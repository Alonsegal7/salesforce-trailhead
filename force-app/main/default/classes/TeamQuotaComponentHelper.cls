public with sharing class TeamQuotaComponentHelper {

    @AuraEnabled(cacheable = true)
    public static List<User> getMyTeamQuoats(String userId){
        return [SELECT SmallBannerPhotoUrl ,MediumPhotoUrl, Name,Office_Region__c, Team_Manager__c, manager.name ,Team__c, Daily_Quota__c, (SELECT Id, Sign_Up_Daily_Quota__c, Current_Sign_Up_Quota__c FROM Leads_Quotas__r), (SELECT Open_Leads_Actual__c, Open_Leads_Limit__c FROM Lead_Caps__r) FROM User WHERE manager.id= :userId OR manager.manager.id = :userId];
    }
}
