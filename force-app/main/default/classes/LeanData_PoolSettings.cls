public without sharing class LeanData_PoolSettings implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        resetCaps();
    }

    public static void resetCaps(){
        list<Lead_Quota__c > lcToUpdate =new list<Lead_Quota__c>();
        for(Lead_Quota__c lc: [select id,Current_Sign_Up_Quota__c from Lead_Quota__c where Current_Sign_Up_Quota__c!=0]){
            lc.Current_Sign_Up_Quota__c=0;
            lcToUpdate.add(lc);
        }
        if(!lcToUpdate.isEmpty()) Database.update(lcToUpdate);

        list<Partner_Region__c > prToUpdate =new list<Partner_Region__c>();
        for(Partner_Region__c pr: [select id,Current_Daily_Leads_Quota__c from Partner_Region__c where Current_Daily_Leads_Quota__c !=0]){
            pr.Current_Daily_Leads_Quota__c =0;
            prToUpdate.add(pr);
        }
        if(!prToUpdate.isEmpty()) Database.update(prToUpdate);    
        
        list<LeanData__Round_Robin_Setting__c > rrsToUpdate =new list<LeanData__Round_Robin_Setting__c>();
        for(LeanData__Round_Robin_Setting__c rrs: [SELECT Id
                                                    FROM LeanData__Round_Robin_Setting__c 
                                                    WHERE LeanData__Pool__c != null
                                                    AND LeanData__Status__c != 'Available']){
            rrs.LeanData__Status__c = 'Available';
            rrs.LeanData__Inactive_Reason__c = null;
            rrs.Set_Current_Day_Timestamp__c = Datetime.now();
            rrsToUpdate.add(rrs);
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



    public static void partnerRegionDailyQuotaChanged(Map<Id, Partner_Region__c> prNew, Map<Id, Partner_Region__c> prOldMap){

        Set<Id> relevantOwners = new Set<Id>();
        // Set<Id> prToAdd = new Set<Id>();
        List<String> dailyLeadQuotaChangedToZero = new  List<String>();
        // List<String> dailyLeadQuotaGraterThenZero = new  List<String>();
        Map<String, LeanData__Round_Robin_Setting__c> mapOfReleventRRS = new Map<String, LeanData__Round_Robin_Setting__c>();
    //    Map<String, LeanData__Round_Robin_Setting__c> mapOfReleventRRSToDelete = new Map<String, LeanData__Round_Robin_Setting__c>();

        for(Partner_Region__c pr: prNew){
            if(prOldMap.containsKey(pr.Id)){
                if(prOldMap.get(pr.Id).Daily_Leads_Quota__c > 0 && pr.Daily_Leads_Quota__c == 0){
                    //List of RRS update to unavailable 
                    dailyLeadQuotaChangedToZero.add((String)pr.Main_User__c+pr.Country__c);
                }
                relevantOwners.add(pr.Main_User__c);
            }
        }


        List<LeanData__Round_Robin_Setting__c> releventRRSlist = [SELECT Id, LeanData__Pool__r.LeanData__Grouping_Name__c, LeanData__OwnerId__c, LeanData__Pool__r.Country__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__OwnerId__c IN: relevantOwners];
        List<LeanData__Round_Robin_Setting__c> rrsToUnavialbe = new List<LeanData__Round_Robin_Setting__c>();
        // List<LeanData__Round_Robin_Setting__c> rrsToUpdate = new List<LeanData__Round_Robin_Setting__c>();

        for(LeanData__Round_Robin_Setting__c rrs : releventRRSlist){
            mapOfReleventRRS.put((String)rrs.LeanData__OwnerId__c+rrs.LeanData__Pool__r.Country__c, rrs);
        }


        for(String prIdCountry :dailyLeadQuotaChangedToZero){
            if(mapOfReleventRRS.containsKey(prIdCountry)){
                rrsToUnavialbe.add(new LeanData__Round_Robin_Setting__c(
                    Id=mapOfReleventRRS.get(prIdCountry).Id,
                    LeanData__Status__c='Unavailable'
                ));
            }
        }

        update rrsToUnavialbe;
    }
}