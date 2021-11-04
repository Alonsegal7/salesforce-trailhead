public without sharing class Account_Rollup {
    
    //flag that helps preventing 2 queueable jobs running in the same time, will be checked on the trigger level and changed by other class when queueable is running
    public static Boolean collisionState = false;
    
    public static void Account_Rollup(List<Account> newAccs, Map<Id,Account> oldAccs) {

        //public static Id MondayAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Id CompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Set<Id> relevantCompanies= new Set<Id>();

        //Accounts list used to 1. update flag that will trigger the scheduled job 2. clean the manual trigger flag if exist
        List<Account>accountsToUpdate = new List<Account>();
        
        //Create a subset for which the ARR is changed
        for(Account acc: newAccs){
            if((oldAccs==null||//new account
            acc.ARR__c!=oldAccs.get(acc.Id).ARR__c||//arr changed
            acc.Plan_Seats__c!=oldAccs.get(acc.Id).Plan_Seats__c||//seats changed
            acc.MAPP__c!=oldAccs.get(acc.Id).MAPP__c||//MAPP changed
            acc.WAPP__c!=oldAccs.get(acc.Id).WAPP__c||//WAPP changed
            acc.Members__c!=oldAccs.get(acc.Id).Members__c||//members changed
            acc.Viewers__c!=oldAccs.get(acc.Id).Viewers__c||//viewers changed
            acc.Guests__c!=oldAccs.get(acc.Id).Guests__c||//guests changed
            acc.Internal_Guests__c!=oldAccs.get(acc.Id).Internal_Guests__c||//internal guests changed
            acc.Collection__c!=oldAccs.get(acc.Id).Collection__c||//collection changed
            acc.ParentId!=oldAccs.get(acc.Id).ParentId)&&acc.ParentId!=null){//account hirarchy change
                relevantCompanies.add(acc.ParentId);
                //in case of parent change, also add the old parent account for recalculation
                if(oldAccs!=null&&oldAccs.get(acc.Id).ParentId!=null&&acc.ParentId!=oldAccs.get(acc.Id).ParentId) {
                    relevantCompanies.add(oldAccs.get(acc.Id).ParentId);
                }
            }
        }
        if(relevantCompanies.isempty()){return;}

        for (Id accId : relevantCompanies) {
            accountsToUpdate.add(new Account(Id=accId, Pending_Rollup__c = true));
        }
        try {
            update accountsToUpdate;
            System.debug('Michael - Account_Rollup - updated flag for: '+accountsToUpdate);
        } 
        catch (Exception ex) {
            if(ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW')){
                try {
                    update accountsToUpdate;
                    Utilities.sendSlackMessage('Encountered DML Error in updateAccountRollupFlag, retried and succeeded!: ', 'biz-tech-monitoring', null , ex, ex.getMessage(), null, null);
                } 
                catch (Exception e) {
                    Utilities.sendSlackMessage('Encountered DML Error in updateAccountRollupFlag, retried and failed again: ', 'biz-tech-monitoring', null , e, e.getMessage() + 'Records: '+relevantCompanies, null, null);
                }
            }
            else {
                System.debug('Message: ' + ex.getMessage());
                Utilities.sendSlackMessage('Error in updateAccountRollupFlag: ', 'biz-tech-monitoring', null , ex, ex.getMessage() + 'Records: '+relevantCompanies, null, null);
            }
        }
    }
}