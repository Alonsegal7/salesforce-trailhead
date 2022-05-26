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
        String query = 'SELECT Id, ParentId FROM Account WHERE Pending_Rollup__c = true AND ParentId != null LIMIT 10000';
        try {
            return Database.getQueryLocator(query);
        }
        catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_Rollup_Scheduled  - getQueryLocator Failed:', e, e.getMessage());
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Account> scope){
        Set<Id> inputAccounts = (new Map<Id,Account>(scope)).keySet();
        try {
            ID jobID = System.enqueueJob(new updateAccountsRollupQueueable(inputAccounts));
            System.debug('Michael - Account_Rollup_Batchable - ' + inputAccounts.size() + ' Accounts Sent to queueable');
            System.debug('Michael - Account_Rollup_Batchable - IDs Sent to queueable: '+ inputAccounts);
            System.debug('JobIDNo: '+jobID);
        } catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            Utilities.sendSlackMessage('Error in AccountRollup Batchable part: ', 'michael-monitoring', null , e, e.getMessage(), null, null);
        }
    }

    public void finish(Database.BatchableContext BC){}

    public class updateAccountsRollupQueueable implements Queueable{
        private Set<Id> inputAccounts;

        public updateAccountsRollupQueueable(Set<Id> inputAccounts){
            this.inputAccounts = inputAccounts;
        }
        public void execute(System.QueueableContext ctx) {
            
            //From the input accounts, create a set of all the parent accounts that requires rollup- will contain 1. inputCompanies and 2. the parents of the inputMAs
            List<Account> inputAccountsList=new List<Account>([SELECT Id,RecordTypeId,ParentId,Pending_Rollup__c FROM Account WHERE Id IN: inputAccounts LIMIT 10000]);
            Set<Id> companiesToRollup = new Set<Id>();
            Id CompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
            Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
            for (Account acc : inputAccountsList) {
                if (acc.recordTypeId == CompanyRecordTypeId) {
                    companiesToRollup.add(acc.Id);
                }
                if (acc.recordTypeId == MARecordTypeId && acc.ParentId != null) {
                    companiesToRollup.add(acc.ParentId);
                }
                acc.Pending_Rollup__c = false;
            }
            if(companiesToRollup.isempty()){return;}

            System.debug('Michael - updateAccountsRollupQueueable - Entered queueable');
            System.debug('Michael - updateAccountsRollupQueueable - '+ inputAccounts.size() + ' input accounts entered. ' + companiesToRollup.size() + ' companies sent to Rollup calculation (input companies + parent companies of input MAs).');
            
            //Rollup calculation- 1. create a map of the companies and their child accounts 2. for each company, sum up the rollup of all the children
            Map<Id, List<Account>> rollupCompaniesWithChildAccounts = new Map<Id, List<Account>>();
            List<Account> childAccounts = [SELECT id, ParentId, ARR__c, Plan_Seats__c, MAPP__c, WAPP__c, Members__c, Viewers__c, Guests__c, Internal_Guests__c, Collection__c FROM Account WHERE ParentId IN:companiesToRollup];
            System.debug('Michael - updateAccountsRollupQueueable - childAccounts '+childAccounts);
            if(childAccounts.isempty()){return;}
            for (Account child : childAccounts) {
                if (rollupCompaniesWithChildAccounts.containsKey(child.ParentId)) {
                    rollupCompaniesWithChildAccounts.get(child.ParentId).add(child);
                }
                else {
                    rollupCompaniesWithChildAccounts.put(child.ParentId,new List<Account>{child});
                }
            }
            List<Account> companiesToUpdate = new List<Account>();
            Decimal updatedArr, updatedSeats, updatedMapp, updatedWapp, updatedMembers, updatedViewers, updatedGuests, updatedInternalGuests, updatedCollection;
            for (Id compId : companiesToRollup) {
                updatedArr = updatedSeats = updatedMapp = updatedWapp = updatedMembers = updatedViewers = updatedGuests = updatedInternalGuests = updatedCollection = 0;
                if(!rollupCompaniesWithChildAccounts.isEmpty()&&rollupCompaniesWithChildAccounts.containsKey(compId)){
                    for (Account childAcc : rollupCompaniesWithChildAccounts.get(compId)) {
                        if (childAcc.ARR__c!=null) {
                            updatedArr+=childAcc.ARR__c;
                        }
                        if (childAcc.Plan_Seats__c!=null) {
                            updatedSeats+=childAcc.Plan_Seats__c;
                        }
                        if (childAcc.MAPP__c!=null) {
                            updatedMapp+=childAcc.MAPP__c;
                        }
                        if (childAcc.WAPP__c!=null) {
                            updatedWapp+=childAcc.WAPP__c;
                        }
                        if (childAcc.Members__c!=null) {
                            updatedMembers+=childAcc.Members__c;
                        }
                        if (childAcc.Viewers__c!=null) {
                            updatedViewers+=childAcc.Viewers__c;
                        }
                        if (childAcc.Guests__c!=null) {
                            updatedGuests+=childAcc.Guests__c;
                        }
                        if (childAcc.Internal_Guests__c!=null) {
                            updatedInternalGuests+=childAcc.Internal_Guests__c;
                        }
                        if (childAcc.Collection__c!=null) {
                            updatedCollection+=childAcc.Collection__c;
                        }
                    }
                }
                companiesToUpdate.add(new Account(
                    Id=compId,
                    ARR__c=updatedArr,
                    Plan_Seats__c=updatedSeats,
                    MAPP__c=updatedMapp,
                    WAPP__c=updatedWapp,
                    Members__c=updatedMembers,
                    Viewers__c=updatedViewers,
                    Guests__c=updatedGuests,
                    Internal_Guests__c=updatedInternalGuests,
                    Collection__c=updatedCollection,
                    Pending_Rollup__c = false));
            }

            //perform the update of the companiesToUpdate which contains the rollup values
            if(!companiesToUpdate.isEmpty()) {
                try {
                    System.debug('Michael Account_Rollup_Scheduled size of companiesToUpdate is: '+companiesToUpdate.size());
                    Database.update(companiesToUpdate, false);
                } catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                    Utilities.sendDebugEmail('Error in AccountRollup Update part: ',e,e.getMessage());   
                    Utilities.sendSlackMessage('Error in AccountRollup Update part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);                     
                }
            }

            //remove the rollup flag - to avoid updating the same account, check which accounts are missing from the companiesToUpdate and update them only
            for (Integer i = (inputAccountsList.size()-1) ; i>= 0 ; i--) {
                if (companiesToRollup.contains(inputAccountsList[i].Id)) {
                    inputAccountsList.remove(i);
                }
            }
            if (!inputAccountsList.isEmpty()) {
                try {
                    System.debug('Michael Account_Rollup_Scheduled size of accounts to remove flag is: '+inputAccountsList.size());
                    Database.update(inputAccountsList, false);
                } catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                    Utilities.sendDebugEmail('Error in AccountRollup accounts to remove flag Update part: ',e,e.getMessage());   
                    Utilities.sendSlackMessage('Error in AccountRollup accounts to remove flag Update part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);                     
                }
            }
            
            //check which companies from the list has parents and update the parents as well
            List<Account>listCompaniesToRollup = new List<Account>([SELECT Id,ParentId FROM Account WHERE Id IN:companiesToRollup LIMIT 10000]);
            Set<Id> relevantParents = new Set<Id>();
            for (Account comp : listCompaniesToRollup) {
                if(comp.ParentId!=null){
                    relevantParents.add(comp.ParentId);
                }
            }
            System.debug('Michael AccountRollup scope for parent queueable - companies: '+listCompaniesToRollup);
            System.debug('Michael AccountRollup scope for parent queueable - parents: '+relevantParents);
            if(!relevantParents.isEmpty()){
                ID parentJobID = System.enqueueJob(new updateAccountsRollupQueueable(relevantParents));
                System.debug('ParentJobIDNo: '+parentJobID);
            }
        }
    }
}