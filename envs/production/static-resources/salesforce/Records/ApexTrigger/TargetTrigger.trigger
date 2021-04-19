trigger TargetTrigger on Target__c (after insert) {
    TargetsService.updateSalesOnTargetCreation(Trigger.new);
}