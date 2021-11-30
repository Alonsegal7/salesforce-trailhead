trigger CommissionCommitmentTrigger on Commission_Commitment__c (before insert, before update, after update, after insert, after delete) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        CommissionCommitmentCollectionService helper = new CommissionCommitmentCollectionService();
        helper.setMondayAcc(Trigger.new, Trigger.oldMap);
        helper.setOpportunity(Trigger.new, Trigger.oldMap);
        helper.setPartnerCommissionReport(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter){
        Partners_SharingService.createCommitmentsShares(Trigger.new, Trigger.oldMap);
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
}