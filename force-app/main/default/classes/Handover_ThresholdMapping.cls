public without sharing class Handover_ThresholdMapping {

    public static void linkOpportunityToThresholdFromTrigger(List<Opportunity> opps, Map<Id, Opportunity> oldOpps) {
        try {
            List<Opportunity> relevantOpps = new List<Opportunity>();
            Id oppInternalOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
            for (Opportunity opp : opps) {
                if (opp.RecordTypeId == oppInternalOppRtId && (opp.Manual_Trigger__c == 'Calculate HO Thresholds' || opp.StageName != oldOpps.get(opp.Id).StageName || oldOpps == null)) { //new oppty or stage changed or manual trigger
                    relevantOpps.add(opp);
                    if(opp.Manual_Trigger__c == 'Calculate HO Thresholds') opp.Manual_Trigger__c = '';
                }
            }
            if (!relevantOpps.isEmpty()){
                Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriterias = getThresholdsWithThresholdCriterias();
                linkOppsToThresholds(relevantOpps, thresholdsWithCriterias);
            }
        } catch(Exception e){
            Utilities.sendDebugEmail('Error in Handover_ThresholdMapping ',e,e.getMessage());    
        }
    }

    public static void recalcHandoverThresholdFromAfterTrigger(List<Opportunity> opps){
        System.debug('Entered recalcHandoverThresholdFromAfterTrigger');
        List<Opportunity> updatedOpps = new List<Opportunity>();
        for (Opportunity opp : opps) {
            updatedOpps.add(new Opportunity(Id = opp.Id, Manual_Trigger__c = 'Calculate HO Thresholds'));
        }
        update updatedOpps;
    }

    public static Map<Id,List<HO_Threshold_Criteria__c>> getThresholdsWithThresholdCriterias() {
        System.debug('Handover_ThresholdMapping getRelevantThresholdsWithThresholdCriterias entered.');
        Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriterias = new Map<Id,List<HO_Threshold_Criteria__c>>();
        List<HO_Threshold_Criteria__c> relevantThCriterias = new List<HO_Threshold_Criteria__c>();
        relevantThCriterias = [SELECT Id, HO_Threshold__c, Criteria_Name__c, Target_Field_API_Name__c, Value__c, Operator__c, Relevant_for_Pass__c, Relevant_for_Link__c FROM HO_Threshold_Criteria__c WHERE Is_Active__c = TRUE AND HO_Threshold__r.Active__c = TRUE];
        if (relevantThCriterias != null) {
            for (HO_Threshold_Criteria__c thCr : relevantThCriterias) {
                if (thresholdsWithCriterias.containsKey(thCr.HO_Threshold__c)) {
                    thresholdsWithCriterias.get(thCr.HO_Threshold__c).add(thCr);
                }
                else {
                    thresholdsWithCriterias.put(thCr.HO_Threshold__c,new List<HO_Threshold_Criteria__c>{thCr});
                }   
            }
        }
        System.debug('Handover_ThresholdMapping getRelevantThresholdsWithThresholdCriterias found ' + thresholdsWithCriterias.size() + ' relevant thresholds and ' + relevantThCriterias.size() + ' threshold criterias in total');
        return thresholdsWithCriterias;
    }

    public static void linkOppsToThresholds(List<Opportunity> relevantOpps, Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriterias) {
        Map<Id, HO_Threshold__c> thresholdsMap = new Map<Id, HO_Threshold__c>([SELECT Id, Type__c, Always_Pass__c FROM HO_Threshold__c WHERE Id IN: thresholdsWithCriterias.keySet() AND Active__c = TRUE]);
        Boolean isMatch, isPass;
        String thresholdFieldName, thresholdPassFieldName;
        for (Opportunity opp : relevantOpps) {
            isMatch = isPass = false;
            opp.HO_Threshold_AM__c = opp.HO_Threshold_CSM__c = opp.HO_Threshold_Onboarding__c = null;
            opp.Passed_AM_Threshold__c = opp.Passed_CSM_Threshold__c = opp.Passed_Onboarding_Threshold__c = false;
            for (HO_Threshold__c th : thresholdsMap.values()) {
                isMatch = checkMatch(opp, th, thresholdsWithCriterias.get(th.Id), 'isLink');
                if (isMatch) {
                    thresholdFieldName = th.Type__c == 'AM' ? 'HO_Threshold_AM__c' : th.Type__c == 'CSM' ? 'HO_Threshold_CSM__c' : th.Type__c == 'Onboarding' ? 'HO_Threshold_Onboarding__c' : null;
                    opp.put(thresholdFieldName, th.Id);
                    //once matched, check if passed the threshold
                    thresholdPassFieldName = th.Type__c == 'AM' ? 'Passed_AM_Threshold__c' : th.Type__c == 'CSM' ? 'Passed_CSM_Threshold__c' : th.Type__c == 'Onboarding' ? 'Passed_Onboarding_Threshold__c' : null;
                    if(th.Always_Pass__c || checkMatch(opp, th, thresholdsWithCriterias.get(th.Id), 'isPass')) {
                        opp.put(thresholdPassFieldName, true);    
                    }
                    else {
                        opp.put(thresholdPassFieldName, false);
                    }
                }
            }
        }
    }

    //checks if a certain opportunity matches a threshold criterias, will recieve 'isLink' or 'isPass' as typeOfMatch
    public static Boolean checkMatch(Opportunity opp, HO_Threshold__c th, List<HO_Threshold_Criteria__c> criteriaList, String typeOfMatch) {
        System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - comparing threshold: '+ th.Id + ' to opp: ' + opp.Id);
        List<HO_Threshold_Criteria__c> filteredScope = new List<HO_Threshold_Criteria__c>();
        for (HO_Threshold_Criteria__c thCr : criteriaList) {
            if (typeOfMatch == 'isLink' && thCr.Relevant_for_Link__c) {
                filteredScope.add(thCr);
            }
            else if (typeOfMatch == 'isPass' && thCr.Relevant_for_Pass__c) {
                filteredScope.add(thCr);
            }
        }
        if (filteredScope.isempty()) return false;
        Boolean isMatch = true;
        for (HO_Threshold_Criteria__c thCr : filteredScope) {
            String thCrFieldValue = string.valueof(thCr.Value__c);
            String oppFieldValue = string.valueof(opp.get(thCr.Target_Field_API_Name__c));
            System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - value of opp: '+ opp.Id + ' for target field: ' + thCr.Target_Field_API_Name__c + ' is: ' + oppFieldValue);
            System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - value of threshold: '+ th.Id + ' for target field: ' + thCr.Criteria_Name__c + ' is: ' + thCrFieldValue + 'value of the operator is: '+ thCr.Operator__c);
            if (thCrFieldValue == null || oppFieldValue == null) {
                if (thCr.Operator__c == 'equal' && (thCrFieldValue == null)) {
                    if(oppFieldValue == null || oppFieldValue == ' ' || oppFieldValue == '') {
                        System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - Null value detected, passing criteria');
                        continue;
                    }
                }
                if (thCr.Operator__c == 'notequal' && oppFieldValue == null && thCrFieldValue != null) {
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - not Null value detected, passing criteria');
                    continue;    
                }
                else {
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - Null value detected, failing criteria');
                    isMatch = false;
                    break;
                }
            }
            switch on thCr.Operator__c {
                when 'greaterthen' {
                    if(integer.valueof(thCrFieldValue) >= integer.valueof(oppFieldValue)) {isMatch = false;}
                }
                when 'lessthen' {
                    if(integer.valueof(thCrFieldValue) <= integer.valueof(oppFieldValue)) {isMatch = false;}
                }
                when 'equal' {
                    if(thCrFieldValue != oppFieldValue) {isMatch = false;}
                }
                when 'notequal' {
                    if(thCrFieldValue == oppFieldValue) {isMatch = false;}
                }
                when 'one of' {
                    System.debug('thCrFieldValue: '+thCrFieldValue);
                    if(!thCrFieldValue.contains(oppFieldValue)) {isMatch = false;}
                }
                when else {
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues Faild to validate criteria - switch part is null or undefined operator: '+thCr.Operator__c);
                    isMatch = false;
                }
            }
            System.debug('Handover_ThresholdMapping compareThresholdsToOppValues isMatch status: ' + isMatch);
            if (!isMatch) {break;}   
        }
        System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - pass result is: '+isMatch);
        return isMatch;
    }

    @AuraEnabled(Cacheable=false)
    public static void checkThresholdCriteriaValidityOnTrigger(List<HO_Threshold_Criteria__c> thCrToCheck){
        for (HO_Threshold_Criteria__c thCr : thCrToCheck) {
            if (!checkThresholdCriteriaFieldsValidity(thCr)) {
                thCr.addError('Field names mismatch - make sure that target opportunity field API name exists on the opportunity');
            }
        }
    }
    
    @AuraEnabled(Cacheable=false)
    public static Boolean checkThresholdCriteriaFieldsValidity(HO_Threshold_Criteria__c thCrToCheck) {
        System.debug('checkThresholdCriteriaFieldsValidity thCrToCheck: '+thCrToCheck);
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> oppFieldMap = schemaMap.get('Opportunity').getDescribe().fields.getMap();    
        Set<String> oppFields = oppFieldMap.keySet();
        if (!(oppFields.contains((thCrToCheck.Target_Field_API_Name__c).toLowercase()))) {
            System.debug('checkThresholdCriteriaFieldsValidity returned false');
            return false;
        }
        return true;
    }

    @AuraEnabled(Cacheable=false)
    public static List<HO_Threshold_Criteria__c> findExistingThCr(Id thId) {
        List<HO_Threshold_Criteria__c> thCrList = new List<HO_Threshold_Criteria__c>([SELECT Id, Name, HO_Threshold__c, Criteria_Name__c, Target_Field_API_Name__c, Value__c, Operator__c, Relevant_for_Pass__c, Relevant_for_Link__c FROM HO_Threshold_Criteria__c WHERE Is_Active__c = TRUE AND HO_Threshold__c = :thId]); 
        System.debug('thId: '+thId);
        System.debug('thCrList: '+thCrList);
        return thCrList;
    }
    
    @AuraEnabled(Cacheable=false)
    public static List<HO_Threshold_Criteria__c> updateThCr(List<HO_Threshold_Criteria__c> finalThCr, Id thId){
        
        if (!finalThCr.isempty()) {
            try {
                update finalThCr;
            } 
            catch(Exception e) {
                System.debug('Message: ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        }
        List<HO_Threshold_Criteria__c> updatedThCrList = new List<HO_Threshold_Criteria__c>(findExistingThCr(thId));
        return updatedThCrList;
    }
}