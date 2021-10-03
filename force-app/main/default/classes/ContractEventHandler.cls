public with sharing class ContractEventHandler {

    public static Map<Id, Quote> alreadyHandledQuotes = new Map<Id, Quote>();
    public static Boolean isRevisedProRatedQuote;

    public static void SalesOrderContractEvent(List<Quote> quotes, Map<Id,Quote> oldQuotes){
        try{
            List<Quote> quotesToHandle = new List<Quote>();
            List <Contract_Event__c> conEventForExisContract = new List<Contract_Event__c>();
            Map<Id, List<Contract_Event__c>> newContractEvents = new Map<Id, List<Contract_Event__c>>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            List<Quote> proRatedQuotesToUpdate = new List<Quote>();
            List<Quote> newContractQuote = new List<Quote>();
            List<Contract> proRataedContsToUpdate = new List<Contract>();
            List<Quote> newContractsQuotesToUpdate = new List<Quote>();
            Set<Id> currentQuotesProRatedContracts = new Set<Id>();
            Map<Id, Contract> currentContractsMap = new Map<Id, Contract>();
            Map<Id, List<Contract_Event__c>> existingContractAndconEventMap = new Map<Id, List<Contract_Event__c>>();
            List<Contract_Event__c> conEventsToCancel = new List<Contract_Event__c>();
            Map<Id, Decimal> priorContractSeatsMap = new Map<Id, Decimal>();

            //First, Check if the quote signed
            for (Quote quote : quotes) {
                if (((quote.Is_Finalized__c == true && oldQuotes.get(quote.Id).Is_Finalized__c == false && quote.ContractId==null) ||
                    (oldQuotes.get(quote.Id).Manual_Trigger__c != quote.Manual_Trigger__c && quote.Manual_Trigger__c == 'Create Active Contract')) && !alreadyHandledQuotes.containskey(quote.id)) {
                    //For pro-rated, get the contract id in order to retrive the current contract seats to add the event added seats
                    if (quote.Quote_Type__c=='Pro-rated- Additional Seats' && quote.Get_Contract_Id__c!=null) {
                        currentQuotesProRatedContracts.add((Id)quote.Get_Contract_Id__c);
                    }
                    quotesToHandle.add(quote);
                    //Avoid duplicate operation within single transaction (First run will not work due to dealhub multiple DML's)
                    alreadyHandledQuotes.put(quote.Id,quote);
                }
            }
            if (!currentQuotesProRatedContracts.isEmpty()) {
                //Define a map of contract with seats to update the contract.seats__c field (not the event rollup)
                for (Contract con : [select Id,Seats__c from contract where id in:currentQuotesProRatedContracts]) {
                     currentContractsMap.put(con.Id,con);
                } 
                //Define a map of existing contract event for the pro-rated contract chech on existingContractAndconEventMap function
                for (Contract_Event__c existingConEvnt : [select Id,Status__c,Contract__c, Start_Date__c, End_Date__c, ARR__c, IsRecurring__c,Quantity__c,Quote_Line_Item__r.Quote.OpportunityId from Contract_Event__c where Contract__c in:currentQuotesProRatedContracts ]){
                    if (existingContractAndconEventMap.containsKey(existingConEvnt.Contract__c)) {
                        existingContractAndconEventMap.get(existingConEvnt.Contract__c).add(existingConEvnt);
                    }
                    else {
                        existingContractAndconEventMap.put(existingConEvnt.Contract__c, new List <Contract_Event__c>{existingConEvnt});
                    }
                }
                //Define a map of the contract history to get the prior contract seats  (This is a temporary solution untill fully go live)
                for (ContractHistory conHistory :  [select ContractId,Field,OldValue,NewValue,CreatedDate from ContractHistory where contractId in:currentQuotesProRatedContracts ORDER BY CreatedDate DESC ]) {
                    if (conHistory.Field=='Seats__c' && !priorContractSeatsMap.containsKey(conHistory.ContractId) ) {
                        priorContractSeatsMap.put(conHistory.ContractId,(decimal)conHistory.OldValue);
                    }
                }
            }
            if (!quotesToHandle.isempty()) {
                //Prepere the qury to include all fields (To avoide missing new fields added from the mdt to dynamic function )
                Map<String, Schema.SObjectField> qlisFieldMap = QuoteLineItem.sObjectType.getDescribe().fields.getMap();
                Set<String> qlisFieldNames = qlisFieldMap.keySet();
                String Set_Joined = String.join((Iterable<String>)qlisFieldNames, ', ');
                List<QuoteLineItem> quoteQlis = Database.query('select ' + Set_Joined + ' from QuoteLineItem WHERE Quote.Id IN: quotesToHandle');
                Map<Id, List<QuoteLineItem>> qlisMap = new Map<Id, List<QuoteLineItem>>();
                //this map is used for getting the recuring line item (crrntly alwys will be licnse) of the quote to add the added seats to the contract
                Map<Id, QuoteLineItem> rcringLineItems = new Map<Id, QuoteLineItem>();
                
                //Set a map of quotes and qlis
                for(QuoteLineItem quoteQli : quoteQlis){
                    if (qlisMap.containskey(quoteQli.QuoteId) && quoteQli.Contract_Event_Product__c) {
                        qlisMap.get(quoteQli.QuoteId).add(quoteQli);
                        if (quoteQli.IsRecurring__c) {
                            rcringLineItems.put(quoteQli.QuoteId,quoteQli);
                        }
                    }
                    else if(quoteQli.Contract_Event_Product__c) {
                        qlisMap.put(quoteQli.QuoteId, new List<QuoteLineItem>{quoteQli});
                        if (quoteQli.IsRecurring__c) {
                            rcringLineItems.put(quoteQli.QuoteId,quoteQli);
                        }
                    }
                }
                //After map defined with signed quotes, check if pro-rated or new contract
                if (!qlisMap.isempty()) {
                    for (Quote quote : quotesToHandle) {
                        isRevisedProRatedQuote=false;
                        if (quote.Quote_Type__c=='Pro-rated- Additional Seats') {
                            Decimal proRatedTotalSeats;
                            //First, check if there are contract events for this oppty (We are assuming that if a quote is created for the same oppty is changing the current contract events)
                            conEventsToCancel.addall(CheckIfEventsExistForOppty(existingContractAndconEventMap.get(quote.Get_Contract_Id__c),quote.OpportunityId));
                            
                            //This is a correction SO - Identified by the related conEvents from CheckIfEventsExistForOppty which related to the oppty (only for pro-rated since new contract deals are creating a new contract)
                            if (isRevisedProRatedQuote) {
                                Decimal priorContractSeats = priorContractSeatsMap.get(quote.Get_Contract_Id__c);
                                        proRatedTotalSeats = priorContractSeats+rcringLineItems.get(quote.id).added_seats__c;
                            }
                            //Not a correction so - update the contract seat by the current contract seats + so qli added seats
                            else {
                                Decimal currentContractSeats = currentContractsMap.get(quote.Get_Contract_Id__c).Seats__c;
                                        proRatedTotalSeats = currentContractSeats+rcringLineItems.get(quote.id).added_seats__c;
                            }
                            
                            //is pro-rated  (Contract from opp is maaped from metadata)
                            conEventForExisContract.addall(DefineContractEvent(qlisMap.get(quote.id)));
                            proRataedContsToUpdate.add(new Contract(Id=quote.Selected_Company_Contract__c,
                            
                            //Seats__c referenced in dh so we still updating this field - untill fully go live
                            Seats__c=proRatedTotalSeats));
                            oppsToUpdate.add(new opportunity(id=quote.opportunityId,
                                                            ContractId=quote.Selected_Company_Contract__c));
                            proRatedQuotesToUpdate.add(new Quote(Id=quote.id, ContractId=quote.Selected_Company_Contract__c));
                        }
                        else if (quote.Quote_Type__c=='New Contract' || quote.Quote_Type__c=='Change Tier in the same term'){
                            list<Contract_Event__c> conEventsToCreate = DefineContractEvent(qlisMap.get(quote.id));
                            newContractEvents.put(quote.id,conEventsToCreate);
                            newContractQuote.add(quote);
                            if (quote.Manual_Trigger__c == 'Create Active Contract') {//This condition is checked on the quotesToHandle list
                                NewContractsQuotesToUpdate.add(new Quote(Id=quote.id,Manual_Trigger__c=''));
                            }
                        }
                    }
                    //Updates related records for for pro-rated deals
                    if (!oppsToUpdate.isEmpty()) {
                        System.enqueueJob(new updateOppQueueable(oppsToUpdate));
                    }
                    if (!proRatedQuotesToUpdate.isempty()) {
                        System.enqueueJob(new updateQuoteQueueable(proRatedQuotesToUpdate));
                    }
                    if (!conEventForExisContract.isempty()) {
                        CreateContractEventForExistingContract(conEventForExisContract);
                    }
                    if (!proRataedContsToUpdate.isempty()) {
                        update proRataedContsToUpdate;
                    }
                    if (!conEventsToCancel.isempty()) {
                        update conEventsToCancel;
                    }
                    //New con from man trigger 
                    if (!NewContractsQuotesToUpdate.isempty()) {
                        update NewContractsQuotesToUpdate;
                    }
                    //Creating a new contract for contract events (Contract creation is on ContractEventToContract class)
                    if (!newContractEvents.isempty()) {
                        ContractEventToContract.ContractEventCreateNewContract(newContractEvents,newContractQuote,'Quote');
                    }
                }
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in ContractEventHandler ',e,e.getMessage());   
        }
    }

    public static void ActivationsContractEventNewContracts(List<Subscription__c> subs){
        try {
            //Contract creating condition is defined on Subscription_ConnectToContract
            Map<Id, List<Contract_Event__c>> newContractEvents = new Map<Id, List<Contract_Event__c>>();
            List<Subscription__c> conEventsToCreate = new List<Subscription__c>();
            for (Subscription__c sub : subs) {
                conEventsToCreate.add(sub); 
                newContractEvents.put(sub.Id,DefineContractEvent(conEventsToCreate));
                //The subscription in the loop is the contract creaotr + the first event. therefore, it must be send as a list of subs
                //Since solution can send many subs on single transaction, we need to clear the list after the event conversion on the DefineContractEvent function using clear()
                conEventsToCreate.clear();
            }
            if (!newContractEvents.isempty()) {
                ContractEventToContract.ContractEventCreateNewContract(newContractEvents,subs,'Subscription');
            }
            
        } catch (Exception e ) {
            Utilities.sendDebugEmail('Error in ContractEventHandler - NewCon_subscriptions',e,e.getMessage());   
        }    
    }

    //This functions was created to get any object that defined ContractEventMapping__mdt within metadata 
    public static List<Contract_Event__c> DefineContractEvent(List<SObject> events) {
        Id contractId;
        List<Contract_Event__c> contEvents = new List<Contract_Event__c>();
        Map<String, Object> contEventsfieldValueMap = new Map<String, Object>();
        List<ContractEventMapping__mdt> eventMapMtd = [SELECT ObjectAPI__c,ObjectFieldAPI__c,ContractEventFieldAPI__c,Constant_Value_Mapping__c,Constant_Value__c 
        FROM ContractEventMapping__mdt WHERE ObjectAPI__c =:String.valueOf(events[0].getSObjectType())];
        try{
        for (SObject obj : events) {
            if (String.valueOf(obj.getSObjectType())=='Subscription__c') {
                //check if it is subscription and part of solution
                if (ContractEventToContract.createdContForSubOrder.containskey((string)obj.get('Order_Number__c'))) {
                    contractId=ContractEventToContract.createdContForSubOrder.get((string)obj.get('Order_Number__c'));
                }
            }
            Contract_Event__c conEven = new Contract_Event__c();
            for (ContractEventMapping__mdt contEvenMapData : eventMapMtd) {
                if (contEvenMapData.ContractEventFieldAPI__c=='Contract__c' && contractId!=null ) {
                    conEven.put(contEvenMapData.ContractEventFieldAPI__c,contractId);
                }
                else if (contEvenMapData.Constant_Value_Mapping__c=='Yes') {
                    conEven.put(contEvenMapData.ContractEventFieldAPI__c,contEvenMapData.Constant_Value__c);
                }
                else {
                    conEven.put(contEvenMapData.ContractEventFieldAPI__c,obj.get(contEvenMapData.ObjectFieldAPI__c));
                }
            }
            contEvents.add(conEven);
        }
    }catch(Exception e){
        Utilities.sendDebugEmail('Error in ContractEventHandler -->DefineContractEvent',e,e.getMessage());   
    }
    return contEvents;
    }

    public static list<Contract_Event__c> CheckIfEventsExistForOppty(List<Contract_Event__c> conEvnts, Id proRataOppId){
        List<Contract_Event__c> returnedConEvnts = new List<Contract_Event__c>();
        for (Contract_Event__c event : conEvnts) {
            if (event.Quote_Line_Item__r.Quote.OpportunityId==proRataOppId) {
                event.status__c='Canceled';
                event.Cancellation_Reason__c='Revised Sales Order';
                returnedConEvnts.add(event);
            }
            if (!returnedConEvnts.isempty()) {
                isRevisedProRatedQuote=true;
                return returnedConEvnts;
            }
        }
        return returnedConEvnts;
    }

    //This function is gettin con events from existing contract and update/create them to contract product
    public static void CreateContractEventForExistingContract(List<Contract_Event__c> conEventForExisContract){
        Set<String> contractProdIdentifiers = new Set<String>();
        Map<string, Contract_Product__c> existingConProdMap = new Map<string, Contract_Product__c>();
        Map<string, Contract_Product__c> newConProdMap = new Map<string, Contract_Product__c>();
        List<Contract_Event__c> conEventsToInsert = new List<Contract_Event__c>();

        //Prepere a set of Contract_Product_Identifier__c
        for (Contract_Event__c conEvent : conEventForExisContract) {
            contractProdIdentifiers.add(conEvent.Contract__c+conEvent.SKU__c);
        }
        //Find Contract_Product_Identifier__c on current DB (existing)
        for (Contract_Product__c conProd : [select Id,Contract_Product_Identifier__c from Contract_Product__c where Contract_Product_Identifier__c in:contractProdIdentifiers]) {
            existingConProdMap.put(conProd.Contract_Product_Identifier__c,conProd);
        }
        //Update contract product to pro-rated event. if not found it means contract product needs to be created
        for (Contract_Event__c conEvent : conEventForExisContract) {
            if (existingConProdMap.get(conEvent.Contract__c+conEvent.SKU__c)!=null) {
                conEvent.Contract_Product__c=existingConProdMap.get(conEvent.Contract__c+conEvent.SKU__c).Id;
                conEventsToInsert.add(conEvent);
            }
            //Didn't found - create contract product and assign event
            else {
                Contract_Product__c conProd = new Contract_Product__c(
                    Product__c=conEvent.Product__c, 
                    Contract__c=conEvent.Contract__c);
                    newConProdMap.put(conEvent.Contract__c+conEvent.SKU__c,conProd);
                    conEventsToInsert.add(conEvent);
            }
        }
        //First, insert the new contract products
        if (!newConProdMap.isempty()) {
            insert newConProdMap.values();
        }
        //Now, run on all the events w/o contract products and assign the created contract product
        for (Contract_Event__c conEvent : conEventsToInsert) {
            if (conEvent.Contract_Product__c==null) {
                conEvent.Contract_Product__c=newConProdMap.get(conEvent.Contract__c+conEvent.SKU__c).Id;
            }
        }
        //When all con events are with contrat product (new or existing) - insert the prorated con events
        if (!conEventsToInsert.isempty()) {
            insert conEventsToInsert;
        }
    }


	private class updateOppQueueable implements System.Queueable {
        private List<Opportunity> oppToUpdateList; 
        public updateOppQueueable(List<Opportunity> oppToUpdateList) {
            this.oppToUpdateList = oppToUpdateList;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(oppToUpdateList);
        }
    }
    private class updateQuoteQueueable implements System.Queueable {
        private List<Quote> quoteToUpdateList; 
        public updateQuoteQueueable(List<Quote> quoteToUpdateList) {
            this.quoteToUpdateList = quoteToUpdateList;
        }
        public void execute(System.QueueableContext ctx) {
            try{
                Database.update(quoteToUpdateList);
            } catch (Exception e){
                Utilities.sendDebugEmail('Error in SalesOrderContractEvent quoteToUpdateList queueable first attempt',e,e.getMessage());
                if(e.getMessage().containsIgnoreCase('Record Currently Unavailable')){
                    try{
                        Database.update(quoteToUpdateList);
                    } catch (Exception e2){
                        Utilities.sendDebugEmail('Error in quoteToUpdateList updateAccounts queueable second attempt',e2,e2.getMessage());
                    }
                }
            }
        }
    }
}