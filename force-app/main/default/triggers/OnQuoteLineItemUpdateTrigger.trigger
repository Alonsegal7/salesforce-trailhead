trigger OnQuoteLineItemUpdateTrigger on QuoteLineItem (after insert, after update, before update, before insert) {
    if (Trigger.isAfter) {
      system.debug('### Tal - in after quote');
		QuoteLineItemHandler.syncQuotes(Trigger.new);
    }
}