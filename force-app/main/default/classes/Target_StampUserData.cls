public class Target_StampUserData {

   public List<Target__c> stampUserData(List<Target__c> newTargetsList, Map<Id,Target__c> oldTargetsMap){
      Set<Id> userIds = new Set<Id>();
      List<Target__c> targetsToUpdateStamps = new List<Target__c>();
      for(Target__c target: newTargetsList){
         if(target.User__c != null && target.RecordTypeId == Utilities.personalTargetRT && (oldTargetsMap == null || oldTargetsMap.get(target.Id).User__c == null)){
            targetsToUpdateStamps.add(target);
            userIds.add(target.User__c);
         }
      }
      Map<Id,User> usersMap = new Map<Id,User>([select Id, Tenure_Months__c, Outbound__c, Department, Function__c, Group__c, Business_Role__c, Segment__c, Seniority__c, Quota_Carrying__c, Team__c, Office__c, Office_Region__c from User where Id IN: userIds]);
      for(Target__c target: targetsToUpdateStamps){
         User currUser = usersMap.get(target.User__c);
         target.Tenure__c = currUser.Tenure_Months__c;
         target.Outbound_Rep__c = currUser.Outbound__c;
         target.Department__c = currUser.Department;
         target.Function__c = currUser.Function__c;
         target.User_Group__c = currUser.Group__c;
         target.User_Business_Role__c = currUser.Business_Role__c;
         target.User_Segment__c = currUser.Segment__c;
         target.User_Seniority__c = currUser.Seniority__c;
         target.User_Quota_Carrying__c = currUser.Quota_Carrying__c;
         target.Team__c = currUser.Team__c;
         target.User_Office__c = currUser.Office__c;
         target.User_Office_Region__c = currUser.Office_Region__c;
         target.Ramp_Up_Stage__c = getRampUpStage(target.Amount__c, currUser.Tenure_Months__c);
      }
      return targetsToUpdateStamps;
   }
   
   private static String getRampUpStage(Decimal targetAmount, Decimal userTenure) {
      if (userTenure <= 1 && targetAmount == 0){
         return 'Onboarding';
      } 
      else if (userTenure < 6) {
         return 'Ramping';
      } 
      else if (userTenure >= 6) {
         return 'Fully Ramped';
      } 
      else return '';
   }
}