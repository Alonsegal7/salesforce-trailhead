trigger onOpportunityUpdate on Opportunity (after insert, after update, after delete, before update, before insert) {

    //BEFORE INSERT
    if(Trigger.isBefore && Trigger.isInsert){
        Opportunity_StampsService.run(Trigger.new, Trigger.oldMap);
        OpportunityHelper.beforeInsert(Trigger.new, Trigger.oldMap);
        OpportunityHelper.updateOppType(Trigger.new, Trigger.oldMap);
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.TargetsServiceOnOpps(Trigger.new, Trigger.oldMap);
        Opportunity_GreenBucketLogic.Opportunity_GreenBucketLogic(Trigger.new, Trigger.oldMap);
        Partners_SharingService.newPartnerOppsSharingValidation(Trigger.new);
        Account_RegionalCompanyService.linkOppsToExistingRegionalCompanies(Trigger.new, Trigger.oldMap);
    }
    
    //BEFORE UPDATE
    if(Trigger.isBefore && Trigger.isUpdate){
        Opportunity_LockValidation lockedValidationService = new Opportunity_LockValidation();
        lockedValidationService.runValidation(Trigger.new, Trigger.oldMap);
        Opportunity_StampsService.run(Trigger.new, Trigger.oldMap);
        Handover_ThresholdMapping.linkOpportunityToThresholdFromTrigger(Trigger.new, Trigger.oldMap);
        OpportunityHelper.beforeUpdate(Trigger.new, Trigger.oldMap);
        Opportunity_Calculate_ARR.Opportunity_Calculate_ARR(Trigger.new, Trigger.oldMap);
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.TargetsServiceOnOpps(Trigger.new, Trigger.oldMap);
        OpportunityHelper.updateOppType(Trigger.new, Trigger.oldMap);
        Opportunity_GreenBucketLogic.Opportunity_GreenBucketLogic(Trigger.new, Trigger.oldMap);
        Partners_SharingService.createOpportunityShares_ManualTrigger(Trigger.new);
        Account_RegionalCompanyService.linkOppsToExistingRegionalCompanies(Trigger.new, Trigger.oldMap);
        if(!Opportunity_CoSellSyncService.checkIfSecondaryOppsUpdateAllowed()) lockedValidationService.cosellLockValidation(Trigger.new, Trigger.oldMap);
    }
    
    //AFTER UPDATE
    if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityHelper.markQuotesSigned(Trigger.new, Trigger.oldMap);
        OpportunityHelper.cloneOlisForCoSell(Trigger.new, Trigger.oldMap);
        Partners_SharingService.createOpportunityShares(Trigger.new, Trigger.oldMap);
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.updateTargetOnClosedWonOppChange(Trigger.new, Trigger.oldMap);
        if(PartnerCommissionService.firstRunOpp){
            PartnerCommissionService partnerCommission = new PartnerCommissionService();
            partnerCommission.partnerCommissionFromGbOpp(Trigger.new, Trigger.oldMap);
        }
        Opportunity_CoSellSyncService.syncCoSellOppsClosedWon(Trigger.new, Trigger.oldMap);
    }

    //AFTER INSERT
    if(Trigger.isAfter && Trigger.isInsert){
        Partners_SharingService.createOpportunityShares(Trigger.new, Trigger.oldMap);
        Opportunity_RenewalCreation.updateRenewalStatus(Trigger.new, Trigger.oldMap);
        Handover_ThresholdMapping.recalcHandoverThresholdFromAfterTrigger(Trigger.new);
    }

    //CALLOUT TO BB
    // old callouts to BB - will leave only delete to be fired from trigger 
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (Trigger.old,'Delete',null);
        //if (trigger.isInsert) CalloutHandler.HandleCallout (Trigger.new,'Insert',null);           // moved to BigBrain_CalloutService
        //if (trigger.IsUpdate) CalloutHandler.HandleCallout (Trigger.new,'Update',trigger.oldmap); // moved to BigBrain_CalloutService
    }

    // new callouts to BB - we update Need_Sync_to_BB__c checkbox to true (if it was false)
    // a scheduled job collects the sobjects with Need_Sync_to_BB__c=true and sends callout to BB (async)
    if(Trigger.isInsert || Trigger.isUpdate) {
        BigBrain_CalloutService.markRecordsToSync(Trigger.new, Trigger.oldMap, Trigger.isAfter);
    }
}