public without sharing class QuoteTriggerHandler {
    public void syncQuoteLineItems(List<Quote> newList, Map<Id, Quote> oldMap) {
        List<Id> syncedQuotes = new List<Id>();
        for (Quote q : newList){
            if (q.IsSyncing && !oldMap.get(q.Id).IsSyncing){
                syncedQuotes.add(q.Id);
            }
        } 

        if (syncedQuotes.size() == 0) { return; }
        
        Datetime nexSched = Datetime.now().addSeconds(10);
        String hour = String.valueOf(nexSched.hour());
        String min = String.valueOf(nexSched.minute()); 
        String ss = String.valueOf(nexSched.second());

        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

        System.debug('$$$ nextFireTime: ' + nextFireTime);
        Batch_SyncQuote s = new Batch_SyncQuote(syncedQuotes); 
        System.schedule('Batch_QuoteSync', nextFireTime, s);
    }
    
    /*public static void SyncPriorityId(Quote quote) {
        Billing_Entity__c be = [
            SELECT Id, Priority_Id__c
            FROM Billing_Entity__c
            WHERE Id = :quote.Billing_Entity__c];
        
        quote.Priority_Customer_ID_Text__c = be.Priority_Id__c;
    }*/
    
    /*public static void handleQuoteArchived(Id quoteId) {
        List<QuoteLineItem> quoteLineItems = [SELECT Id, Opportunity_Line_Item_ID__c FROM QuoteLineItem WHERE QuoteId =: quoteId];
        system.debug('Raz Ben Ron HQA quoteLineItems: '+quoteLineItems);
		List<sObject> deleteList1 = new List<sObject>();
        List<sObject> deleteList2 = new List<sObject>();
        List<sObject> deleteList3 = new List<sObject>();
        deleteList1.add([SELECT Id FROM Quote WHERE Id =: quoteId]);
        
        for(QuoteLineItem qli : quoteLineItems){ 
            deleteList2.add(qli);
            deleteList3.add(new OpportunityLineItem(Id = qli.Opportunity_Line_Item_ID__c));
        }
        
        //try { delete deleteList3; } catch(DmlException e) {}//Olis
        //try { delete deleteList2; } catch(DmlException e) {}//QLIs
        system.debug('Raz Ben Ron HQA deleteList1: '+deleteList1);
        delete deleteList1;//Quotes
        //List<Quote> relevantQuotes = [SELECT Id,Billing_Entity__c, Opportunity.Billing_Entity__c FROM quote WHERE Opportunity.Billing_Entity__c != null and Id IN: quotesIds];

    }*/
    //Quote Is Created (document type has been updated to Sales Order), connect the Opp billing entity to the Quote. 
    public static void connectQuoteToBE(List<Quote> newQuotes, Map<Id,Quote> oldQuotes){
        Set<Id> oppIds = new Set<Id>();
        for (Quote newQuote : newQuotes){
            if(newQuote.Document_Type__c != oldQuotes.get(newQuote.Id).Document_Type__c && newQuote.Document_Type__c=='Sales Order')
                oppIds.add(newQuote.OpportunityId);
        }
        if (oppIds.isEmpty()) return;
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Billing_Entity__c FROM Opportunity WHERE Id IN: oppIds]);
        for(Quote quote : newQuotes){
            if (oppMap.containsKey(quote.OpportunityId)){
                quote.Billing_Entity__c = oppMap.get(quote.OpportunityId).Billing_Entity__c;              
            }
        }
    }

    public static void handleQuoteArchived(List<Quote> newQuotes, Map<Id, Quote> oldQuotes) {
        try{
            Set<Id> archivedQuoteIds= new Set<Id>();
            List<QuoteLineItem> qlisToDelete = new List<QuoteLineItem>();
            for(Quote newQuote : newQuotes) { 
                if (newquote.DH_Quote_Status__c!=oldQuotes.get(newQuote.Id).DH_Quote_Status__c&&
                    newQuote.DH_Quote_Status__c == 'Archived' && oldQuotes.get(newQuote.Id).DH_Quote_Status__c != 'Won')
                    archivedQuoteIds.add(newQuote.Id);
            }
            if(archivedQuoteIds.isEmpty())
                return;
        
            for(QuoteLineItem qli : [SELECT Id, Opportunity_Line_Item_ID__c 
                                    FROM QuoteLineItem 
                                    WHERE QuoteId in: archivedQuoteIds]){ 
                qlisToDelete.add(qli);
            }
            list<Quote>relevantQuotes=[select id from Quote where id in: archivedQuoteIds];
            system.debug('Raz Ben Ron HQA relevantQuotes: '+relevantQuotes);
            delete qlisToDelete;
            delete relevantQuotes;
        }catch(Exception e){
            Utilities.sendEmail('Error in QuoteTriggerHandler ',e.getMessage(),new list<String>{label.SystemNotificationsDL});   
        }
    }
}