trigger OnQuoteUpdateTrigger on Quote (after insert, after update, before update, before insert) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        for(Quote newQuote : Trigger.new){   
            Quote oldQuote = Trigger.oldMap.get(newQuote.Id);
            if (newQuote.Billing_Entity__c != null && oldQuote.Billing_Entity__c != newQuote.Billing_Entity__c)
            { QuoteTriggerHandler.SyncPriorityId(newQuote); }

            if (oldQuote.Sync_Request_Timestamp_iConduct__c != newQuote.Sync_Request_Timestamp_iConduct__c)
            { IConductService.handleQuoteSync(newQuote.Id); }

            ContractService.ConditionOnContractCreation(oldQuote, newQuote);
        }
    }
    
    QuoteTriggerHandler handler = new QuoteTriggerHandler();
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        if(Quote_Utils.firstRunAfterUpdate){
            Quote_Utils.firstRunAfterUpdate=false;
            QuoteTriggerHandler.handleQuoteArchived(Trigger.new, Trigger.oldMap);
        }
        //handler.syncQuoteLineItems(Trigger.new, Trigger.oldMap);
    }
    
    /*if (Trigger.isAfter && Trigger.isUpdate) {
        for(Quote newQuote : Trigger.new) { 
            if (newQuote.DH_Quote_Status__c == 'Archived')
            { QuoteTriggerHandler.handleQuoteArchived(newQuote.Id); }
        }
    }*/
}