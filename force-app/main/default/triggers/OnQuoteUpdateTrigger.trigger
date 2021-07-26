trigger OnQuoteUpdateTrigger on Quote (after insert, after update, before update, before insert) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        for(Quote newQuote : Trigger.new){   
            Quote oldQuote = Trigger.oldMap.get(newQuote.Id);
            if (newQuote.Billing_Entity__c != null && oldQuote.Billing_Entity__c != newQuote.Billing_Entity__c)
            { QuoteTriggerHandler.SyncPriorityId(newQuote); }
            ContractService.ConditionOnContractCreation(oldQuote, newQuote);
        }
    }    
    if (Trigger.isAfter && Trigger.isUpdate) {
        if(Quote_Utils.firstRunAfterUpdate){
            Quote_Utils.firstRunAfterUpdate=false;
            QuoteTriggerHandler.handleQuoteArchived(Trigger.new, Trigger.oldMap);
        }
        if (Quote_CallQuoteSync.firstRun) {
            Quote_CallQuoteSync.Quote_CallQuoteSync(Trigger.new,Trigger.oldMap);
        }
        Quote_CreateQuoteHistory.CreateQuoteHistory(Trigger.new,Trigger.oldMap);
    }   
}