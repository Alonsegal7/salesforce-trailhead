public with sharing class Contract_PostSigneChanges {
    public static Boolean firstRunOpp = true;

    public static void HandleLostOpptyForQuote(List<Opportunity> oppties, Map<Id,Opportunity> oldOppty){//handle signed sales orders for lost oppties
        Set<Id> syncedQuoteIds = new Set<Id>();
        for (Opportunity oppty : oppties) {
            if (oppty.Is_Primary_SO_Signed__c==true && oppty.stagename!=oldoppty.get(oppty.id).stagename && oppty.stagename=='Closed Lost') {
                syncedQuoteIds.add(oppty.syncedquoteid);
            }
        }

        if (!syncedQuoteIds.isEmpty()) {
            List<Quote> relevantQuotes =[select id,Quote_Type__c,contractid from quote where id in: syncedQuoteIds];
            HandleContractForPostSigneture(relevantQuotes);
            firstRunOpp = false;

        }
    }

    public static void HandleUnsyncQuote(List<quote> quotes, Map<Id,quote> oldQuote){//NEED TO HANDLE CASES WHERE THE CONTRACT WAS ACTIVATED
        List<quote> relevantQuotes = new List<quote>();
        for (Quote q : quotes) {
            if (q.issyncing!=oldQuote.get(q.id).issyncing && q.issyncing==false && q.Is_Finalized__c==true) {//signed quote was unsynced from the opportunity
                relevantQuotes.add(q);
            }
        }
        if (!relevantQuotes.isEmpty()) {
            HandleContractForPostSigneture(relevantQuotes);
        }
    }

    public static void HandleContractForPostSigneture(List<quote> relevantQuotes){
        try{
        Utilities.sendSlackMessage('Oppty was lost with contract - check and verify ', 'alon-monitoring', null , null, null, '@channel relevant quotes Ids: ' + relevantQuotes + ' <br/>Date: ' + date.today(), null);
        Set<Id> proRatedQuoteIds = new Set<Id>();
        Set<Id> newConts = new Set<Id> ();

        for (Quote q : relevantQuotes) {
            if (q.Quote_Type__c=='Pro-rated- Additional Seats') {
                proRatedQuoteIds.add(q.Id);

            }
            if (q.Quote_Type__c=='New Contract' || q.Quote_Type__c=='Change Tier in the same term') {
                newConts.add(q.contractid);
            }
        }
        if (!proRatedQuoteIds.isempty()) {
            handleProRatedCancellation(proRatedQuoteIds);
        }
        if (!newConts.isempty()) {
            handleNewContractCancellation(newConts);
            }
    }catch(Exception e){
            Utilities.sendDebugEmail('Error in handleLostOpptyForQuote',e,e.getMessage());   
        }
    }
    
    private static void handleProRatedCancellation(set<Id> proRatedQuoteIds){
        List<Contract_Event__c> eventsToUpdate = new List<Contract_Event__c>();
        for(Contract_Event__c conEvent : [select id,status__c,quote_line_item__r.quoteId from contract_event__c where quote_line_item__r.quoteId in: proRatedQuoteIds]){
            conEvent.status__c='Canceled';
            conEvent.Cancellation_Reason__c='Deal Was Lost';
            eventsToUpdate.add(conEvent);
        }
        if (!eventsToUpdate.isempty()) {
            update eventsToUpdate;
        }
    }
    private static void handleNewContractCancellation(set<id> newConts){
        List<contract> conToUpdate = new List<contract>();
        Map<Id, Id> newConPrioConMap = new Map<Id, Id>();
        List<Account> accToUpdate = new List<Account>();
        Set<Id> oldContIds = new Set<Id>();
    
        for (contract con : [select id,status__c,prior_contract__c,prior_contract__r.status__c from contract where id in: newconts]) {
            con.status__c='Deactivated';
            if (con.prior_contract__c !=null && con.status__c!='Future Activation') {
                newConPrioConMap.put(con.Id,con.prior_contract__c);
                conToUpdate.add(new Contract(Id=con.prior_contract__c,status__c='Active',Continuation_Contract__c=null));
                con.prior_contract__c=null;
            }
            conToUpdate.add(con);
        }
        if (!newConPrioConMap.isEmpty()) {
            for (account acc :[select id,active_contract__c from account where active_contract__c in:newConPrioConMap.keySet()]) {
                acc.active_contract__c=newConPrioConMap.get(acc.active_contract__c);
                accToUpdate.add(acc);
            }
        }
        if (!conToUpdate.isempty()) {
            update conToUpdate;
        }
        if (!accToUpdate.isempty()) {
            update accToUpdate;
        }
    }
}