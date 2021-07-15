trigger PartnerCommissionTrigger on Partner_Commission__c (before insert, before update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        PartnerCommissionService partnerCommissionHelper = new PartnerCommissionService();
        partnerCommissionHelper.checkIfExistingPcDatesOverlap(Trigger.new, Trigger.oldMap);
        PartnerCommissionHelper.updateEndDateOnRenewableFalse(Trigger.new, Trigger.oldMap);
        partnerCommissionHelper.updatePartnerCommissionVersion(Trigger.new, Trigger.oldMap); //has to be last
    }
}