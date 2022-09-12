public with sharing class Quote_CallBigBrainPreview {
    
    public static void callBigBrainPreviewService(List<quote> newQuotes, map<id,quote> oldMap){//will wrok on single record - when bb set the api as bulkefied, todo - change to bulkefied
        //for manualy signed quotes, the ervice called from the close won process
        if (newQuotes[0].BigBrain_Preview_API_Status__c==null && newQuotes[0].Is_Finalized__c != oldmap.get(newQuotes[0].id).Is_Finalized__c && newQuotes[0].Is_Finalized__c==true ) {
            Opportunity opp = [select id, account.primary_pulse_account_id__c from opportunity where id=:newQuotes[0].opportunityId limit 1];
            if (opp.account.primary_pulse_account_id__c!=null && opp.account.primary_pulse_account_id__c!='') {
                System.enqueueJob(new runSalesOrderErrorQueueable(opp.account.primary_pulse_account_id__c,newQuotes[0].Id));
            }
        }
        //in case the service ran before the contract updates, re-run again and reset the prior response 
        if (newQuotes[0].BigBrain_Preview_API_Status__c=='Invalid' && newQuotes[0].Contract != oldmap.get(newQuotes[0].id).Contract && newQuotes[0].Contract!=null ) {
            Opportunity opp = [select id, account.primary_pulse_account_id__c from opportunity where id=:newQuotes[0].opportunityId limit 1];
            if (opp.account.primary_pulse_account_id__c!=null && opp.account.primary_pulse_account_id__c!='') {
                retryForInvalidResponse(newQuotes[0],opp.account.primary_pulse_account_id__c);
            }
        }
    }
    public static void retryForInvalidResponse(quote quoteToRetry, string pulseId){//TODO Wehn bb support bulk, change to bulk
        List<Order_Activation_Conflict__c> relatedConfs = [select id from Order_Activation_Conflict__c where quote__c =: quoteToRetry.Id];
        if (!relatedConfs.isempty()) {
            delete relatedConfs;
        }
        System.enqueueJob(new runSalesOrderErrorQueueable(pulseId,quoteToRetry.Id));
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