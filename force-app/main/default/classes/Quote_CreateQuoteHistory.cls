public with sharing class Quote_CreateQuoteHistory {
    public static Map<String, Object> historyMap = new Map<String, Object>();
    public static void CreateQuoteHistory(List <Quote> quotes, Map<Id, Quote> oldQuotes) {
        Schema.FieldSet trackChangesFieldSet = Schema.SObjectType.Quote.fieldSets.getMap().get('TrackChangesFields');
        List<Quote_History__c> quoteHistoryToCreate = new List<Quote_History__c>();
        for (Quote quote : quotes) {
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
                    quoteHistoryToCreate.add(quteHis);
                    }
                }
            }
        }
        if (!quoteHistoryToCreate.isempty()) {
            insert quoteHistoryToCreate;
        }
    }
}