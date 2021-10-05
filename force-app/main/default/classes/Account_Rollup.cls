public without sharing class Account_Rollup {
    
    //flag that helps preventing 2 queueable jobs running in the same time, will be checked on the trigger level and changed by other class when queueable is running
    public static Boolean collisionState = false;
    
    public static void Account_Rollup(List<Account> newAccs, Map<Id,Account> oldAccs) {

        //public static Id MondayAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Id CompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();


        Set<Id> relevantCompanies= new Set<Id>();
        //Create a subset for which the ARR is changed
        for(Account acc: newAccs){
            if((oldAccs==null||//new account
            acc.ARR__c!=oldAccs.get(acc.Id).ARR__c||//arr changed
            acc.Plan_Seats__c!=oldAccs.get(acc.Id).Plan_Seats__c||//seats changed
            acc.MAPP__c!=oldAccs.get(acc.Id).MAPP__c||//MAPP changed
            acc.WAPP__c!=oldAccs.get(acc.Id).WAPP__c||//members WAPP changed
            acc.Members__c!=oldAccs.get(acc.Id).Members__c||//members members changed
            acc.ParentId!=oldAccs.get(acc.Id).ParentId||//account hirarchy change
            (acc.Manual_Trigger__c!=oldAccs.get(acc.Id).Manual_Trigger__c&&acc.Manual_Trigger__c=='Rollup Company')//manual trigger
            )&&acc.ParentId!=null){
                relevantCompanies.add(acc.ParentId);
                //in case of parent change, also add the old parent account for recalculation
                if(oldAccs!=null&&oldAccs.get(acc.Id).ParentId!=null&&acc.ParentId!=oldAccs.get(acc.Id).ParentId) {
                    relevantCompanies.add(oldAccs.get(acc.Id).ParentId);
                }
                if (acc.Manual_Trigger__c=='Rollup Company') {
                    acc.Manual_Trigger__c='';
                }
            }
        }
        if(relevantCompanies.isempty()){return;}
        ID jobID = System.enqueueJob(new updateAccountsRollup(relevantCompanies));
        System.debug('JobIDNo: '+jobID);
    }
    private class updateAccountsRollup implements Queueable{
        private Set<Id> relevantCompanies;

        public updateAccountsRollup(Set<Id> relevantCompanies){
            this.relevantCompanies = relevantCompanies;
        }
        public void execute(System.QueueableContext ctx) {
            Decimal updatedArr;
            Decimal updatedSeats;
            Decimal updatedMapp;
            Decimal updatedWapp;
            Decimal updatedMembers;

            Map<Id, List<Account>> accountsWithChildAccounts = new Map<Id, List<Account>>();
            List<Account> childrenAccounts = [select id, ParentId, ARR__c, Plan_Seats__c, MAPP__c, WAPP__c, Members__c from Account where ParentId IN:relevantCompanies];
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
            }
            if(!companiesToUpdate.isEmpty()) {
                Database.update(companiesToUpdate);
                //update companiesToUpdate;
            }
        }
    }
}