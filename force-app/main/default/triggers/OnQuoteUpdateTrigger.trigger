trigger OnQuoteUpdateTrigger on Quote (after insert, after update, after delete, before update,before insert) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        for(Quote newQuote : Trigger.new){   
            Quote oldQuote = Trigger.oldMap.get(newQuote.Id);
            if (newQuote.Billing_Entity__c != null && oldQuote.Billing_Entity__c != newQuote.Billing_Entity__c)
            { QuoteTriggerHandler.SyncPriorityId(newQuote); }
        }
        QuoteTriggerHandler.connectQuoteToBE(Trigger.new,Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        Quote_CreateQuoteHistory.CreateQuoteHistory(Trigger.new,Trigger.oldMap);
        if(Quote_Utils.firstRunAfterUpdate){
            Quote_Utils.firstRunAfterUpdate=false;
            QuoteTriggerHandler.handleQuoteArchived(Trigger.new, Trigger.oldMap);
        }
        if (Quote_CallQuoteSync.firstRun) {
            Quote_CallQuoteSync.Quote_CallQuoteSync(Trigger.new,Trigger.oldMap);
        }
        ContractEventHandler.SalesOrderContractEvent(Trigger.new,Trigger.oldMap);
        Quote_CloseCorrectionOpp.Quote_CloseCorrectionOpp(Trigger.new, Trigger.oldMap);
    }   
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) {
            CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
            Quote_CallBigBrainPreview.callBigBrainPreviewService(Trigger.new, Trigger.oldMap);
        }

    }
}