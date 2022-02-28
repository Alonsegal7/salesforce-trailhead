trigger onThresholdCrietriaUpdate on HO_Threshold_Criteria__c (before insert, before update) {
        Handover_ThresholdMapping.checkThresholdCriteriaValidityOnTrigger(Trigger.new);
}