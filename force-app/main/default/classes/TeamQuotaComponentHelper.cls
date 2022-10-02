public with sharing class TeamQuotaComponentHelper {

    @AuraEnabled(cacheable = true)
    public static List<User> getMyTeamQuoats(String userId){
        return [SELECT SmallBannerPhotoUrl ,MediumPhotoUrl, Name,Office_Region__c, Team_Manager__c, manager.name ,Team__c, Daily_Quota__c, (SELECT Id, Sign_Up_Daily_Quota__c, Current_Sign_Up_Quota__c FROM Leads_Quotas__r), (SELECT Open_Leads_Actual__c, Open_Leads_Limit__c FROM Lead_Caps__r) FROM User WHERE manager.id= :userId OR manager.manager.id = :userId];
    }

    @AuraEnabled(cacheable = true)
    public static List<aggregateResult> getAVGDistributedScore(String userId){
        return [SELECT Owner_Name_Initial__c, AVG(Distributed_score__c) FROM Lead WHERE Created_From_Pull_Signups_BB__c = true and Distribution_reason__c = 'New lead' and  Received_Timestamp_DT__c = LAST_N_DAYS:200 AND OwnerId IN (SELECT Id FROM User WHERE manager.id= :userId OR manager.manager.id = :userId) GROUP BY Owner_Name_Initial__c];
    }
}
