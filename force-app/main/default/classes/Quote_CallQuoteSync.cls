public class Quote_CallQuoteSync {
    public static Boolean firstRun=true;  
    public static void Quote_CallQuoteSync(List<Quote> newQuote, Map<Id,Quote> oldMap){
        for (Quote quoteRec : newQuote) {
            if (quoteRec.Sync_Request_Timestamp_iConduct__c != oldMap.get(quoteRec.Id).Sync_Request_Timestamp_iConduct__c ) {
                firstRun=false;   
                System.enqueueJob(new IConductService('Quote',quoteRec.Id));
            }
        }        
    }
}
