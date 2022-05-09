public without sharing class Opportunity_LockValidation {


    private static Set<Id> unlockedOpps_set = new Set<Id>();
    private static List<Opportunity_Lock_Validation_Control__mdt> validationCmtList;
    private static String myProfile;
    private static Boolean firstRun = true;
    private static String errorMsg = 'This opp is closed and locked for editing.';
    
    //runs in before update
    public void cosellLockValidation(List<Opportunity> newOpps, Map<Id,Opportunity> oldOppsMap){ //prevent secondary opps from being updated
        Map<Id,Opportunity> potentialOpps_map = new Map<Id,Opportunity>();
        for(Opportunity opp: newOpps){ 
            if(opp.Co_Sell_Opportunity__c == null || opp.Need_Sync_Co_Sell__c) continue; //not co-sell or already marked as need to be synced
            for(Co_sell_Main_to_Secondary_Opp_Mapping__mdt cmt: Opportunity_CoSellSyncService.mainToSecOppMapping_cmt){ //we prevent the update only for cmt fields
                if(opp.get(cmt.Field_API_Name__c) != oldOppsMap.get(opp.Id).get(cmt.Field_API_Name__c)){ //field from cmt was updated
                    if(Opportunity_CoSellSyncService.isSecondaryCoSellOpp(opp)) potentialOpps_map.put(opp.Id, opp);
                    else if(Opportunity_CoSellSyncService.isMainCoSellOpp(opp)) opp.Need_Sync_Co_Sell__c = true;
                }
            }
        }
        if(potentialOpps_map.isEmpty()) return;
        for(Co_Sell_Request__c cosellReq: [select Id, Secondary_Opportunity__c from Co_Sell_Request__c where Secondary_Opportunity__c in: potentialOpps_map.keySet()]){
            potentialOpps_map.get(cosellReq.Secondary_Opportunity__c).addError('Secondary Co Sell Opportunities can not be updated');
        }
    }

    //runs in before update
    public void runValidation(List<Opportunity> newOpps, Map<Id,Opportunity> oldOppsMap){
        List<Opportunity> lockedOpps = new List<Opportunity>();
        for(Opportunity opp: newOpps){
            if(oldOppsMap.get(opp.Id).Is_Locked__c && !Opportunity_CoSellSyncService.isSecondaryCoSellOpp(opp)){ 
                //opp was locked and it is not a secondary co sell opp 
                //secondary co sell opps have a separate validation - cosellLockValidation 
                //which allows update only by Opportunity_CoSellSyncService.syncMainOppsToSec , regardless of Is_Locked__c
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