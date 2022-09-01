trigger OnAccountUpdateTrigger on Account (before insert,before update,before delete, after insert, after update, after delete, after undelete) {	
    if (!Globals.CodeOff)
    {
        if (trigger.isBefore && trigger.isInsert){
            MondayAccountHelper.setCompanyID(trigger.new);

        } else if (trigger.isAfter && trigger.isUpdate){
            MondayAccountHelper.HandleAfter(trigger.new, trigger.oldmap);
        }
    }
    if (Trigger.isBefore) {
        if (trigger.isInsert||trigger.IsUpdate){ //before insert & update
            Account_StampsService.run(Trigger.new,Trigger.oldMap);
            Account_MapRegions.Account_MapRegions (trigger.new,trigger.oldmap);
            Account_Rollup.Account_Rollup_ValueChange(trigger.new, trigger.oldMap);
            Opportunity_RenewalCreation.getProFromActiveContract(Trigger.oldMap, Trigger.new);
            Account_SetPartnerCompany.Account_SetPartnerCompany (trigger.new,trigger.oldmap);
        }
        if(Trigger.isUpdate){ //before update only
            Account_OwnerValidation.companyOwnerValidation(Trigger.new, Trigger.oldMap);
            Partners_SharingService.createAccountShares_ManualTrigger(Trigger.new);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) { 
            Account_SetCompanyDomains.Account_SetCompanyDomains(trigger.new,trigger.oldmap);
            Account_RegionalCompanyService.findOrCreateRegionalCompany(trigger.new, trigger.oldMap);
            Account_RegionalCompanyService.updateRegionalCompanyOnRelatedObjects(trigger.new, trigger.oldMap);
            Account_Rollup.Account_Rollup_ParentChange(trigger.new, trigger.oldMap);
            Partners_SharingService.createAccountShares(trigger.new, trigger.oldMap);
            Partners_SharingService.createAccountSharesOwnerChange(trigger.new, trigger.oldMap);
            Account_LeadsCapForPartnerCompany.Account_LeadsCapForPartnerCompany(trigger.new,trigger.oldmap);
        }
        if(Trigger.isUpdate){
            // Partner Commission - start 
            if(PartnerCommissionService.firstRunAccArr
                || PartnerCommissionService.firstRunAccPlanPeriod
                || PartnerCommissionService.firstRunAccTrans 
                || PartnerCommissionService.firstRunAccSource 
                || PartnerCommissionService.firstRunAccMerge) {
                PartnerCommissionService commissionHelper = new PartnerCommissionService();
                if(PartnerCommissionService.firstRunAccArr) commissionHelper.pcArrChanged(Trigger.new, Trigger.oldMap);
                if(PartnerCommissionService.firstRunAccPlanPeriod) commissionHelper.pcAccPlanPeriod(Trigger.new, Trigger.oldMap);
                if(PartnerCommissionService.firstRunAccTrans) commissionHelper.partnerCommissionFromPartnerTransfer(Trigger.new, Trigger.oldMap);
                if(PartnerCommissionService.firstRunAccSource) commissionHelper.updatePcOnAccountSourceChange(Trigger.new, Trigger.oldMap);
                if(PartnerCommissionService.firstRunAccMerge) commissionHelper.updatePcOnAccountMerge(Trigger.new, Trigger.oldMap);
            }
            if(PartnerCommission_PartnerTermination.firstRun){ // Partner Termination - Set End Date to Active PCs
                PartnerCommission_PartnerTermination partnerTermination = new PartnerCommission_PartnerTermination();
                partnerTermination.updatePcAfterPartnerTermination(Trigger.new, Trigger.oldMap);
            }
            if(PartnerCommissionModel_PartnerSigned.firstRun){ // Partner Signed - Create Gold First Year PCM
                PartnerCommissionModel_PartnerSigned pcmSignedAccount = new PartnerCommissionModel_PartnerSigned();
                pcmSignedAccount.updatePcmForSignedPartners(Trigger.new, Trigger.oldMap);
            }
            // Partner Commission - end
            if(TargetsService.firstRunUpdateTargetsFromAcc){
                TargetsService targetsServ = new TargetsService();
                targetsServ.updateTargetOnAccSourceTypeChange(Trigger.new, Trigger.oldMap);
            } 
            Account_SourceTypeOnOpps.updateSourceTypeOnOpps(Trigger.new, Trigger.oldMap);
            updateMainAccountOnContract.updateMainAccountOnContract(Trigger.new, Trigger.oldMap);
        }

        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        //if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        //if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
    //BB Callout - for account 
    if(Trigger.isInsert || Trigger.isUpdate) {
        BigBrain_CalloutService.markRecordsToSync(Trigger.new, Trigger.oldMap, Trigger.isAfter);
    }

}