trigger onUserUpdate on User (after insert, after update, after delete) {
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) {
            CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
            if(Account_UpdateCsmManager.firstRun){
                Account_UpdateCsmManager.firstRun = false;
                Account_UpdateCsmManager updateCsmManagerHandler = new Account_UpdateCsmManager();
                updateCsmManagerHandler.checkForCmsManagerUpdate(trigger.new, trigger.oldMap);
            }
        }
    }
}