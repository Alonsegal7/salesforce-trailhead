public with sharing class Quote_CallBigBrainPreview {
    
    public static void callBigBrainPreviewService(List<quote> newQuotes, map<id,quote> oldMap){//will wrok on single record - when bb set the api as bulkefied, todo - change to bulkefied
        if (newQuotes[0].BigBrain_Preview_API_Status__c==null && newQuotes[0].Is_Finalized__c != oldmap.get(newQuotes[0].id).Is_Finalized__c && newQuotes[0].Is_Finalized__c==true ) {//for manualy signed quotes, the ervice called from the close won process
            Opportunity opp = [select id, account.primary_pulse_account_id__c from opportunity where id=:newQuotes[0].opportunityId limit 1];
            System.enqueueJob(new runSalesOrderErrorQueueable(opp.account.primary_pulse_account_id__c,newQuotes[0].Id));
        }
    }
    private class runSalesOrderErrorQueueable implements System.Queueable, Database.AllowsCallouts {
        private String pulseId;
        private String quoteId;

        public runSalesOrderErrorQueueable(String pulseId, String quoteId) {
            this.pulseId = pulseId;
            this.quoteId = quoteId;
        }
        public void execute(System.QueueableContext ctx) {
            SalesOrderErrorHandlingService.CallBigBrainPreview(quoteId,pulseId);
        }
    } 
}