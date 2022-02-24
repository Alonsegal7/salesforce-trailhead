trigger onOpportunityUpdate on Opportunity (after insert, after update, after delete, before update, before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        OpportunityHelper.beforeInsert(trigger.new,trigger.oldmap);
        OpportunityHelper.updateOppType(trigger.new,trigger.oldmap);
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.TargetsServiceOnOpps(trigger.new,trigger.oldmap);
        Opportunity_GreenBucketLogic.Opportunity_GreenBucketLogic(trigger.new,trigger.oldmap);
        Partners_SharingService.newPartnerOppsSharingValidation(trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        Partners_SharingService.createOpportunityShares_ManualTrigger(Trigger.new);
        Opportunity_LockValidation lockedValidationService = new Opportunity_LockValidation();
        lockedValidationService.runValidation(Trigger.new, Trigger.oldMap);
        OpportunityHelper.beforeUpdate(Trigger.new, Trigger.oldmap);
        Opportunity_Calculate_ARR.Opportunity_Calculate_ARR(Trigger.new, Trigger.oldmap);
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.TargetsServiceOnOpps(trigger.new,trigger.oldmap);
        OpportunityHelper.updateOppType(trigger.new,trigger.oldmap);
        Opportunity_GreenBucketLogic.Opportunity_GreenBucketLogic(trigger.new,trigger.oldmap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityHelper.afterUpdate(Trigger.new,Trigger.oldmap);
        Partners_SharingService.createOpportunityShares(trigger.new, trigger.oldMap);
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.updateTargetOnClosedWonOppChange(Trigger.new, Trigger.oldMap);
        if(PartnerCommissionService.firstRunOpp){
            PartnerCommissionService partnerCommission = new PartnerCommissionService();
            partnerCommission.partnerCommissionFromGbOpp(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter && Trigger.isInsert){
        Partners_SharingService.createOpportunityShares(trigger.new, trigger.oldMap);
        Opportunity_RenewalCreation.updateRenewalStatus(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
}