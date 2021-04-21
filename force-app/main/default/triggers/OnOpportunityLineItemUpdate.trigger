trigger OnOpportunityLineItemUpdate on OpportunityLineItem (after insert, after update, after delete, before delete) {
    if(Trigger.isInsert && Trigger.isAfter && OpportunityLineItemHandler.isTriggerFire){
        //Set<Id> qliIds = Trigger.newMap.keyset();
        OpportunityLineItemHandler.sync(Trigger.newMap);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        OpportunityLineItemHandler.restoreCreditCardOlis(Trigger.oldMap);
    }
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
}