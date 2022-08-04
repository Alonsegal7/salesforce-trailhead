trigger OnLeadUpdateTrigger on Lead (after insert, after update, after delete, before insert, before update) {
    
    if(Trigger.isBefore){
        if (Trigger.isUpdate || Trigger.isInsert){
            Lead_MapRegions.Lead_MapRegions(Trigger.new,Trigger.oldMap);
            Account_RegionalCompanyService.linkLeadsToExistingRegionalCompanies(Trigger.new,Trigger.oldMap);
            Lead_SetPartnerCompany.Lead_SetPartnerCompany(Trigger.new,Trigger.oldMap);
            Lead_StampsService.run(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            Partners_SharingService.createLeadShares_ManualTrigger(Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isUpdate || Trigger.isInsert){
            Partners_SharingService.createLeadShares(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            Lead_ConvertActions.postConvertActions(Trigger.new,Trigger.oldMap);
            Lead_RelatedTasks.markTasksCompleted(Trigger.new,Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isDelete) CalloutHandler.HandleCallout (Trigger.old,'Delete',null);
        if (Trigger.isInsert) CalloutHandler.HandleCallout (Trigger.new,'Insert',null);
        if (Trigger.IsUpdate) CalloutHandler.HandleCallout (Trigger.new,'Update',Trigger.oldMap);
    }
}