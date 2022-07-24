public with sharing class Quote_CreateQuoteHistory {
    public static Map<String, Object> historyMap = new Map<String, Object>();
    public static Map<Id,Boolean> quoteLocked = new Map<Id,Boolean>();
    public static void CreateQuoteHistory(List <Quote> quotes, Map<Id, Quote> oldQuotes) {
        Schema.FieldSet trackChangesFieldSet = Schema.SObjectType.Quote.fieldSets.getMap().get('TrackChangesFields');
        List<Quote_History__c> quoteHistoryToCreate = new List<Quote_History__c>();
        for (Quote quote : quotes) {
            /*  BUG FIX
                =============
                * BUG LIFE Description: Quote_History failed to insert because of the Parent Quote record that was locked by Approval Process (Approval.isLocked(quote.Id))
                * BUG Link (Salesforce Magic 2.0 Board): https://monday.monday.com/boards/2016847993/pulses/2823961519
                * Approval Process on Quote object: Finance approval to signed SO
            */
            if(Approval.isLocked(quote.Id) == false){
                for (Schema.FieldSetMember fldSetMmber : trackChangesFieldSet.getFields()) {
                    if (quote.get(fldSetMmber.getFieldPath()) != oldQuotes.get(quote.Id).get(fldSetMmber.getFieldPath())) {
                        if (!historyMap.containskey(fldSetMmber.getFieldPath()) || historyMap.get(fldSetMmber.getFieldPath())!=quote.get(fldSetMmber.getFieldPath())) {
                            Quote_History__c quteHis = new Quote_History__c(
                                Date__c=datetime.now(),
                                Quote__c=quote.Id,
                                User__c=UserInfo.getUserId(),
                                Field__c=fldSetMmber.getLabel(),
                                Original_Value__c=String.valueOf(oldQuotes.get(quote.Id).get(fldSetMmber.getFieldPath())),
                                New_Value__c=String.valueOf(quote.get(fldSetMmber.getFieldPath()))
                            );
                            historyMap.put(fldSetMmber.getFieldPath(),quote.get(fldSetMmber.getFieldPath()));
                            if (quote.id !=null) {//avoid insert for deleted quotes
                                quoteHistoryToCreate.add(quteHis);
                            }
                        }
                    }
                }
            }
        }
        if (!quoteHistoryToCreate.isempty()) {
            insert quoteHistoryToCreate;
        }
    }
}