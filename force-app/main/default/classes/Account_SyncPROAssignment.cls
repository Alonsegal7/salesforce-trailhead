public without sharing class Account_SyncPROAssignment {
    public static void Account_SyncPROAssignment(List<Account> newAccounts, Map<Id,Account> oldAccounts) {
        Set<Id> contractsIdsForChangeDefualtProAssignemnt = new Set<Id>();
        List<Contract> contractsToUpdate = new List<Contract>();
        for(Account acc: newAccounts){
            if(acc.RecordTypeId == Utilities.MARecordTypeId && oldAccounts != null && acc.OwnerId != oldAccounts.get(acc.Id).OwnerId && acc.Active_Contract__c!=null){
                contractsIdsForChangeDefualtProAssignemnt.add(acc.Active_Contract__c);
            }
        }
        if(contractsIdsForChangeDefualtProAssignemnt.isEmpty()) return;
        date conEndDateQ1 = date.newInstance(2023, 03, 31); 
        for (Contract con : [select Id,Define_Default_PRO_Assignment__c from Contract where Id in: contractsIdsForChangeDefualtProAssignemnt and (Renewal_Opp_Created_from_Contract__c = false AND Primary_Renewal_Owner__c!=null AND EndDate <=:conEndDateQ1)]) 
        {
            con.Define_Default_PRO_Assignment__c = true;
            contractsToUpdate.add(con);
        }
        update(contractsToUpdate);
    }
}



