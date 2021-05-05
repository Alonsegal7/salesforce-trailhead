public class Account_UpdateCsmManager {

    public static Boolean firstRun = true;

    public void checkForCmsManagerUpdate(List<User> newUsers, Map<Id,User> oldUsersMap){
        Map<Id, Id> csmUserIdsManagerIdsMap = new Map<Id, Id>();
        Id csmProfileId = [select Id from Profile where Name = 'CSM' limit 1].Id;
        for(User userRec: newUsers){
            if(userRec.isActive && userRec.ProfileId == csmProfileId && userRec.ManagerId != oldUsersMap.get(userRec.Id).ManagerId){
                csmUserIdsManagerIdsMap.put(userRec.Id, userRec.ManagerId);
            }
        }
        if(!csmUserIdsManagerIdsMap.isEmpty()){
            Id MondayAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
            List<Account> accList = [select Id, CSM__c, CSM_Manager__c from Account where RecordTypeId =: MondayAccRecordTypeId and CSM__c IN: csmUserIdsManagerIdsMap.keySet()];
            List<Account> accToUpdate = new List<Account>();
            for(Account acc: accList){
                if(csmUserIdsManagerIdsMap.containsKey(acc.CSM__c)){
                    Id tempScmManagerId = csmUserIdsManagerIdsMap.get(acc.CSM__c);
                    if(tempScmManagerId != acc.CSM_Manager__c){
                        accToUpdate.add(new Account(Id = acc.Id, CSM_Manager__c = tempScmManagerId));
                    }
                }
            }
            if(!accToUpdate.isEmpty()) System.enqueueJob(new updateAccounts(accToUpdate));
        }
    }

    private class updateAccounts implements Queueable{
        private List<Account> accToUpdate;
    
        public updateAccounts(List<Account> accToUpdate){
            this.accToUpdate = accToUpdate;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(accToUpdate);
        }
    }
}
