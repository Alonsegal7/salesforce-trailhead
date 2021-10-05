public class QuoteLineItemHandler {
    public static void syncQuotes(List<QuoteLineItem> newLineItems){
        try{
            // get quote ids we need to query for
            Set<Id> quoteIds = new Set<Id>();
            for (QuoteLineItem qli : newLineItems) { 
                if (qli.QuoteId != null) 
                    quoteIds.add(qli.QuoteId); }

            // Linking quote line item with Opportunity Line Items
            Map<ID,ID> mapQuoteLineItemSortOrder= returnDefaultLinking(quoteIds);
            system.debug('Raz Ben Ron mapQuoteLineItemSortOrder: '+mapQuoteLineItemSortOrder);
            //Fetch opportunity line item for sync
            Map<Id, OpportunityLineItem> mapOppLineItems = new Map<Id, OpportunityLineItem>();

            for(OpportunityLineItem oli : [SELECT Id, ARR__c, Tier__c, PS_Start_Date__c, Product_Type__c, Plan_Period__c, Seats__c, CC_Claim_Product__c,Co_Sell_Product__c, PS_Hours__c, Expiration_Date__c FROM OpportunityLineItem WHERE Opportunity.SyncedQuoteId IN: quoteIds]){
                mapOppLineItems.put(oli.Id, oli); 
            }
            
            List<OpportunityLineItem> lstOppotunityToUpdate = new List<OpportunityLineItem>();
            for (QuoteLineItem qli : newLineItems) {
                OpportunityLineItem oli = mapOppLineItems.get(mapQuoteLineItemSortOrder.get(qli.Id));
                system.debug('Raz Ben Ron oli: '+oli);
                if (oli != null && !oli.CC_Claim_Product__c && !oli.Co_Sell_Product__c) {
                    oli.ARR__c = qli.ARR__c;
                    oli.Tier__c = qli.Tier__c;
                    oli.Product_Type__c = qli.Product_Type__c;
                    oli.Plan_Period__c = qli.Plan_Period__c;
                    oli.Seats__c = qli.Seats__c;
                    oli.Training_Hours__c = qli.Training_Hours__c;
                    oli.Sales_Order_Primary_Line__c=qli.Sales_Order_Primary_Line__c;
                    oli.Is_Primary__c=qli.Is_Primary__c;
                    oli.Added_Seats__c = qli.Added_Seats__c;
                    oli.PS_Hours__c = qli.Hours__c;
                    oli.Expiration_Date__c = qli.Expiration_Date__c;
                    oli.PS_Start_Date__c = qli.ServiceDate;
                    lstOppotunityToUpdate.add(oli);
                }
            }
            update lstOppotunityToUpdate;
        }catch(Exception e){
            Utilities.sendEmail('Error in QuoteLineItemHandler syncQuotes ',e.getMessage(),new list<String>{label.SystemNotificationsDL});   
        }
    }
    
    private static Map<ID,ID> returnDefaultLinking(Set<ID> poIds){
        Map<Id,Id> mapSortOrder= new Map<Id,Id>();
        String query='select id, name, (select id, Opportunity_Line_Item_ID__c from QuoteLineItems) from Quote where id in :poIds';
        List<Quote> lstQuotesWithLineItems = Database.query(query);
        for(Quote q : lstQuotesWithLineItems){
            if(q.QuoteLineItems != null){
                for(QuoteLineitem qli : q.QuoteLineItems){
                    if(qli.Opportunity_Line_Item_ID__c != null){
                        //map quote line item id with respective opportunity line item id
                         mapSortOrder.put(qli.Id,ID.valueOF(qli.Opportunity_Line_Item_ID__c));
                    } 
                }
            }
        }
        return mapSortOrder;
    }
}