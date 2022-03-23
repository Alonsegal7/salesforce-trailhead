public without sharing class Account_SourceTypeOnOpps {
    public static void updateSourceTypeOnOpps(List<Account> newAccounts, map<Id,Account> oldAccounts) {
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Map<Id,Account> relevantAccounts_map = new Map<Id,Account>();
        for(Account acc: newAccounts){
            if(acc.RecordTypeId == MARecordTypeId && //only for monday accounts
                ((oldAccounts == null && acc.Account_Source_Type__c != null) || (oldAccounts != null && acc.Account_Source_Type__c != oldAccounts.get(acc.Id).Account_Source_Type__c))){
                    relevantAccounts_map.put(acc.Id, acc);
            }
        }
        if (relevantAccounts_map.isEmpty()) return;
        List<Opportunity> oppsToUpdate = [select Id, AccountId from Opportunity where 
                                            AccountId in: relevantAccounts_map.keySet() 
                                            and (Main_Co_Sell_Opportunity__c = true or Co_Sell_Request__c = null or Co_Sell_Request__r.Status__c != 'Approved')];
        if(oppsToUpdate.isEmpty()) return;
        for(Opportunity opp: oppsToUpdate){
            opp.Account_Source_Type__c = relevantAccounts_map.get(opp.AccountId).Account_Source_Type__c;
        }
        Database.update(oppsToUpdate);
    }
}