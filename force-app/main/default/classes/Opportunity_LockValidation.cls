public without sharing class Opportunity_LockValidation {

    public static Map<Id,Set<String>> oppAllowedFields = new Map<Id,Set<String>>();
    public static List<Opportunity_Lock_Validation_Control__mdt> validationCmtList;
    public static String myProfile;
    
    public void runValidation(List<Opportunity> newOpps, Map<Id,Opportunity> oldOppsMap){
        List<Opportunity> lockedOpps = new List<Opportunity>();
        for(Opportunity opp: newOpps){
            if(oldOppsMap.get(opp.Id).Is_Locked__c){ //opp was locked
                lockedOpps.add(opp);
            } else if(opp.Unlock_Opportunity__c) {
                opp.Unlock_Opportunity__c = false;
            }
        }
        if(lockedOpps.isEmpty()) return;

        if(validationCmtList == null) validationCmtList = [select Label, Allowed_Profiles__c, Field_API_Name__c, Requires_Manual_Unlocking__c from Opportunity_Lock_Validation_Control__mdt where Active__c = true];
        if(myProfile == null) {
            User myUser = [select Profile.Name from User where Id =: UserInfo.getUserId()];
            myProfile = myUser.Profile.Name;
        }
        
        for(Opportunity lockedOpp: lockedOpps){
            for(Opportunity_Lock_Validation_Control__mdt cmt: validationCmtList){
                if(lockedOpp.get(cmt.Field_API_Name__c) == oldOppsMap.get(lockedOpp.Id).get(cmt.Field_API_Name__c) || (oppAllowedFields.containsKey(lockedOpp.Id) && oppAllowedFields.get(lockedOpp.Id).contains(cmt.Field_API_Name__c))) { //check if the current field was changed or already allowed
                    continue; 
                }
                if(cmt.Requires_Manual_Unlocking__c){ // manual unlocking is required for current field
                    if(!(lockedOpp.Unlock_Opportunity__c && myProfile == 'System Administrator') && !Test.isRunningTest()) lockedOpp.addError('This opp is closed and locked for editing.');
                    else {
                        if(oppAllowedFields.containsKey(lockedOpp.Id)){
                            oppAllowedFields.get(lockedOpp.Id).add(cmt.Field_API_Name__c);
                        } else {
                            oppAllowedFields.put(lockedOpp.Id, new Set<String>{cmt.Field_API_Name__c});
                        }
                        insert new Opportunity_Audit__c(Type__c = 'Opportunity Lock Process', Opportunity__c = lockedOpp.Id, Changed_Field__c = cmt.Field_API_Name__c, Original_Value__c = String.valueOf(oldOppsMap.get(lockedOpp.Id).get(cmt.Field_API_Name__c)), New_Value__c = String.valueOf(lockedOpp.get(cmt.Field_API_Name__c)));
                    }
                } else if(cmt.Allowed_Profiles__c != null){
                    Set<String> allowedProfilesSet = new Set<String>(cmt.Allowed_Profiles__c.trim().split(','));
                    if(!allowedProfilesSet.contains(myProfile) && !Test.isRunningTest()) lockedOpp.addError('This opp is closed and locked for editing.');
                    else {
                        if(oppAllowedFields.containsKey(lockedOpp.Id)){
                            oppAllowedFields.get(lockedOpp.Id).add(cmt.Field_API_Name__c);
                        } else {
                            oppAllowedFields.put(lockedOpp.Id, new Set<String>{cmt.Field_API_Name__c});
                        }
                        insert new Opportunity_Audit__c(Type__c = 'Opportunity Lock Process', Opportunity__c = lockedOpp.Id, Changed_Field__c = cmt.Field_API_Name__c, Original_Value__c = String.valueOf(oldOppsMap.get(lockedOpp.Id).get(cmt.Field_API_Name__c)), New_Value__c = String.valueOf(lockedOpp.get(cmt.Field_API_Name__c)));
                    }
                } else if(!Test.isRunningTest()) lockedOpp.addError('This opp is closed and locked for editing.');
            }
            if(lockedOpp.Unlock_Opportunity__c) lockedOpp.Unlock_Opportunity__c = false;
        }
    }
}