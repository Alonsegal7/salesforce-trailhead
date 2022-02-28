public without sharing class Subscription_ConnectToContractEvent {
    public static map<string,id> subOrderNumbers = new map<string,id>();
    public static boolean multipleSubsUpdated=false;
    public static map<string,Id> priorContsMap = new map<string,Id>();

    public static void Subscription_ConnectToContract(List<Subscription__c> newSubs, map<Id, Subscription__c> oldMap) {
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

            List<Contract> contractsToUpdate= new List<Contract>();
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
                            //Check if Extract added seats to sub
                            conProdsKeys.add(sub.Contract__c+sub.SKU__c);
                            if(sub.SO_Import_Type__c=='Pro-rated'){//for pro rated deal imported in BB, do not update prices as they are not aligned in BB
                                contractsToUpdate.add(new contract(id=sub.Contract__c,
                                                                    Seats__c=integer.valueof(sub.Seats__c)));
                            }else{
                                contractsToUpdate.add(new contract(id=sub.Contract__c,
                                                                    Seats__c=integer.valueof(sub.Seats__c),
                                                                    List_Price__c=sub.List_Price__c,
                                                                    Unit_Price__c=sub.Unit_Price__c,
                                                                    Discount__c=sub.Discount__c));
                            }
                        }
                        else if(acc.Active_Contract__c!=null&&sub.Deactivation_Date__c!=acc.Active_Contract__r.EndDate) {//Active Contract is related to the account and subscription dates are above contract end date -needs to decativate
                                //contractsToDeactivate.add(new contract(id=acc.Active_Contract__c,Status__c='Deactivated'));
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

            //Values for sub creation will kept for pilot    
            if(!contractsToUpdate.isempty())
            update contractsToUpdate;

            if(!contractsToDeactivate.isempty())
            update contractsToDeactivate;
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Subscription_ConnectToContract ',e,e.getMessage()+'Cons To Create');   
        }
    }

    public static List<Subscription__c> sortSubsByContractCreation(List <Subscription__c> subs){
        List<Subscription__c> sortedSubsByContractCreationField = new List<Subscription__c>();
        List<Subscription__c> NotContractCreationSubs = new List<Subscription__c>();
        try {
        for (Subscription__c sub : subs) {
            if (sub.SKU__c.contains('CORE')) {
                sortedSubsByContractCreationField.add(sub);
            }
            else {
                NotContractCreationSubs.add(sub);
            }
        }
        if (!NotContractCreationSubs.isempty()) {
            sortedSubsByContractCreationField.addall(NotContractCreationSubs);
        }
    }catch(Exception e){
        Utilities.sendDebugEmail('Error in SubscriptionToContractEvent ',e,e.getMessage());   
    }
    return sortedSubsByContractCreationField;
}

    public static void SubscriptionToContractEvent(List<Subscription__c> newSubs, map<Id, Subscription__c> oldMap) {
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
                    }
                    //Contract wasn't found on before trigger and didn't imported by so- create contract and event 
                    if (sub.Status__c=='ACTIVE'&&sub.Contract__c==null&&sub.Activated_via_Import_SO__c==false && !subOrderNumbers.containskey(sub.order_number__c)) {
                        subsConEventToCreate.add(sub); 
                        //In case of multi-product subscriptions, Only one contract will be created for the subscrition (random chose)
                        if (sub.order_number__c!=null) {
                            subOrderNumbers.put(sub.order_number__c,sub.id); 
                        }
                    }
                    //Imported by SO - check if the monday account is different then the activation monday account (activate on different account)
                    if(sub.Status__c=='ACTIVE'&&sub.Contract__c!=null&&sub.Source_Sales_Order__c!=null&&sub.Activated_via_Import_SO__c==true){
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