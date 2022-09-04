public without sharing class Account_SyncPROAssignment {
    public static void Account_SyncPROAssignment(List<Account> newAccounts, Map<Id,Account> oldAccounts) {
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Set<Id> relevantContractsIds = new Set<Id>();
        List<Contract> contractsToUpdate = new List<Contract>();
        for(Account acc: newAccounts){
            if(acc.RecordTypeId == MARecordTypeId && oldAccounts != null && acc.OwnerId != oldAccounts.get(acc.Id).OwnerId && acc.Active_Contract__c!=null){
                relevantContractsIds.add(acc.Active_Contract__c);
            }
        }
        for (Contract con : [select Id from Contract where 
        Id in: relevantContractsIds 
        and (Renewal_Opp_Created_from_Contract__c = false and Primary_Renewal_Owner__c!=null)]) {
            con.Define_Default_PRO_Assignment__c = true;
            contractsToUpdate.add(con);
        }
        if(contractsToUpdate.isEmpty()) return;
        Database.update(contractsToUpdate);
    }
}



