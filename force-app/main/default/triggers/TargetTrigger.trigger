trigger TargetTrigger on Target__c (before insert, after insert, before update) {
    TargetsService targetServiceHelper = new TargetsService();
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        targetServiceHelper.setTargetUniqueKeys(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        targetServiceHelper.updateSalesOnTargetCreation(Trigger.new);
    }
}