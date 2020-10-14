trigger Subscription_Trigger on Subscription__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if (trigger.isBefore){
        if (trigger.isInsert){
            Subscription_ConnectToContract.Subscription_ConnectToContract(trigger.new,trigger.oldMap);
        }
        if (trigger.isUpdate){}

    }
    
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
}