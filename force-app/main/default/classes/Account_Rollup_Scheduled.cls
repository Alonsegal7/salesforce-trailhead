public with sharing class Account_Rollup_Scheduled implements Database.Batchable<sObject>,Schedulable {
    public void execute(SchedulableContext SC) {

        System.debug('Michael - Account_Rollup_Scheduled - Entered scheduled');
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this, 200);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_Rollup_Scheduled ', e, e.getMessage());   
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,ParentId FROM Account WHERE Pending_Rollup__c = true LIMIT 10000';
        try {
            return Database.getQueryLocator(query);
        }
        catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_Rollup_Scheduled  - getQueryLocator Failed:', e, e.getMessage());
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Account> scope){
        Set<Id> relevantAccounts = (new Map<Id,Account>(scope)).keySet();
        try {
            ID jobID = System.enqueueJob(new updateAccountsRollupQueueable(relevantAccounts));
            System.debug('Michael - Account_Rollup_Batchable - Sent to queueable');
            System.debug('JobIDNo: '+jobID);
        } catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            Utilities.sendSlackMessage('Error in AccountRollup Batchable part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);
        }
     }

    public void finish(Database.BatchableContext BC){}

    public class updateAccountsRollupQueueable implements Queueable{
        private Set<Id> relevantAccounts;

        public updateAccountsRollupQueueable(Set<Id> relevantAccounts){
            this.relevantAccounts = relevantAccounts;
        }
        public void execute(System.QueueableContext ctx) {
            Decimal updatedArr;
            Decimal updatedSeats;
            Decimal updatedMapp;
            Decimal updatedWapp;
            Decimal updatedMembers;
            Id CompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
            Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
            Set<Id> relevantCompanies=new Set<Id>();
            Set<Id> relevantMAs=new Set<Id>();
            
            List<Account> accountsList=new List<Account>([SELECT Id,RecordTypeId FROM Account WHERE Id IN: relevantAccounts]);
            
            for (Account acc : accountsList) {
                if (acc.recordTypeId == CompanyRecordTypeId) {
                    relevantCompanies.add(acc.Id);
                }
                if (acc.recordTypeId == MARecordTypeId) {
                    relevantMAs.add(acc.Id);
                }
            }
            
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
            //Separation to 2 sets- 1 for Monday Accounts (came from ValueChange) and 1 for Companies (Came from ParentChange or sent to queueble from child)
            List<Account> companiesToUpdate = new List<Account>();
            List<Account> accountsToRemoveFlag = new List<Account>();
            //Value calculation - for companies
            for (Id compId : relevantCompanies) {
                updatedArr = 0;
                updatedSeats = 0;
                updatedMapp = 0;
                updatedWapp = 0;
                updatedMembers = 0;
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
                accountsToRemoveFlag.add(new Account(Id=compId,Pending_Rollup__c = false));
            }
            for (Id maId : relevantMAs) {
                accountsToRemoveFlag.add(new Account(Id=maId,Pending_Rollup__c = false));
            }
            if(!companiesToUpdate.isEmpty()) {
                try {
                    System.debug('Michael Account_Rollup_Scheduled size of companiesToUpdate is: '+companiesToUpdate.size());
                    Database.SaveResult[] SrList = Database.update(companiesToUpdate, false);
                } catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                    Utilities.sendDebugEmail('Error in AccountRollup Update part: ',e,e.getMessage());   
                    Utilities.sendSlackMessage('Error in AccountRollup Update part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);                     
                }
            }
            if(!accountsToRemoveFlag.isEmpty()){
                //remove the trigger flag
                try {
                    System.debug('Michael Account_Rollup_Scheduled size of companiesToRemoveFlag is: '+accountsToRemoveFlag.size());
                    Database.SaveResult[] SrList = Database.update(accountsToRemoveFlag, false);
                } catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                    Utilities.sendDebugEmail('Error in AccountRollup Update2 part: ',e,e.getMessage());   
                    Utilities.sendSlackMessage('Error in AccountRollup Update2 part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);                     
                }
                //check which companies from the list has parents and update the parents as well
                List<Account>relevantChildAccounts = new List<Account>([SELECT Id,ParentId FROM Account WHERE Id IN:relevantAccounts]);
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