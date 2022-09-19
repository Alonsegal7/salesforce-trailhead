public without sharing class Subscription_ConnectToContractEvent {
    public static map<string,id> subOrderNumbers = new map<string,id>();
    public static boolean multipleSubsUpdated=false;
    public static map<string,Id> priorContsMap = new map<string,Id>();

    public static void Subscription_ConnectToContract(List<Subscription__c> newSubs, map<Id, Subscription__c> oldMap) {//run's before
        try{
            
            set<string> subsPulseIds= new set<string>();
            Set<string> subsProductSKUs = new Set<string>();
            Set<string> conProdsKeys = new Set<string>();
            map<string,Contract_Product__c> conProdsMap= new map<string,Contract_Product__c>(); 

            if(oldMap==null)//insert
                for(Subscription__c sub: newSubs){
                    //There could be multiple active subs for accuont (solutions)
                    if (!subsPulseIds.contains(sub.Pulse_Account_Id__c)) {
                        subsPulseIds.add(sub.Pulse_Account_Id__c); 
                    }
                    subsProductSKUs.add(sub.SKU__c);
                }
            else{//update (will be only for manual trigger)
                for(Subscription__c sub: newSubs){
                    if(sub.Manual_Trigger__c!=oldMap.get(sub.id).Manual_Trigger__c&&sub.Manual_Trigger__c=='Create Active Contract'){
                    priorContsMap.put(sub.BigBrain_Id__c,sub.Contract__c);
                    subsPulseIds.add(sub.Pulse_Account_Id__c);   
                    subsProductSKUs.add(sub.SKU__c);  
                    sub.ContractCreatedByThisSubscription__c=true; //This subscription is going to create the contract - indicate that on the sub
                    }
                }
            }

            if(subsPulseIds.isEmpty())
                return;

            map<string,Account> accountsByPulseId= new map<string,Account>(); 
            for(Account acc: [select id,primary_pulse_account_id__c,Active_Contract__c,Company__c,Active_Contract__r.EndDate
                                from Account where primary_pulse_account_id__c in: subsPulseIds]){
                if(!accountsByPulseId.containsKey(acc.primary_pulse_account_id__c))
                    accountsByPulseId.put(acc.primary_pulse_account_id__c,acc);
            }

            map<string,Product2> prodBySKUs= new map<string,Product2>(); 
            for(Product2 prod: [select id,Product_Identifier__c
                                from Product2 where IsActive=true AND Product_Identifier__c in: subsProductSKUs]){
                if(!prodBySKUs.containsKey(prod.Product_Identifier__c))
                    prodBySKUs.put(prod.Product_Identifier__c,prod);
            }
            List<Contract> contractsToDeactivate= new List<Contract>();

            for(Subscription__c sub: newSubs){
                if(accountsByPulseId.containsKey(sub.Pulse_Account_Id__c)){
                    Account acc=accountsByPulseId.get(sub.Pulse_Account_Id__c);
                    if (sub.SKU__c!=null && prodBySKUs.containsKey(sub.SKU__c)) {
                        sub.Product__c=prodBySKUs.get(sub.SKU__c).Id;
                    }
                    sub.Monday_Account__c=acc.Id;
                    if(sub.Status__c=='ACTIVE'&&sub.Contract__c==null){//if contract is selected in BB, do not create/connect to another contract
                        if(acc.Active_Contract__c!=null&&sub.Deactivation_Date__c==acc.Active_Contract__r.EndDate){//connect to existing active contract (Different end date will create a new contract)
                            sub.Contract__c=acc.Active_Contract__c;
                            conProdsKeys.add(sub.Contract__c+sub.SKU__c);//Check if Extract added seats to sub
                        }
                        else if(acc.Active_Contract__c!=null&&sub.Deactivation_Date__c!=acc.Active_Contract__r.EndDate) {//Active Contract is related to the account and subscription dates are above contract end date -needs to decativate
                                priorContsMap.put(sub.BigBrain_Id__c,acc.Active_Contract__c);//We use this map in order to update this contract on the new contract created
                                sub.ContractCreatedByThisSubscription__c=true;//This subscription is going to create the contract - indicate that on the sub
                        }
                        else {//This subscription is going to create the contract - indicate that on the sub
                            sub.ContractCreatedByThisSubscription__c=true;
                        }
                    }
                }
            }
            //Extract added seats?
            for(Contract_Product__c ConProd: [select id,Contract_Product_Identifier__c,Quantity__c
                                from Contract_Product__c where Contract_Product_Identifier__c in: conProdsKeys]){
                if(!conProdsMap.containsKey(ConProd.Contract_Product_Identifier__c))
                    conProdsMap.put(ConProd.Contract_Product_Identifier__c,ConProd);
            }

            //update added seats
            for (Subscription__c sub : newSubs){
                if (conProdsMap.containskey(sub.Contract__c+sub.SKU__c)) {//Contract Product was found - substract sub seats from cont prod seats
                    Contract_Product__c currentConProd = conProdsMap.get(sub.Contract__c+sub.SKU__c);
                    Decimal addedSeats = Decimal.valueof(sub.Seats__c)-currentConProd.Quantity__c;
                    sub.Contract_Added_Seats__c=addedSeats;
                 }
                else {//Contract Product wasnt found - added seats = total seats
                    sub.Contract_Added_Seats__c=Decimal.valueof(sub.Seats__c);
                }
            }

            if(!contractsToDeactivate.isempty())
            update contractsToDeactivate;

        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Subscription_ConnectToContract ',e,e.getMessage()+'Cons To Create');   
        }
    }

    public static List<Subscription__c> sortSubsByContractCreation(List <Subscription__c> subs){//sort the subs to get the core first - core are the contract creation subs
        List<Subscription__c> sortedSubsByContractCoreProduct = new List<Subscription__c>();
        List<Subscription__c> NotCoreSubs = new List<Subscription__c>();
        try {
        for (Subscription__c sub : subs) {
            if (sub.SKU__c.contains('CORE')) {
                sortedSubsByContractCoreProduct.add(sub);
            }
            else {
                NotCoreSubs.add(sub);
            }
        }
        if (!NotCoreSubs.isempty()) {
            sortedSubsByContractCoreProduct.addall(NotCoreSubs);
        }
    }catch(Exception e){
        Utilities.sendDebugEmail('Error in SubscriptionToContractEvent ',e,e.getMessage());   
    }
    return sortedSubsByContractCoreProduct;
}

    public static void SubscriptionToContractEvent(List<Subscription__c> newSubs, map<Id, Subscription__c> oldMap) {//run's on after
        try {
        Map<Id, Subscription__c> subsMapToGetARR = new Map<Id, Subscription__c>();
        List <Subscription__c> subsConEventToCreate = new List <Subscription__c>();
        List <Subscription__c> subsConEventToUpdate = new List <Subscription__c>();
        List <Subscription__c> subsToUpdateContract = new List <Subscription__c>();
        List <Subscription__c> multiContractSubsToEvents = new List <Subscription__c>();
        Map<Id, List<Contract_Event__c>> existingContractAndconEventMap = new Map<Id, List<Contract_Event__c>>();
        List <Contract_Event__c> conEventForExisContract = new List<Contract_Event__c>();
        Set<Id> contractIds = new Set<Id>();
        List<Account> acctsToUpdateActiveCon = new List<Account>();
        List<Subscription__c> subImportedBySo = new List<Subscription__c>();
        List<Contract> contToUpdateCoreActivation = new List<Contract>();

        //First, Create a set of contract id's from subs to define a map of contract events related to the set(Used later in SameTermEventExist function)
        for (Subscription__c sub : newSubs) {
            if (sub.Contract__c!=null) {
                contractIds.add(sub.Contract__c);
            }
        }
        if (!contractIds.isEmpty()) {
             //Prepere a map to check if there is a contract event with the same term for this subscription  (Used later in SameTermEventExist function)
            for (Contract_Event__c existingConEvnt : [select Id,sku__c,Product__c,Contract__c, Start_Date__c, End_Date__c, ARR__c, IsRecurring__c from Contract_Event__c where IsRecurring__c=true and Contract__c in:contractIds ])
            {
                if (existingContractAndconEventMap.containsKey(existingConEvnt.Contract__c)) {
                    existingContractAndconEventMap.get(existingConEvnt.Contract__c).add(existingConEvnt);
                }
                else {
                    existingContractAndconEventMap.put(existingConEvnt.Contract__c, new List <Contract_Event__c>{existingConEvnt});
                }
            }      
        }

        //Now, handle contract creations/event update
            if (oldMap==null) {//insert 
                for (Subscription__c sub : newSubs) {
                    //Contract was added on the 'before' trigger
                    //Contract event fields is mapped on the ContractEventMapping__mdt (Including the contract created on the before)
                    if(sub.Status__c=='ACTIVE'&&sub.Contract__c!= null&&sub.Activated_via_Import_SO__c==false && !SameTermEventExist(existingContractAndconEventMap,sub)){
                        subsConEventToUpdate.add(sub);
                        conEventForExisContract.addall(ContractEventHandler.DefineContractEvent(subsConEventToUpdate));

                        if (sub.sku__c.contains('CORE')) {//connect core activation to contract
                            contToUpdateCoreActivation.add(new Contract(Id=sub.Contract__c,Core_Activation__c=sub.Id));
                        }
                    }
                    //Contract wasn't found on before trigger and didn't imported by so- create contract and event 
                    if (sub.Status__c=='ACTIVE'&&sub.Contract__c==null&&sub.Activated_via_Import_SO__c==false && !subOrderNumbers.containskey(sub.order_number__c)) {
                        subsConEventToCreate.add(sub); 
                        //In case of multi-product subscriptions, Only one contract will be created for the subscrition (the core - after sorted on trigger sort function)
                        if (sub.order_number__c!=null) {
                            subOrderNumbers.put(sub.order_number__c,sub.id); 
                        }
                    }
                    //Imported by SO - check if the monday account is different then the activation monday account (activate on different account)
                    if((sub.Status__c=='ACTIVE' || sub.Status__c=='PENDING' )&&sub.Contract__c!=null&&sub.Source_Sales_Order__c!=null&&sub.Activated_via_Import_SO__c==true){
                        subImportedBySo.add(sub);
                    }
                }
            }
             
            else {//update
                for (Subscription__c sub : newSubs) {
                    if(sub.Manual_Trigger__c!=oldMap.get(sub.id).Manual_Trigger__c&&sub.Manual_Trigger__c=='Create Active Contract'){
                        subsConEventToCreate.add(sub);
                    }
                    if (sub.Status__c=='ACTIVE' && sub.contract__c!=null && ((sub.arr__c !=null && oldMap.get(sub.id).arr__c==null) || (sub.ARR_Gain__c !=null && oldMap.get(sub.id).ARR_Gain__c==null))) {
                        subsMapToGetARR.put(sub.id,sub);
                    } 
                }
            }
                    //New contract and contract event
                    if (!subsConEventToCreate.isempty()) {
                        ContractEventHandler.ActivationsContractEventNewContracts(subsConEventToCreate);
                    }
                    //update arr to con event is added after insert (and it was null)
                    if (!subsMapToGetARR.isEmpty()) {
                        updateArrToEvent(subsMapToGetARR);
                    } 
                    
                    //For multiple subs under the same contract, find the created contract and call the conEventForExisContract function to set a cont product and con events
                    if (multipleSubsUpdated==false) {
                        for (Subscription__c sub : newSubs) {
                            if (sub.order_number__c !=null && ContractEventToContract.createdContForSubOrder.containsKey(sub.Order_Number__c) && sub.Id != subOrderNumbers.get(sub.order_number__c)) {
                                multiContractSubsToEvents.add(sub);
                                subsToUpdateContract.add(new Subscription__c(Id=sub.Id,Contract__c=ContractEventToContract.createdContForSubOrder.get(sub.order_number__c)) );
                            }
                        }
                    }
                    if (!subsToUpdateContract.isempty()) {
                        multipleSubsUpdated=true;
                        update subsToUpdateContract;
                        //System.enqueueJob(new createContractToSubscriptionsQueueable(subsToUpdateContract));
                    }
                    if (!subImportedBySo.isempty()) {
                        ConnectImportedActivation(subImportedBySo);
                        List<Account> accts = handleDifferentActivation(subImportedBySo);
                        if (accts!=null) {
                            acctsToUpdateActiveCon.addall(accts); 
                        }
                    }
                    //Contract event for existing contract
                    if (!multiContractSubsToEvents.isempty()) {
                        conEventForExisContract.addall(ContractEventHandler.DefineContractEvent(multiContractSubsToEvents));
                    }       
                    if (!conEventForExisContract.isempty()) {
                        System.enqueueJob(new createContractEventsQueueable(conEventForExisContract));
                    }   
                    if (!acctsToUpdateActiveCon.isempty()) {
                        System.enqueueJob(new updateAccountQueueable(acctsToUpdateActiveCon));
                    } 
                    if (!contToUpdateCoreActivation.isempty()) {
                        update contToUpdateCoreActivation;
                    }

        }catch(Exception e){
            Utilities.sendDebugEmail('Error in SubscriptionToContractEvent ',e,e.getMessage());   
        }
    }

    //Function to check if a subscription holds the same start date, and date, and ARR of contract events - to avoid duplication
    public static Boolean SameTermEventExist(Map<Id, List<Contract_Event__c>> conEvnts, Subscription__c sub){
        Boolean evntExist = false;
        for (Id conKey : conEvnts.keyset()) {
            for (Contract_Event__c singleEvent : conEvnts.get(conKey)) {
                 if (singleEvent.Contract__c==sub.Contract__c&&singleEvent.Start_Date__c==sub.Activation_Date__c && 
                     singleEvent.End_Date__c==sub.Deactivation_Date__c && singleEvent.SKU__c==sub.SKU__c && 
                     singleEvent.ARR__c==sub.ARR__c) {
                     evntExist=true;  
                }
            }
        }
        return evntExist; 
    }
    //There are cases that the arr is inserted to the subscription__c after he created - we need to update the contract event
    public static void updateArrToEvent(Map<Id,Subscription__c> subs){
        List<contract_event__c> conEvntsToUpdate = new List<contract_event__c>();
        for (contract_event__c conEvn:[select id, ARR__c,subscription__c from contract_event__c where subscription__c in:subs.keyset() ]){
            conEvn.arr__c = subs.get(conEvn.subscription__c).Contract_Event_ARR__c;
            conEvntsToUpdate.add(conEvn);
        }
        update conEvntsToUpdate;
    }

    //This function handle different actiavtion change where the sales order is chosen 
    public static List<Account> handleDifferentActivation(List<Subscription__c> subImportedBySo){
        List<Account> acctsToUpdate = new List<Account>();
        for (Subscription__c sub : [SELECT Id, Contract__c, Source_Sales_Order__r.Opportunity.AccountId, Source_Sales_Order__r.Opportunity.Account.Monday_Account_Status__c, Monday_Account__r.Active_Contract__c FROM Subscription__c WHERE Id=:subImportedBySo]) {
            if (sub.Monday_Account__c!=sub.Source_Sales_Order__r.Opportunity.AccountId && sub.Contract__c!=sub.Monday_Account__r.Active_Contract__c) {
                acctsToUpdate.add(new Account (Id=sub.Monday_Account__c,Active_Contract__c=sub.Contract__c));
                if (sub.Source_Sales_Order__r.Opportunity.Account.Monday_Account_Status__c=='Trial Account') {
                    acctsToUpdate.add(new Account (Id=sub.Source_Sales_Order__r.Opportunity.AccountId,Active_Contract__c=null));
                }
                Utilities.sendEmail('Contract was move on subscription activation', 'Subscription Id: ' + sub.Id + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E') +'From Account: ' + sub.Source_Sales_Order__r.Opportunity.AccountId + 'To Account: '+ sub.Monday_Account__c, new List<String>{'alonse@monday.com'});
                Utilities.sendSlackMessage('Contract was move on subscription activation ', 'alon-monitoring', null , null, null, '@channel Subscription Id: ' + sub.Id + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E') +'From Account: ' + sub.Source_Sales_Order__r.Opportunity.AccountId + ' To Account: '+ sub.Monday_Account__c, null);
            }
        }
        if (!acctsToUpdate.isEmpty()) {
            return acctsToUpdate;
        }
        return null;
    }
    //connect activation to sales order event (to inidicate activation. in case of non sale order event, managed by the metadata map)
    public static void ConnectImportedActivation(List<Subscription__c> subs){
        Map<string, Subscription__c> subsQuotes = new Map<string, Subscription__c>();
        List<Contract_Event__c> conEventsToUpdate = new List<Contract_Event__c>();
        List<Contract> conToUpdate = new List<Contract>();
        Set<Id> quoteIds = new Set<Id>();
        for (Subscription__c sub : subs) {
            quoteIds.add(sub.Source_Sales_Order__c);
            subsQuotes.put(sub.Source_Sales_Order__c+sub.sku__c,sub);
        }
        for (Contract_Event__c conEvent : [select id , Contract__c,quote_line_item__r.quoteId,sku__c from contract_event__c where quote_line_item__r.quoteId in: quoteIds]) {
            if(subsQuotes.containskey(conEvent.quote_line_item__r.quoteId + conEvent.sku__c)){
                if (conEvent.sku__c.contains('CORE')) {//connect core subscription to contract
                    conToUpdate.add(new Contract (id=conEvent.Contract__c,Core_Activation__c=subsQuotes.get(conEvent.quote_line_item__r.quoteId + conEvent.sku__c).Id));
                }
                conEventsToUpdate.add(new Contract_Event__c (id=conEvent.id,Related_Activation__c=subsQuotes.get(conEvent.quote_line_item__r.quoteId + conEvent.sku__c).Id));
            }
        }
            update conEventsToUpdate;
            update conToUpdate;
    }

    private class createContractEventsQueueable implements System.Queueable {
        private List<Contract_Event__c> contractEventToCreateList; 
        public createContractEventsQueueable(List<Contract_Event__c> contractEventToCreateList) {
            this.contractEventToCreateList = contractEventToCreateList;
        }
        public void execute(System.QueueableContext ctx) {
            ContractEventHandler.CreateContractEventForExistingContract(contractEventToCreateList);
        }
    }

    private class updateAccountQueueable implements System.Queueable {
        private List<Account> accToUpdate; 
        public updateAccountQueueable(List<Account> accToUpdate) {
            this.accToUpdate = accToUpdate;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(accToUpdate);
        }
    }
}