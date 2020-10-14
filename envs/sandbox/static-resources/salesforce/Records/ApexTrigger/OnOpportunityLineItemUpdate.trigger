trigger OnOpportunityLineItemUpdate on OpportunityLineItem (after insert, after update, after delete) {
    if(Trigger.isInsert && Trigger.isAfter && OpportunityLineItemHandler.isTriggerFire){
        //Set<Id> qliIds = Trigger.newMap.keyset();
        OpportunityLineItemHandler.sync(Trigger.newMap);
    }
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
}