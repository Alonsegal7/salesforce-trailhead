public class QuoteLineItemHandler {
    public static void syncQuotes(List<QuoteLineItem> newLineItems)
    {
        // get quote ids we need to query for
        Set<Id> quoteIds = new Set<Id>();
        for (QuoteLineItem qli : newLineItems) { 
            if (qli.QuoteId != null) 
                quoteIds.add(qli.QuoteId); }

        // Linking quote line item with Opportunity Line Items
        Map<ID,ID> mapQuoteLineItemSortOrder= returnDefaultLinking(quoteIds);
        system.debug('Raz Ben Ron mapQuoteLineItemSortOrder: '+mapQuoteLineItemSortOrder);
        //Fetch opportunity line item for sync
        Map<ID,OpportunityLineItem> mapOppLineItems=new Map<ID,OpportunityLineItem>();
        for(OpportunityLineItem oli:[select id, ARR__c, Tier__c, Product_Type__c,Plan_Period__c,Seats__c,CC_Claim_Product__c from OpportunityLineItem where Opportunity.SyncedQuoteId in :quoteIds])
        { mapOppLineItems.put(oli.id,oli); }
        
        List<OpportunityLineItem> lstOppotunityToUpdate = new List<OpportunityLineItem>();
        for (QuoteLineItem qli : newLineItems) {
            OpportunityLineItem oli = mapOppLineItems.get(mapQuoteLineItemSortOrder.get(qli.Id));
            system.debug('Raz Ben Ron oli: '+oli);
            if (oli != null&&!oli.CC_Claim_Product__c) {
                oli.ARR__c = qli.ARR__c;
               	oli.Tier__c = qli.Tier__c;
                oli.Product_Type__c = qli.Product_Type__c;
                oli.Plan_Period__c = qli.Plan_Period__c;
                oli.Seats__c = qli.Seats__c;
                lstOppotunityToUpdate.add(oli);
            }
        }
        update lstOppotunityToUpdate;
    }
    
    private static Map<ID,ID> returnDefaultLinking(Set<ID> poIds)
    {
        Map<ID,ID> mapSortOrder= new Map<ID,ID>();
        String query='select id, name, (select id, Opportunity_Line_Item_ID__c from QuoteLineItems) from Quote where id in :poIds';
        List<Quote> lstQuotesWithLineItems=Database.query(query);
        for(Quote q: lstQuotesWithLineItems){
            if(q.QuoteLineItems !=null){
                for(QuoteLineitem qli : q.QuoteLineItems){
                    if(qli.Opportunity_Line_Item_ID__c!=null){
                        //map quote line item id with respective opportunity line item id
                         mapSortOrder.put(qli.Id,ID.valueOF(qli.Opportunity_Line_Item_ID__c));
                    } 
                }
            }
        }
        return mapSortOrder;
    }
}