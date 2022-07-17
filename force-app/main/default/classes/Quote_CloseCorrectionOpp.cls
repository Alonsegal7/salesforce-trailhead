public with sharing class Quote_CloseCorrectionOpp {
    public static void Quote_CloseCorrectionOpp(List<Quote> newQuotes, map<Id,Quote> oldQuotes) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>(); //correction opps to update list
        for(Quote quote : newQuotes){
            if ((quote.Is_Correction__c || quote.Servie_PS_Quote__c)&& //correction quote only
                quote.IsSyncing && //quote is synced to opp
                quote.DH_Quote_Status__c != oldQuotes.get(quote.Id).DH_Quote_Status__c && //DH quote status changed
                quote.DH_Quote_Status__c == 'Won'){ //DH quote status changed to 'Won'
                    oppsToUpdate.add(new Opportunity( // initialize an opp with the oppId from Quote and stage Closed Won and add this opp to oppsToUpdate list
                        Id = quote.OpportunityId,
                        StageName = 'Closed Won'
                    ));
            }
        }
        
        try {
            //Database.update(oppsToUpdate);
            if(!oppsToUpdate.isEmpty()) {
                System.enqueueJob(new Utilities.updatesObjectsQueueable(oppsToUpdate));
            }
        } catch (Exception e) {
            system.debug('Error in Quote_CloseCorrectionOpp: ' + e.getMessage());
        }
    }
}