trigger PartnerCommissionModelTrigger on Partner_Commission_Model__c (after insert, before insert, before update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        PartnerCommissionModelService pcmHandler = new PartnerCommissionModelService();
        pcmHandler.checkIfExistingPcmDatesOverlap(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        PartnerCommissionModelService pcmHandler = new PartnerCommissionModelService();
        pcmHandler.updatePartnerAccount(Trigger.new);
    }
}