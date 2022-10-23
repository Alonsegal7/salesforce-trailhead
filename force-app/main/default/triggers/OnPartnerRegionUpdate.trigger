trigger OnPartnerRegionUpdate on Partner_Region__c (after insert, after update, after delete) {
	if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) {
            LeanData_PoolSettings.partnerRegionMainUserChangedUpdatePoolSetting(trigger.new, trigger.oldMap);
            LeanData_PoolSettings.partnerRegionDailyQuotaChanged(trigger.new, trigger.oldMap);
            CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
        }
    }
}