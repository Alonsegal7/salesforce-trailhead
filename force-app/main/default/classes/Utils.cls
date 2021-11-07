/*************************************************************************
    * Created by: Synebo/ Anastasia Sapihora
    * Created date: 28 January 2020
    * Description: Apex class for util methods
************************************************************************/

public without sharing class Utils {

    public static Map<Id, SObject> recursiveOldMap = new Map<Id, SObject>();

    public static List<SObject> getChangedObjects(List<Schema.SObjectField> fieldsToCheck,
                                                  List<SObject> newObjects, Map<Id, SObject> oldObjects) {
        if (oldObjects == null || oldObjects.isEmpty()) {
            return newObjects;
        }

        List<SObject> changedObjects = new List<SObject>();
        for (SObject obj : newObjects) {
            Boolean isChanged = false;

            SObject oldObject = Trigger.isExecuting && Trigger.isBefore &&
                    recursiveOldMap.containsKey(obj.Id) ? recursiveOldMap.get(obj.Id) : (oldObjects.containsKey(obj.Id) ? oldObjects.get(obj.Id) : null);

            if (oldObject != null && obj.Id != null) {
                for (Schema.SObjectField fieldName : fieldsToCheck) {
                    if (obj.get(fieldName) != oldObject.get(fieldName)) {
                        isChanged = true;
                        break;
                    }
                }
            }

            if (isChanged) {
                changedObjects.add(obj);
            }
        }
        return changedObjects;
    }

    public static List<Schema.SObjectField> fetchFieldsFromFieldSet(Schema.FieldSet fieldSet) {
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
        for (Schema.FieldSetMember fieldSetMember_i : fieldSet.getFields()) {
            fieldList.add(fieldSetMember_i.getSObjectField());
        }
        return fieldList;
    }

    public static void updateRecursiveOldMap(Map<Id, SObject> objects) {
        if (objects == null) {
            return;
        }
        for (SObject sObj : objects.values()) {
            Utils.recursiveOldMap.put(sObj.Id, objects.get(sObj.Id));
        }
    }

    public static String obtainNameField(SObjectType sObjType) {
        Map<String,Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
        for (String field_i : fieldMap.keySet()) {
            if ( fieldMap.get(field_i).getDescribe().isNameField() ) {
                return String.valueOf(fieldMap.get(field_i));
            }
        }
        return '';
    }

    public static List<String> getAllObjectFieldsApiNames(String objectApiName) {
        List<String> objectFields = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = ((SObject) Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().fields.getMap();
        if (fieldMap != null) {
            for (Schema.SObjectField fieldObject : fieldMap.values()) {
                objectFields.add(fieldObject.getDescribe().getName());
            }
        }
        return objectFields;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static List<PicklistValue> buildPickListOptionsBySchema(SObjectType objectType, SObjectField picklistObjectField, Boolean addEmptyValue) {
        List<PicklistValue> pickList = new List<PicklistValue>();

        Map<String,Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();

        if (fieldMap.containsKey(picklistObjectField.getDescribe().getName().toLowerCase())) {
            Schema.DescribeFieldResult fieldResult = fieldMap.get(picklistObjectField.getDescribe().getName().toLowerCase()).getDescribe();
            List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

            if (addEmptyValue) {
                pickList.add(new PicklistValue('--None--', ''));
            }

            if (!picklistValueList.isEmpty()) {
                for (Schema.PicklistEntry picklistEntry_i : picklistValueList) {
                    pickList.add(new PicklistValue(picklistEntry_i.getLabel(), picklistEntry_i.getValue()));
                }
            }
        }
        return pickList;
    }

    public class PicklistValue {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        public PicklistValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    //method used to process DML operation results, will iterate through the result and will log errors
    public static void validateDmlOperationResults (List<Database.SaveResult> srList, String c, String m){
        try {
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, get errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields affected this error: ' + err.getFields());
                    }
                }
            }
        } catch (Exception e) {
            logApexExceptions(e, 'OperationResultHandler', 'validateDmlOperationResults');
        }
    }
    //method used to process general apex exceptions
    public static void logApexExceptions (Exception e, String c, String m) {
            System.debug('Class: ' + c);    
            System.debug('Method: ' + m);    
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString()); 
    }
}