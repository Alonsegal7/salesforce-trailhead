public class Target_StampUserData {
    public List<Target__c> stampUserData(List<Target__c> newTargetsList, Map<Id,Target__c> oldTargetsMap){
        Set<Id> userIds = new Set<Id>();
        List<Target__c> targetsToUpdateStamps = new List<Target__c>();

        for(Target__c target: newTargetsList){
            if(target.User__c != null && (oldTargetsMap == null || oldTargetsMap.get(target.Id).User__c == null)){
                targetsToUpdateStamps.add(target);
                userIds.add(target.User__c);
            }
        }

        Map<Id,User> usersMap = new Map<Id,User>([select Id, Group__c, Business_Role__c, Segment__c, Seniority__c, Quota_Carrying__c, Team__c, Office__c, Office_Region__c from User where Id IN: userIds]);
        for(Target__c target: targetsToUpdateStamps){
            User currUser = usersMap.get(target.User__c);
            target.User_Group__c = currUser.Group__c;
            target.User_Business_Role__c = currUser.Business_Role__c;
            target.User_Segment__c = currUser.Segment__c;
            target.User_Seniority__c = currUser.Seniority__c;
            target.User_Quota_Carrying__c = currUser.Quota_Carrying__c;
            target.User_Team__c = currUser.Team__c;
            target.Team__c = currUser.Team__c;
            target.User_Office__c = currUser.Office__c;
            target.User_Office_Region__c = currUser.Office_Region__c;
        }
        return targetsToUpdateStamps;
    }
}