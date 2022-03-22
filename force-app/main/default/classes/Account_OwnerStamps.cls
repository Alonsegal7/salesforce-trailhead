public without sharing class Account_OwnerStamps {
    
    public static Map<Id,User> ownersMap;

    public static void UpdateOwnerStamps(List<Account> newAccounts, map<Id,Account> oldAccounts) {
        List<Account> relevantAccounts = new List<Account>();
        Set<Id> relevantOwners = new Set<Id>();
        for(Account acc: newAccounts){
            if(oldAccounts == null || acc.OwnerId != oldAccounts.get(acc.Id).OwnerId){
                relevantAccounts.add(acc);
                relevantOwners.add(acc.OwnerId);
            }
        }
        if (relevantAccounts.isEmpty() || relevantOwners.isEmpty()) return;
        if (ownersMap == null) {
            ownersMap = new Map<Id,User>();
            for (User u : [SELECT Id, Business_Role__c, Manager.Team__c FROM USER WHERE Id IN: relevantOwners]) {
                ownersMap.put(u.Id, u);
            }
        }
        for (Account acc : relevantAccounts) {
            User currOwner = ownersMap.get(acc.OwnerId);
            if (oldAccounts.get(acc.Id).OwnerId != null) {
                acc.PreviousOwner__c = oldAccounts.get(acc.Id).OwnerId;
            }
            System.debug('Account_OwnerStamps currOwner: '+ currOwner);
            if (currOwner.Business_Role__c != null) {
                String ownerBusinessRole = currOwner.Business_Role__c;
                acc.AM__c = ownerBusinessRole == 'AM' ? acc.OwnerId : null;
                acc.AE__c = ownerBusinessRole == 'AE' ? acc.OwnerId : null;
            }
            acc.Owner_s_Manager_Team__c = currOwner.Manager.Team__c;
        }
    }
}