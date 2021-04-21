trigger OnQuoteLineItemUpdateTrigger on QuoteLineItem (after insert, after update, before update, before insert) {
    if (Trigger.isAfter) {
		QuoteLineItemHandler.syncQuotes(Trigger.new);
    }
}