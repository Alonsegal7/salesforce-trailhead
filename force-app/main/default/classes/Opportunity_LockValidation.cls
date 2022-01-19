public without sharing class Opportunity_LockValidation {

    private static Set<Id> unlockedOpps_set = new Set<Id>();
    private static List<Opportunity_Lock_Validation_Control__mdt> validationCmtList;
    private static String myProfile;
    private static Boolean firstRun = true;
    private static String errorMsg = 'This opp is closed and locked for editing.';
    
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
        
        for(Opportunity lockedOpp: lockedOpps){ //main loop of unlocked opps
            system.debug('Opportunity_LockValidation unlockedOpps_set: ' + unlockedOpps_set);
            system.debug('Opportunity_LockValidation firstRun: ' + firstRun);
            for(Opportunity_Lock_Validation_Control__mdt cmt: validationCmtList){
                system.debug('Opportunity_LockValidation validationCmtList loop; fieldname: ' + cmt.Field_API_Name__c);
                if(lockedOpp.get(cmt.Field_API_Name__c) == oldOppsMap.get(lockedOpp.Id).get(cmt.Field_API_Name__c)) { //check if the current field was changed
                    system.debug('Opportunity_LockValidation validationCmtList loop; next field cause no change');
                    continue;
                }
                if(!firstRun){ //check if as a result of the original fields update, other fields got updated
                    if(unlockedOpps_set.contains(lockedOpp.Id)) { //opp was unlocked in first run
                        //for other fields (from the cmt) that got updated as a result of the original fields - we save an audit marked as Continual Update
                        insert new Opportunity_Audit__c(Type__c = 'Opportunity Lock Process - Continual Update', Opportunity__c = lockedOpp.Id, Changed_Field__c = cmt.Field_API_Name__c, Original_Value__c = String.valueOf(oldOppsMap.get(lockedOpp.Id).get(cmt.Field_API_Name__c)), New_Value__c = String.valueOf(lockedOpp.get(cmt.Field_API_Name__c)));
                        system.debug('Opportunity_LockValidation validationCmtList loop; added Continual Update for ' + cmt.Field_API_Name__c);
                        continue;
                    } else { //opp was not unlocked in first run
                        lockedOpp.addError(errorMsg);
                    }
                }
                
                if(cmt.Requires_Manual_Unlocking__c){ // manual unlocking is required for current field
                    system.debug('Opportunity_LockValidation Entered Requires_Manual_Unlocking__c');
                    if(!(lockedOpp.Unlock_Opportunity__c && myProfile == 'System Administrator') && !Test.isRunningTest()) lockedOpp.addError(errorMsg);
                    else {
                        unlockedOpps_set.add(lockedOpp.Id);
                        insert new Opportunity_Audit__c(Type__c = 'Opportunity Lock Process', Opportunity__c = lockedOpp.Id, Changed_Field__c = cmt.Field_API_Name__c, Original_Value__c = String.valueOf(oldOppsMap.get(lockedOpp.Id).get(cmt.Field_API_Name__c)), New_Value__c = String.valueOf(lockedOpp.get(cmt.Field_API_Name__c)));
                    }
                } else if(cmt.Allowed_Profiles__c != null){
                    system.debug('Opportunity_LockValidation Entered Allowed_Profiles__c');
                    Set<String> allowedProfilesSet = new Set<String>(cmt.Allowed_Profiles__c.trim().split(','));
                    if(!allowedProfilesSet.contains(myProfile) && !Test.isRunningTest()) lockedOpp.addError(errorMsg);
                    else {
                        unlockedOpps_set.add(lockedOpp.Id);
                        insert new Opportunity_Audit__c(Type__c = 'Opportunity Lock Process', Opportunity__c = lockedOpp.Id, Changed_Field__c = cmt.Field_API_Name__c, Original_Value__c = String.valueOf(oldOppsMap.get(lockedOpp.Id).get(cmt.Field_API_Name__c)), New_Value__c = String.valueOf(lockedOpp.get(cmt.Field_API_Name__c)));
                    }
                } else if(!Test.isRunningTest()) lockedOpp.addError(errorMsg);
            }
            if(lockedOpp.Unlock_Opportunity__c) lockedOpp.Unlock_Opportunity__c = false;
        }
        if(firstRun) firstRun = false;
    }
}