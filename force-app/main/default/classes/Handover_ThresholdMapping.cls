public with sharing class Handover_ThresholdMapping {

    public static Boolean onDemandCalculation = false;
    
    public static void linkOpportunityToThresholdFromTrigger(List<Opportunity> opps, Map<Id, Opportunity> oldOpps) {
        List<Opportunity> relevantOpps = new List<Opportunity>();
        for (Opportunity opp : opps) {
            if (oldOpps == null || //new opportunity
            opp.StageName != oldOpps.get(opp.Id).StageName || //stage changed
            opp.Manual_Trigger__c == 'Calculate HO Thresholds') { //manual trigger
                relevantOpps.add(opp);
                if(opp.Manual_Trigger__c == 'Calculate HO Thresholds') opp.Manual_Trigger__c = ''; //if triggerd manually, clean the manual trigger
            }
        }
        if (!relevantOpps.isEmpty()){
            linkOpportunityToAllThresholds(relevantOpps);
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

    /*
    Method that starts threshold link calculations from all threshold types
    Can be called from: 
    1 linkOpportunityToThresholdFromTrigger (came from trigger) 
    2. directrly for on demand recalculations (e.g. closed won process)
    */
    public static void linkOpportunityToAllThresholds(List<Opportunity> opps) {
        linkOpportunityToAMThreshold(opps);
        linkOpportunityToCSMThreshold(opps);
        linkOpportunityToOBThreshold(opps);
    }

    public static void linkOpportunityToAMThreshold(List<Opportunity> opps) {
        System.debug('Handover_ThresholdMapping linkOpportunityToAMThreshold entered.');
        Map<Id,Opportunity> relevantOppsMap = new Map<Id,Opportunity>(filterRelevantOppsForAMThresholdLink(opps));
        if (relevantOppsMap.isEmpty()) return;
        Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriteriasMap = new Map<Id,List<HO_Threshold_Criteria__c>>(getRelevantThresholdsWithThresholdCriterias('AM'));
        if (thresholdsWithCriteriasMap.isEmpty()) return;
        for (Opportunity opp : relevantOppsMap.values()) {
            opp.HO_Threshold_AM__c = null;
        }
        compareThresholdsToOppValues(relevantOppsMap,thresholdsWithCriteriasMap,true);
    }
    
    public static Map<Id,Opportunity> filterRelevantOppsForAMThresholdLink (List<Opportunity> opps) {
        Id oppInternalOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        Map<Id,Opportunity> relevantOppsMap = new Map<Id,Opportunity>();
        for (Opportunity opp : opps) {
            if (opp.Owner_s_Office_Region__c != null && opp.Company_Employees__c != null && opp.RecordTypeId == oppInternalOppRtId) { //internal opp with the relevant fields
                relevantOppsMap.put(opp.Id, opp);
            }
        }
        System.debug('Handover_ThresholdMapping linkOpportunityToAMThreshold relevant opps count: '+ relevantOppsMap.keySet().size());
        return relevantOppsMap;
    }
    
    public static void linkOpportunityToCSMThreshold(List<Opportunity> opps) {
        System.debug('Handover_ThresholdMapping linkOpportunityToCSMThreshold entered.');
        Map<Id,Opportunity> relevantOppsMap = new Map<Id,Opportunity>(filterRelevantOppsForCSMThresholdLink(opps));
        if (relevantOppsMap.isEmpty()) return;
        Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriteriasMap = new Map<Id,List<HO_Threshold_Criteria__c>>(getRelevantThresholdsWithThresholdCriterias('CSM'));
        if (thresholdsWithCriteriasMap.isEmpty()) return;
        for (Opportunity opp : relevantOppsMap.values()) {
            opp.HO_Threshold_CSM__c = null;
        }
        compareThresholdsToOppValues(relevantOppsMap,thresholdsWithCriteriasMap,true);
    }
    
    public static Map<Id,Opportunity> filterRelevantOppsForCSMThresholdLink (List<Opportunity> opps) {
        Id oppInternalOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        Map<Id,Opportunity> relevantOppsMap = new Map<Id,Opportunity>();
        for (Opportunity opp : opps) {
            if (opp.RecordTypeId == oppInternalOppRtId) { //internal opp with the relevant fields
                relevantOppsMap.put(opp.Id, opp);
            }
        }
        System.debug('Handover_ThresholdMapping linkOpportunityToCSMThreshold relevant opps count: '+ relevantOppsMap.keySet().size());
        return relevantOppsMap;
    }

    public static void linkOpportunityToOBThreshold(List<Opportunity> opps) {
        System.debug('Handover_ThresholdMapping linkOpportunityToOBThreshold entered.');
        Map<Id,Opportunity> relevantOppsMap = new Map<Id,Opportunity>(filterRelevantOppsForOBThresholdLink(opps));
        if (relevantOppsMap.isEmpty()) return;
        Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriteriasMap = new Map<Id,List<HO_Threshold_Criteria__c>>(getRelevantThresholdsWithThresholdCriterias('Onboarding'));
        if (thresholdsWithCriteriasMap.isEmpty()) return;
        for (Opportunity opp : relevantOppsMap.values()) {
            opp.HO_Threshold_Onboarding__c = null;
        }
        compareThresholdsToOppValues(relevantOppsMap,thresholdsWithCriteriasMap,true);
    }
    
    public static Map<Id,Opportunity> filterRelevantOppsForOBThresholdLink (List<Opportunity> opps) {
        Id oppInternalOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        Map<Id,Opportunity> relevantOppsMap = new Map<Id,Opportunity>();
        for (Opportunity opp : opps) {
            if ((opp.Onboarding_Hours__c != null) && opp.RecordTypeId == oppInternalOppRtId) {//internal opp with the relevant fields
                relevantOppsMap.put(opp.Id, opp);
            }
        }
        System.debug('Handover_ThresholdMapping filterRelevantOppsForOBThresholdLink relevant opps count: '+ relevantOppsMap.keySet().size());
        return relevantOppsMap;
    }
    
    //returns the relevant thresholds and criterias based on the type of threshold (AM/CSM/Onboarding/PS)
    public static Map<Id,List<HO_Threshold_Criteria__c>> getRelevantThresholdsWithThresholdCriterias (String thresholdType) {
        System.debug('Handover_ThresholdMapping getRelevantThresholdsWithThresholdCriterias entered.');
        Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriterias = new Map<Id,List<HO_Threshold_Criteria__c>>();
        List<HO_Threshold_Criteria__c> relevantThCriterias = new List<HO_Threshold_Criteria__c>();
        try {
            relevantThCriterias = [SELECT Id, HO_Threshold__c, Criteria_Name__c, Target_Field_API_Name__c, Value__c, Operator__c FROM HO_Threshold_Criteria__c WHERE Is_Active__c = TRUE AND Threshold_Type__c = :thresholdType AND Relevant_for_Link__c = true];
            System.debug('Handover_ThresholdMapping getRelevantThresholdsWithThresholdCriterias found: '+relevantThCriterias.size()+ ' threshold criterias from type: '+thresholdType);
            System.debug('Handover_ThresholdMapping getRelevantThresholdsWithThresholdCriterias thresholds list: '+relevantThCriterias);
        } catch (Exception e) {
            System.debug('Handover_ThresholdMapping getRelevantThresholdsWithThresholdCriterias Faild to retrive relevantThCriterias: ' + e.getMessage());
        }
        for (HO_Threshold_Criteria__c thCr : relevantThCriterias) {
            if (thresholdsWithCriterias.containsKey(thCr.HO_Threshold__c)) {
                thresholdsWithCriterias.get(thCr.HO_Threshold__c).add(thCr);
            }
            else {
                thresholdsWithCriterias.put(thCr.HO_Threshold__c,new List<HO_Threshold_Criteria__c>{thCr});
            }   
        }
        System.debug('Handover_ThresholdMapping getRelevantThresholdsWithThresholdCriterias found ' + thresholdsWithCriterias.size() + ' relevant thresholds and ' + relevantThCriterias.size() + ' threshold criterias in total');
        return thresholdsWithCriterias;
    }
    
    // finds an opp-threshold match. (1) when used for link - will connect the opp to the threshold (2) when used for pass, will return true/false. For link use isLink = true, for pass- use isLink = false
    public static Boolean compareThresholdsToOppValues(Map<Id,Opportunity> relevantOppsMap,Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriteriasMap, Boolean isLink) {
        System.debug('Handover_ThresholdMapping compareThresholdsToOppValues entered. ' + relevantOppsMap.keySet().size() + ' opps and ' + thresholdsWithCriteriasMap.keySet().size() + ' thresholds');
        //validate that all threshold criteria fields actually exist on the opp
        for(List<HO_Threshold_Criteria__c> thCrList: thresholdsWithCriteriasMap.values()) {
            for(HO_Threshold_Criteria__c thCr: thCrList) {
                if(!checkThresholdCriteriaFieldsValidity(thCr)){
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - invalid fields detacted in threshold criterias');
                    return false;
                }
            }
        }
        Set<Id> thIdSet = thresholdsWithCriteriasMap.keySet();
        Map<Id,HO_Threshold__c> relevantThresholdsMap = new Map<Id,HO_Threshold__c>([SELECT Id, Type__c FROM HO_Threshold__c WHERE Id IN: thIdSet]);
        Boolean isMatch;
        for (Id oppId : relevantOppsMap.keySet()) {
            // for (Id thId : relevantThresholdsMap.keySet()) {
            for (Id thId : thIdSet) {
                System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - comparing threshold: '+ thId + ' to opp: ' + oppId);
                isMatch = true;
                for (HO_Threshold_Criteria__c thCr : thresholdsWithCriteriasMap.get(thId)) {
                    String thCrFieldValue = string.valueof(thCr.Value__c);
                    String oppFieldValue = string.valueof(relevantOppsMap.get(oppId).get(thCr.Target_Field_API_Name__c));
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - value of opp: '+ oppId + ' for target field: ' + thCr.Target_Field_API_Name__c + ' is: ' + oppFieldValue);
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - value of threshold: '+ thId + ' for target field: ' + thCr.Criteria_Name__c + ' is: ' + thCrFieldValue);
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - value of the operator is: '+ thCr.Operator__c);
                    if (thCrFieldValue == null || oppFieldValue == null) {
                        if (thCr.Operator__c == 'equal' && (thCrFieldValue == null)) {
                            if(oppFieldValue == null || oppFieldValue == ' ' || oppFieldValue == '') {
                                System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - Null value detected, skipping criteria');
                                continue;
                            }
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
                        when null {
                            System.debug('Handover_ThresholdMapping compareThresholdsToOppValues Faild to validate criteria - switch part operator is null');
                        }
                        when else {
                            System.debug('Handover_ThresholdMapping compareThresholdsToOppValues Faild to validate criteria - switch part is undefined operator: '+thCr.Operator__c);
                        }
                    }
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues isMatch status: ' + isMatch);
                    if (!isMatch) {break;}
                }
                if (isMatch) {
                    if (isLink) {
                        if((relevantThresholdsMap.get(thId)).Type__c == 'AM') {
                            relevantOppsMap.get(oppId).HO_Threshold_AM__c = thId;
                        }
                        if((relevantThresholdsMap.get(thId)).Type__c == 'CSM') {
                            relevantOppsMap.get(oppId).HO_Threshold_CSM__c = thId;
                        }
                        if((relevantThresholdsMap.get(thId)).Type__c == 'Onboarding') {
                            relevantOppsMap.get(oppId).HO_Threshold_Onboarding__c = thId;
                        }
                    }
                    System.debug('Handover_ThresholdMapping compareThresholdsToOppValues - found link match for opp: '+ oppId + ' to threshold: ' + thId);
                    break;                        
                }
            }
        }
        if (onDemandCalculation) {
            update relevantOppsMap.values();
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

    public static String getRelevantFieldsFromOpportunity(Set<Id> thresholdsToCheck){
        Set<String> fieldsList = new Set<String>();
        for (HO_Threshold_Criteria__c thCr : [SELECT Target_Field_API_Name__c FROM HO_Threshold_Criteria__c WHERE Is_Active__c = TRUE]) {
            fieldsList.add(thCr.Target_Field_API_Name__c);
            System.debug('Field: '+thCr.Target_Field_API_Name__c);
        }
        String fieldsString = 'Id, RecordTypeId,';
        for (String st : fieldsList) {
            fieldsString += st + ',';
        }
        fieldsString = fieldsString.substring(0,fieldsString.length()-1);
        String query = 'SELECT ' +fieldsString+ ' FROM Opportunity LIMIT 1';
        System.debug(query);
        try {
            Database.query(query);
        } catch (Exception e) {
            System.debug('Handover_ThresholdMapping getRelevantFieldsFromOpportunity Faild to retrive query: ' + e.getMessage());
        }
        return fieldsString;
    }
    
    public static Boolean checkIfOppPassedThreshold(Id inputOppId, String thresholdType) {
        System.debug('Handover_ThresholdMapping checkIfOppPassedThreshold entered. opps id is ' + inputOppId);
        Opportunity relevantOppRaw = [SELECT Id, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Id = :inputOppId];
        Id oppTh;
        //determine which type of thresold is checked
        if (thresholdType == 'AM' && relevantOppRaw.HO_Threshold_AM__c != null) {
            oppTh = relevantOppRaw.HO_Threshold_AM__c;
        }
        if (thresholdType == 'CSM' && relevantOppRaw.HO_Threshold_CSM__c != null) {
            oppTh = relevantOppRaw.HO_Threshold_CSM__c;
        }
        if (thresholdType == 'Onboarding' && relevantOppRaw.HO_Threshold_Onboarding__c != null) {
            oppTh = relevantOppRaw.HO_Threshold_Onboarding__c;
        }
        if (oppTh == null) {
            return false;
        }
        //check first if the threshold is marked with 'Always Pass' 
        HO_Threshold__c currentTh = [SELECT Id, Always_Pass__c FROM HO_Threshold__c WHERE Id = :oppTh];
        if (currentTh.Always_Pass__c) {
            return true;
        }
        Set<Id> thresholdsSet = new Set<Id>{oppTh};
        //find the fields used in the threshold and query them
        String relevantFields = getRelevantFieldsFromOpportunity(thresholdsSet);
        System.debug('relevantFields: '+relevantFields);
        String query = 'SELECT ' +relevantFields+ ' FROM Opportunity WHERE Id =: inputOppId';
        System.debug('query: '+query);
        Opportunity relevantOpp = Database.query(query);
        if (oppTh == null){
            System.debug('Handover_ThresholdMapping checkIfOppPassedThreshold null threshold detected');
            return false;
        } 
        System.debug('Handover_ThresholdMapping checkIfOppPassedThreshold current threshold is ' + oppTh);
        //create a map of opps and map of thresholds with their threshold criteria- to be sent to the compare method 
        Map<Id,Opportunity> relevantOppsMap = new Map<Id,Opportunity>();
        relevantOppsMap.put(inputOppId, relevantOpp);
        List<HO_Threshold_Criteria__c> relevantThCriterias = new List<HO_Threshold_Criteria__c>([SELECT Id, HO_Threshold__c, Criteria_Name__c, Target_Field_API_Name__c, Value__c, Operator__c FROM HO_Threshold_Criteria__c WHERE Is_Active__c = TRUE AND HO_Threshold__c = :oppTh AND Relevant_for_Pass__c = true]);
        if (relevantThCriterias.isEmpty()) {return false;}
        Map<Id,List<HO_Threshold_Criteria__c>> thresholdsWithCriteriasMap = new Map<Id,List<HO_Threshold_Criteria__c>>();
        thresholdsWithCriteriasMap.put(oppTh,relevantThCriterias);
        System.debug('Handover_ThresholdMapping checkIfOppPassedThreshold sending to compareThresholdsToOppValues. ' + relevantOppsMap.keySet().size() + ' opps and ' + thresholdsWithCriteriasMap.keySet().size() + ' thresholds');
        //do the actual compare
        return compareThresholdsToOppValues(relevantOppsMap,thresholdsWithCriteriasMap,false);
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