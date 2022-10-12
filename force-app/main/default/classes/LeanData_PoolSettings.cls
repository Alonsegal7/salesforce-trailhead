public without sharing class LeanData_PoolSettings implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        resetCaps();
    }

    public static void resetCaps(){
        Map<Id, Integer> userIdToCap = new Map<Id,Integer>();

        list<Lead_Quota__c > lcToUpdate =new list<Lead_Quota__c>();
        List<Lead_Quota__c> allLc=[select id, Current_Sign_Up_Quota__c, Sign_Up_Daily_Quota__c, User__c from Lead_Quota__c];
        for(Lead_Quota__c lc: allLc){
            if(lc.Current_Sign_Up_Quota__c > 0){
                lc.Current_Sign_Up_Quota__c=0;
                lcToUpdate.add(lc);
            }
            if (lc.User__c != null) {
                userIdToCap.put(Id.valueOf(lc.User__c), Integer.valueOf(lc.Sign_Up_Daily_Quota__c));
            }
        }
        if(!lcToUpdate.isEmpty()) Database.update(lcToUpdate);

        list<Partner_Region__c > prToUpdate =new list<Partner_Region__c>();
        List<Partner_Region__c> allPr= [select id,Current_Daily_Leads_Quota__c, Daily_Leads_Quota__c, Main_User__c from Partner_Region__c ];
        for(Partner_Region__c pr: allPr){
            if(pr.Current_Daily_Leads_Quota__c > 0){
                pr.Current_Daily_Leads_Quota__c =0;
                prToUpdate.add(pr);
            }
            if (pr.Main_User__c != null) {
                userIdToCap.put(Id.valueOf(pr.Main_User__c), Integer.valueOf(pr.Daily_Leads_Quota__c));
            }
        }
        if(!prToUpdate.isEmpty()) Database.update(prToUpdate);    
        
        System.debug(userIdToCap);

        list<LeanData__Round_Robin_Setting__c > rrsToUpdate =new list<LeanData__Round_Robin_Setting__c>();

        list<LeanData__Round_Robin_Setting__c> listRrs = [SELECT Id, LeanData__User_Owner__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__Pool__c != null];

        for(LeanData__Round_Robin_Setting__c rrs: listRrs){
                                                 
            if(userIdToCap.get(rrs.LeanData__User_Owner__c) == null){
                //Send slack notefication
                Utilities.sendSlackMessage('Error in resetCaps LeanData_PoolSettings service wasnt able locate user from RRS', 'biz-tech-monitoring', null , null, 'Found a user with RRS without lead cap ' + rrs.LeanData__User_Owner__c, null, null);  
            }else{
                if(userIdToCap.get(rrs.LeanData__User_Owner__c) == 0){
                    rrs.LeanData__Status__c = 'Unavailable';
                    rrs.LeanData__Inactive_Reason__c = '["Lead Cap at 0 - Daily Reset"]';
                }else{
                    rrs.LeanData__Status__c = 'Available';
                    rrs.LeanData__Inactive_Reason__c = null;
                }
                rrsToUpdate.add(rrs);
            }

        }
        if(!rrsToUpdate.isEmpty()) Database.update(rrsToUpdate);  
    }

    public static void partnerRegionMainUserChangedUpdatePoolSetting(List<Partner_Region__c> prNew, Map<Id, Partner_Region__c> prOldMap) {
    
        Set<Id> relevantOwners = new Set<Id>();
        Map<Id, List<Partner_Region__c>> mainUserToRegions = new Map<Id, List<Partner_Region__c>>();
        for (Partner_Region__c pr : prNew) {
            Id prevUserId = prOldMap.get(pr.Id).Main_User__c;
            if (prOldMap != null && pr.Main_User__c != prevUserId) {
                relevantOwners.add(prevUserId);
                if (mainUserToRegions.containsKey(prevUserId)) {
                    mainUserToRegions.get(prevUserId).add(pr);
                }
                else {
                    mainUserToRegions.put(prevUserId, new List<Partner_Region__c>{pr});
                }
            }
        }
        if (relevantOwners == null) return;
        List<LeanData__Round_Robin_Setting__c> rrSettingsToUpdate = [SELECT Id, LeanData__Pool__r.LeanData__Grouping_Name__c, LeanData__OwnerId__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__OwnerId__c IN: relevantOwners];
        for (LeanData__Round_Robin_Setting__c rrSetting : rrSettingsToUpdate) {
            List<Partner_Region__c> prForTheUser = mainUserToRegions.get(rrSetting.LeanData__OwnerId__c);
            for (Partner_Region__c pr : prForTheUser) {
                if (rrSetting.LeanData__Pool__r.LeanData__Grouping_Name__c.contains('-'+pr.Country__c+'-')) {
                    rrSetting.LeanData__OwnerId__c = pr.Main_User__c;
                }
            }         
        }
        update rrSettingsToUpdate;
    }
}