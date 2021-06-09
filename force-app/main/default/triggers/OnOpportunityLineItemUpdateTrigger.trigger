trigger OnOpportunityLineItemUpdateTrigger on OpportunityLineItem (after insert, after update, before update, before insert) {
    /*if(Trigger.isInsert && Trigger.isAfter && OpportunityLineItemHandler.isTriggerFire){
        //Set<Id> qliIds = Trigger.newMap.keyset();
        OpportunityLineItemHandler.sync(Trigger.newMap);
    }*/
}