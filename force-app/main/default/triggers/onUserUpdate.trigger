trigger onUserUpdate on User (after insert, after update, after delete, before insert, before update, before delete) {
    if(Trigger.isAfter){
        if (Trigger.isDelete) {
            CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        }

        if (trigger.isInsert) {
            CalloutHandler.HandleCallout (trigger.new,'Insert',null);
            User_CreateLeadsCap.User_CreateLeadsCap(trigger.new, trigger.oldMap);
        }

        if (trigger.IsUpdate) {
            CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
            if(Account_UpdateCsmManager.firstRun){
                Account_UpdateCsmManager.firstRun = false;
                Account_UpdateCsmManager updateCsmManagerHandler = new Account_UpdateCsmManager();
                updateCsmManagerHandler.checkForCmsManagerUpdate(trigger.new, trigger.oldMap);
                User_CreateLeadsCap.User_CreateLeadsCap(trigger.new, trigger.oldMap);
            }
        }
    }
    /*if(Trigger.isBefore){
        if (trigger.isInsert||trigger.IsUpdate) {
            User_CreateLeadsCap.User_CreateLeadsCap(trigger.new, trigger.oldMap);
        }

    }*/
}