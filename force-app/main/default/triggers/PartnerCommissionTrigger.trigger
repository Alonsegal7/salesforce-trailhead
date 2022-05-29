trigger PartnerCommissionTrigger on Partner_Commission__c (before insert, before update, after insert) {
    if(Trigger.isInsert || Trigger.isUpdate){
        PartnerCommissionService partnerCommissionHelper = new PartnerCommissionService();
        if(Trigger.isBefore){
            partnerCommissionHelper.checkIfExistingPcDatesOverlap(Trigger.new, Trigger.oldMap);
            partnerCommissionHelper.updateEndDateOnRenewableFalse(Trigger.new, Trigger.oldMap);
            if(Trigger.isInsert) { 
                partnerCommissionHelper.limitPcStartDate(Trigger.new);
                partnerCommissionHelper.updatePartnerCommissionTriggerValidFrom(Trigger.new); 
                PartnerCommissionHelper.setPcCounterAndPreviousPc(Trigger.new);
            }
            partnerCommissionHelper.updatePartnerCommissionVersion(Trigger.new, Trigger.oldMap); //has to be last
        }
        if(Trigger.isAfter && Trigger.isInsert){
            partnerCommissionHelper.setIsLastFalseForManual(Trigger.new);
        }
    }
}