public with sharing class Account_OwnerStamps {
    public static void UpdatePreviousOwner(List<Account> newAccounts, map<Id,Account> oldAccounts) {
        for(Account acc: newAccounts){
            if(acc.OwnerId!=oldAccounts.get(acc.Id).OwnerId){ //Owner change
                acc.PreviousOwner__c=oldAccounts.get(acc.Id).OwnerId;
            }
         }
    }
}
