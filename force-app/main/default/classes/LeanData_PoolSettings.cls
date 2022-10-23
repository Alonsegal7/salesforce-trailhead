public without sharing class LeanData_PoolSettings implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        resetCaps();
    }

    //this methods resets the caps and sets the RRS avaiability based on the quotas
    public static void resetCaps(){

        //Part 1 - Create the 3 maps: usersByTypes, leadQuotasToUpdate and partnerRegionsToUpdate. Also reset the daily caps to 0
        Map<Id,String> usersByTypes = new Map<Id,String>(); //the value will be 'Sales' or 'Partner' for each user, used to later query the relevant Partner Region / Lead Quota
        Map<Id,Lead_Quota__c> salesUsersQuotas = new Map<Id,Lead_Quota__c>();
        Map<String,Partner_Region__c> partnerUsersQuotas = new Map<String,Partner_Region__c>(); //the key will be the userId + the country because partner users can have more then 1 partner region (quota)

        List<Lead_Quota__c> leadQuotasToUpdate = new List<Lead_Quota__c>();
        List<Lead_Quota__c> allLeadQuotas = [SELECT Id, Current_Sign_Up_Quota__c, Sign_Up_Daily_Quota__c, User__c FROM Lead_Quota__c WHERE User__c != NULL];
        for(Lead_Quota__c lq: allLeadQuotas){
            if(lq.Current_Sign_Up_Quota__c > 0) {
                leadQuotasToUpdate.add(new Lead_Quota__c(Id = lq.Id, Current_Sign_Up_Quota__c = 0));
            }
            usersByTypes.put(lq.User__c, 'Sales');
            salesUsersQuotas.put(lq.User__c, lq);
        }
        List<Partner_Region__c> partnerRegionsToUpdate = new List<Partner_Region__c>();
        List<Partner_Region__c> allpartnerRegions= [SELECT Id,Current_Daily_Leads_Quota__c, Daily_Leads_Quota__c, Main_User__c, Country__c FROM Partner_Region__c WHERE Main_User__c != NULL];
        for(Partner_Region__c pr: allpartnerRegions){
            if(pr.Current_Daily_Leads_Quota__c > 0){
                partnerRegionsToUpdate.add(new Partner_Region__c(Id = pr.Id, Current_Daily_Leads_Quota__c = 0));
            }
            usersByTypes.put(pr.Main_User__c, 'Partner');
            partnerUsersQuotas.put((String)pr.Main_User__c + pr.Country__c, pr);
        }
        //Part 2 - Interate over the RRSs and update the avaiability based on the user's quota
        List<LeanData__Round_Robin_Setting__c> allRRS = [
            SELECT Id, LeanData__User_Owner__c, LeanData__Pool__r.Country__c, LeanData__Status__c, LeanData__Inactive_Reason__c 
            FROM LeanData__Round_Robin_Setting__c 
            WHERE LeanData__Pool__c != NULL];
        List<LeanData__Round_Robin_Setting__c > RRSToUpdate = new List<LeanData__Round_Robin_Setting__c>();

        Set<Id> usersWithRRSWithoutQuota = new Set<Id>();

        for (LeanData__Round_Robin_Setting__c rrs : allRRS) {
            if (usersByTypes.containsKey(rrs.LeanData__User_Owner__c)) {
                String userType = usersByTypes.get(rrs.LeanData__User_Owner__c); //will be 'Sales' or 'Partner'
                Decimal userQuota;
                if (userType == 'Sales') { //sales user - get the quota from based on the user id
                    userQuota = salesUsersQuotas.get(rrs.LeanData__User_Owner__c)?.Sign_Up_Daily_Quota__c; 
                } else { //partner user - get the quota from based on the user id & country
                    String userKey = (String)rrs.LeanData__User_Owner__c + rrs.LeanData__Pool__r.Country__c;
                    userQuota = partnerUsersQuotas.get(userKey)?.Daily_Leads_Quota__c; 
                }
                //quota found, continue to update the availability  
                if (userQuota > 0 && rrs.LeanData__Status__c == 'Unavailable') {
                    rrs.LeanData__Status__c = 'Available';
                    rrs.LeanData__Inactive_Reason__c = null;
                    RRSToUpdate.add(rrs);
                }
                else if(userQuota == 0) {
                    rrs.LeanData__Status__c = 'Unavailable';
                    rrs.LeanData__Inactive_Reason__c = '["Lead Cap at 0 - Daily Reset"]';
                    RRSToUpdate.add(rrs);
                }
            }
            else { //RRS with Pool and without lead cap, add to set and notify biztech
                usersWithRRSWithoutQuota.add(rrs.LeanData__User_Owner__c);
            }
        }
        update RRSToUpdate;
        update leadQuotasToUpdate;
        update partnerRegionsToUpdate;
        
        if (!usersWithRRSWithoutQuota.isEmpty()) {
            for (Id userId : usersWithRRSWithoutQuota) {
                Utilities.sendSlackMessage('Error in LeanData_PoolSettings - resetCaps service wasnt able locate user from RRS', 'biz-tech-monitoring', null , null, 'Found a user with RRS without lead cap ' + userId, null, null);
            }
        }
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



    public static void partnerRegionDailyQuotaChanged(List<Partner_Region__c> prNew, Map<Id, Partner_Region__c> prOldMap){

        Set<Id> relevantOwners = new Set<Id>();
        List<String> dailyLeadQuotaChangedToZero = new  List<String>();
        Map<String, LeanData__Round_Robin_Setting__c> mapOfReleventRRS = new Map<String, LeanData__Round_Robin_Setting__c>();

        for(Partner_Region__c pr: prNew){
            if(prOldMap.containsKey(pr.Id)){
                if(prOldMap.get(pr.Id).Daily_Leads_Quota__c > 0 && pr.Daily_Leads_Quota__c == 0){
                    //List of RRS update to unavailable 
                    dailyLeadQuotaChangedToZero.add((String)pr.Main_User__c+pr.Country__c);
                    relevantOwners.add(pr.Main_User__c);
                }
            }
        }


        List<LeanData__Round_Robin_Setting__c> releventRRSlist = [SELECT Id, LeanData__Pool__r.LeanData__Grouping_Name__c, LeanData__OwnerId__c, LeanData__Pool__r.Country__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__OwnerId__c IN: relevantOwners];
        List<LeanData__Round_Robin_Setting__c> rrsToUnavialbe = new List<LeanData__Round_Robin_Setting__c>();

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