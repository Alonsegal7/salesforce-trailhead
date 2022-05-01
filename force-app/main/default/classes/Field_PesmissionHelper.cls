global class Field_PesmissionHelper {
    
    @AuraEnabled
    public static Boolean enableFieldVisibility(String objectName, List<String> fieldNames) {
        
        if(!checkIfFieldExists(objectName, fieldNames)) {
            System.debug('Fields Not Found');
            return false;
        }
        
        // Retrieves all the relevant profiles
        List<Profile> relevantProfiles = new List<Profile>([SELECT Id,Name FROM Profile WHERE UserLicense.Name = 'Salesforce' AND (NOT(Name like '%Community%'))]);
        Set<Id> relevantProfileIds = (new Map<Id,SObject>(relevantProfiles)).keySet();
        System.debug('relevantProfiles: '+ relevantProfiles);

        List<FieldPermissions> FPsToUpsert = new List<FieldPermissions>();

        for (String f : fieldNames) {
            String fieldAndObjectName = objectName + '.' + f;
            System.debug('fieldAndObjectName: '+fieldAndObjectName);

            // Retrieves existing FPs and map them to their profile Id
            Map<Id,FieldPermissions> profilesWithFPs = new Map<Id,FieldPermissions>();
            List<FieldPermissions> existingFPs = new List<FieldPermissions>([SELECT Id, Field, PermissionsRead, Parent.ProfileId FROM FieldPermissions WHERE Field =: fieldAndObjectName AND Parent.ProfileId IN: relevantProfileIds]);
            // Put existing FPs in a map
            if (!existingFPs.isempty()) {
                for (FieldPermissions fsl : existingFPs) {
                    profilesWithFPs.put(fsl.Parent.ProfileId, new FieldPermissions(Id = fsl.Id, PermissionsRead = true));
                }
            }
            // Map of Profile IDs to Permission Sets, need because Field Permission should be linked to a Permission Set
            List<PermissionSet> relevantPermissionSets = new List<PermissionSet>([SELECT Id, ProfileId FROM PermissionSet WHERE ProfileId IN: relevantProfileIds]);
            Map<Id,PermissionSet> profilesWithFSs = new Map<Id,PermissionSet>();
            for (PermissionSet ps : relevantPermissionSets) {
                profilesWithFSs.put(ps.ProfileId, ps);
            }
            // Add FPs for the remaining profiles
            for (Profile pr : relevantProfiles) {
                if(!profilesWithFPs.containsKey(pr.Id)) {
                    profilesWithFPs.put(pr.Id, new FieldPermissions(
                        Field = fieldAndObjectName, 
                        ParentId = profilesWithFSs.get(pr.Id).Id, 
                        SobjectType = objectName,
                        PermissionsRead = true)
                    );
                }
            }
            FPsToUpsert.addall(profilesWithFPs.values());
        }
        try {
            System.debug('FPs to upsert: '+FPsToUpsert);
            for (FieldPermissions fp : FPsToUpsert) {
                System.debug('Current FP: '+fp);
            }
            upsert FPsToUpsert;
            System.debug('Upsert Succeeded: ');
            return true;
        } catch (Exception e) {
            System.debug('Upsert Failed: '+e.getMessage());
            return false;
        }
    }
    
    public static Boolean checkIfFieldExists(String objName, List<String> fieldNames) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        try {
            Map<String, Schema.SObjectField> FieldMap = schemaMap.get(objName).getDescribe().fields.getMap();    
            Set<String> objectFields = FieldMap.keySet();
            for (String f : fieldNames) {
                if(!objectFields.contains(f.toLowerCase())) {
                    return false;
                }
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldDefinition> getfields(string objectname){
        string query = 'select DeveloperName,QualifiedApiName from FieldDefinition where EntityDefinition.QualifiedApiName = :objectname and LastModifiedDate = LAST_N_DAYS:30 ORDER BY LastModifiedDate';
        list<FieldDefinition> lstObject = Database.query(query);
        return lstObject;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSObjects() {        
        Map<String, String> sObjectNamebyLabel = new Map<String, String>();
        for(SObjectType objectType : Schema.getGlobalDescribe().values()) {
            DescribeSObjectResult sObjectDescribe = objectType.getDescribe();
            if(sObjectDescribe.isAccessible() && sObjectDescribe.isQueryable()) {
                sObjectNamebyLabel.put(sObjectDescribe.getLabel(),sObjectDescribe.getName());
            }
        }        
        return sObjectNamebyLabel;
    }
}
