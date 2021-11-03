public with sharing class Account_Rollup_Scheduled implements Schedulable {
    public void execute(SchedulableContext SC) {

        System.debug('Michael - Account_Rollup_Scheduled - Entered scheduled');
        Map<Id,Account> relevantCompaniesMap = new Map<Id,Account>([SELECT Id,ParentId FROM Account WHERE Pending_Rollup__c = true]);
        Set<Id> relevantCompanies = relevantCompaniesMap.keyset();
        System.debug('Michael - Account_Rollup_Scheduled - relevantCompaniesMap: '+relevantCompaniesMap);
        try {
            ID jobID = System.enqueueJob(new updateAccountsRollupQueueable(relevantCompanies));
            System.debug('Michael - Account_Rollup_Scheduled - Sent to queueable');
            System.debug('JobIDNo: '+jobID);
        } catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            Utilities.sendDebugEmail('Error in AccountRollup Initiate part: ',e,e.getMessage());   
            Utilities.sendSlackMessage('Error in AccountRollup Initiate part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);
        }
    }
    public class updateAccountsRollupQueueable implements Queueable{
        private Set<Id> relevantCompanies;

        public updateAccountsRollupQueueable(Set<Id> relevantCompanies){
            this.relevantCompanies = relevantCompanies;
        }
        public void execute(System.QueueableContext ctx) {
            Decimal updatedArr;
            Decimal updatedSeats;
            Decimal updatedMapp;
            Decimal updatedWapp;
            Decimal updatedMembers;

            System.debug('Michael - updateAccountsRollupQueueable - Entered queueable');
            Map<Id, List<Account>> accountsWithChildAccounts = new Map<Id, List<Account>>();
            List<Account> childrenAccounts = [SELECT id, ParentId, ARR__c, Plan_Seats__c, MAPP__c, WAPP__c, Members__c FROM Account WHERE ParentId IN:relevantCompanies];
            if(childrenAccounts.isempty()){return;}
            for (Account child : childrenAccounts) {
                if (accountsWithChildAccounts.containsKey(child.ParentId)) {
                    accountsWithChildAccounts.get(child.ParentId).add(child);
                }
                else {
                    accountsWithChildAccounts.put(child.ParentId,new List<Account>{child});
                }
            }

            List<Account> companiesToUpdate = new List<Account>();
            List<Account> companiesToRemoveFlag = new List<Account>();
            for (Id compId : relevantCompanies) {
                updatedArr = 0;
                updatedSeats = 0;
                updatedMapp = 0;
                updatedWapp = 0;
                updatedMembers = 0;
                //System.debug('Michael3: ')
                if(!accountsWithChildAccounts.isEmpty()&&accountsWithChildAccounts.containsKey(compId)){
                    for( Account child: accountsWithChildAccounts.get(compId)) {
                        if (child.ARR__c!=null) {
                            updatedArr+=child.ARR__c;
                        }
                        if (child.Plan_Seats__c!=null) {
                            updatedSeats+=child.Plan_Seats__c;
                        }
                        if (child.MAPP__c!=null) {
                            updatedMapp+=child.MAPP__c;
                        }
                        if (child.WAPP__c!=null) {
                            updatedWapp+=child.WAPP__c;
                        }
                        if (child.Members__c!=null) {
                            updatedMembers+=child.Members__c;
                        }
                    }
                }
                companiesToUpdate.add(new Account(Id=compId,ARR__c=updatedArr,Plan_Seats__c=updatedSeats,MAPP__c=updatedMapp,WAPP__c=updatedWapp,Members__c=updatedMembers));
                companiesToRemoveFlag.add(new Account(Id=compId,Pending_Rollup__c = false));
            }
            if(!companiesToUpdate.isEmpty()) {
                try {
                    Database.SaveResult[] SrList = Database.update(companiesToUpdate, false);
                } catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                    Utilities.sendDebugEmail('Error in AccountRollup Update part: ',e,e.getMessage());   
                    Utilities.sendSlackMessage('Error in AccountRollup Update part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);                     
                }
                //remove the triggrt flag
                try {
                    Database.SaveResult[] SrList = Database.update(companiesToRemoveFlag, false);
                } catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                    Utilities.sendDebugEmail('Error in AccountRollup Update2 part: ',e,e.getMessage());   
                    Utilities.sendSlackMessage('Error in AccountRollup Update2 part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);                     
                }
                //check which companies from the list has parents and update the parents as well
                List<Account>relevantChildAccounts = new List<Account>([SELECT Id,ParentId FROM Account WHERE Id IN:relevantCompanies]);
                Set<Id> relevantParents = new Set<Id>();
                for (Account childAcc : relevantChildAccounts) {
                    if(childAcc.ParentId!=null){
                        relevantParents.add(childAcc.ParentId);
                    }
                }
                System.debug('Michael AccountRollup scope for parent queueable - childs: '+relevantChildAccounts);
                System.debug('Michael AccountRollup scope for parent queueable - parents: '+relevantParents);
                if(!relevantParents.isEmpty()){
                    ID parentJobID = System.enqueueJob(new updateAccountsRollupQueueable(relevantParents));
                    System.debug('ParentJobIDNo: '+parentJobID);
                }
            }
        }
    }
}