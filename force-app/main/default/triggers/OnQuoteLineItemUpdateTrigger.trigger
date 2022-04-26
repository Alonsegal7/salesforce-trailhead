trigger OnQuoteLineItemUpdateTrigger on QuoteLineItem (after insert, after update, after delete) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
		  QuoteLineItemHandler.syncQuotes(Trigger.new);
    }
    if(Trigger.isAfter){
      if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
      if (Trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
      if (Trigger.isUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
  }
}