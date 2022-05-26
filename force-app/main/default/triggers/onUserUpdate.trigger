trigger onUserUpdate on User (after insert, after update, after delete) {

    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            Partners_SharingService.handleEligibleUsersUserRole(Trigger.new, Trigger.oldMap);
            User_CommunityPublicGroupService.addRemoved_PartnerCommunityUsersPG(Trigger.new, Trigger.oldMap);
        }
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
}