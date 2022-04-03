trigger onOpportunityUpdate on Opportunity (after insert, after update, after delete, before update, before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        OpportunityHelper.beforeInsert(trigger.new,trigger.oldmap);
        OpportunityHelper.updateOppType(trigger.new,trigger.oldmap);
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.TargetsServiceOnOpps(trigger.new,trigger.oldmap);
        Opportunity_GreenBucketLogic.Opportunity_GreenBucketLogic(trigger.new,trigger.oldmap);
        Partners_SharingService.newPartnerOppsSharingValidation(trigger.new);
        Account_RegionalCompanyService.linkOppsToExistingRegionalCompanies(trigger.new,trigger.oldmap);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        Opportunity_LockValidation lockedValidationService = new Opportunity_LockValidation();
        lockedValidationService.cosellLockValidation(Trigger.new, Trigger.oldMap);
        lockedValidationService.runValidation(Trigger.new, Trigger.oldMap);
        Handover_ThresholdMapping.linkOpportunityToThresholdFromTrigger(Trigger.new, Trigger.oldMap);
        OpportunityHelper.beforeUpdate(Trigger.new, Trigger.oldmap);
        Opportunity_Calculate_ARR.Opportunity_Calculate_ARR(Trigger.new, Trigger.oldmap);
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.TargetsServiceOnOpps(trigger.new,trigger.oldmap);
        OpportunityHelper.updateOppType(trigger.new,trigger.oldmap);
        Opportunity_GreenBucketLogic.Opportunity_GreenBucketLogic(trigger.new,trigger.oldmap);
        Partners_SharingService.createOpportunityShares_ManualTrigger(trigger.new);
        Account_RegionalCompanyService.linkOppsToExistingRegionalCompanies(trigger.new,trigger.oldmap);
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
        Opportunity_CoSellSyncService.syncCoSellOppsClosedWon(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        Partners_SharingService.createOpportunityShares(trigger.new, trigger.oldMap);
        Opportunity_RenewalCreation.updateRenewalStatus(Trigger.new, Trigger.oldMap);
        Handover_ThresholdMapping.recalcHandoverThresholdFromAfterTrigger(Trigger.new);
    }

    // old callouts to BB - will leave only delete to be fired from trigger 
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        //if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);           // moved to BigBrain_CalloutService
        //if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap); // moved to BigBrain_CalloutService
    }

    // new callouts to BB - we update Need_Sync_to_BB__c checkbox to true (if it was false)
    // a scheduled job collects the sobjects with Need_Sync_to_BB__c=true and sends callout to BB (async)
    if(Trigger.isInsert || Trigger.isUpdate) {
        BigBrain_CalloutService.markRecordsToSync(Trigger.new, Trigger.oldMap, Trigger.isAfter);
    }
}