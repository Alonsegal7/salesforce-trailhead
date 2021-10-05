trigger OnAccountUpdateTrigger on Account (before insert,before update,before delete, after insert, after update, after delete, after undelete) {	
    if (!Globals.CodeOff)
    {
         if (trigger.isBefore)
         {
            if (trigger.isInsert) MondayAccountHelper.HandleBefore(trigger.new, null, 'Insert');
            if (trigger.IsUpdate) MondayAccountHelper.HandleBefore(trigger.new, trigger.oldmap, 'Update');
            if (trigger.isDelete) MondayAccountHelper.HandleBefore(trigger.old, null, 'Delete');
            if (trigger.isUndelete) MondayAccountHelper.HandleBefore(trigger.new, null, 'Undelete');
         }
     
        if (trigger.isAfter)
        {
            if (trigger.isDelete) {
                MondayAccountHelper.HandleAfter(trigger.old, null);  
            } else { 
                MondayAccountHelper.HandleAfter(trigger.new, trigger.oldmap);
            }
        }
    }
    if (Trigger.isBefore) {
        if (trigger.isInsert||trigger.IsUpdate){
            Account_MapRegions.Account_MapRegions (trigger.new,trigger.oldmap);
            Account_SetPartnerCompany.Account_SetPartnerCompany (trigger.new,trigger.oldmap);
            System.debug('Collision state is: '+ Account_Rollup.collisionState);
            if(!Account_Rollup.collisionState)Account_Rollup.Account_Rollup(trigger.new, trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if(Trigger.isUpdate){
            // Partner Commission - start 
            if(PartnerCommissionService.firstRunAccARR || PartnerCommissionService.firstRunAccTrans || PartnerCommissionService.firstRunAccSource || PartnerCommissionService.firstRunAccMerge) {
                PartnerCommissionService commissionHelper = new PartnerCommissionService();
                if(PartnerCommissionService.firstRunAccARR) commissionHelper.partnerCommissionFromARR(Trigger.new, Trigger.oldMap);
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
        }
        if(trigger.isInsert||trigger.IsUpdate){
            Account_SetCompanyDomains.Account_SetCompanyDomains(trigger.new,trigger.oldmap);
            Account_LeadsCapForPartnerCompany.Account_LeadsCapForPartnerCompany(trigger.new,trigger.oldmap);
        }

        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
}