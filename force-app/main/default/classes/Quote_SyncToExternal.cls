public with sharing class Quote_SyncToExternal {
    //When quote is marked as activated (by BB) - update the related opp so it will be synced to the external monday board
    public static void syncActivationStatusToExternal(List<Quote> newQuotes, map<Id,Quote> oldQuotes) { 
        set<Id> relevantOppIdsToCheck = new set<Id>();
        for(Quote quote : newQuotes){
            //Check if quote is relevant - synced and activated indication changed and add it's related opp to the set
            if (quote.IsSyncing && 
                quote.Activated_via_Import_SO__c != oldQuotes.get(quote.Id).Activated_via_Import_SO__c && 
                quote.Activated_via_Import_SO__c == true 
                ){ 
                    relevantOppIdsToCheck.add(quote.OpportunityId);
                }
        }

        if (relevantOppIdsToCheck.isEmpty()) return;

        //Check if the collected opps are valid to sync: only opps that are already in the board (item link <> null)
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity opp : [SELECT id, Sync_to_External_monday__c FROM Opportunity WHERE Id IN:relevantOppIdsToCheck AND monday_External_Item__c != '']){
            opp.Sync_to_External_monday__c = true;
            oppsToUpdate.add(opp);
        }

        //update all opps
        if(!oppsToUpdate.isEmpty()) {
            System.enqueueJob(new Utilities.updatesObjectsQueueable(oppsToUpdate));
        } 
}
}
