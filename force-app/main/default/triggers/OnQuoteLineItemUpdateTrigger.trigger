trigger OnQuoteLineItemUpdateTrigger on QuoteLineItem (after insert, after update, after delete, before update, before insert) {
    if(Trigger.isAfter) {
		  QuoteLineItemHandler.syncQuotes(Trigger.new);
    }
    if(Trigger.isAfter){
      if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
      if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
      if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
  }
}