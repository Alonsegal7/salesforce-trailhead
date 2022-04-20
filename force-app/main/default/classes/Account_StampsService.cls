public with sharing class Account_StampsService {
    
    public static void run(List<Account> newAccounts, map<Id,Account> oldAccounts){
        try {
            // if(oldAccounts == null) getValuesOnCreate(newAccounts);
            UpdateOwnerStamps(newAccounts,oldAccounts);
            handleOngoingUpdates(newAccounts,oldAccounts);
        } catch(Exception e) {
            Utilities.sendDebugEmail('Error in Account_StampsService',e,e.getMessage());
        }
    }

    public static Map<Id,User> usersMap;

    public static void UpdateOwnerStamps(List<Account> newAccounts, map<Id,Account> oldAccounts) {
        
        List<Account> relevantAccountsOwnerChange = new List<Account>();
        List<Account> relevantAccountsCSMChange = new List<Account>();
        Set<Id> relevantUsers = new Set<Id>();
        for(Account acc: newAccounts){
            if(oldAccounts == null || acc.OwnerId != oldAccounts.get(acc.Id).OwnerId){
                relevantAccountsOwnerChange.add(acc);
                relevantUsers.add(acc.OwnerId);
            }
            if (oldAccounts != null && acc.CSM__c == null && oldAccounts.get(acc.Id).CSM__c != null) { //CSM Removed
                acc.CSM_Manager__c = null;
            }
            if(acc.CSM__c != null && (oldAccounts == null || acc.CSM__c != oldAccounts.get(acc.Id).CSM__c)){ //CSM was changed or new account with CSM
                relevantAccountsCSMChange.add(acc);
                relevantUsers.add(acc.CSM__c);
            }
        }
        if (relevantAccountsOwnerChange.isEmpty() && relevantAccountsCSMChange.isEmpty()) return;
        
        if (usersMap == null) {
            usersMap = new Map<Id,User>();
            for (User u : [SELECT Id, Business_Role__c, Manager.Team__c, ManagerId FROM USER WHERE Id IN: relevantUsers]) {
                usersMap.put(u.Id, u);
            }
        }

        //update owner stamps on the relevant accounts
        for (Account acc : relevantAccountsOwnerChange) {
            User currOwner = usersMap.get(acc.OwnerId);
            if (oldAccounts != null && oldAccounts.get(acc.Id).OwnerId != null) {
                acc.PreviousOwner__c = oldAccounts.get(acc.Id).OwnerId;
            }
            System.debug('Account_OwnerStamps currOwner: '+ currOwner);
            if (currOwner != null) {
                if (currOwner.Business_Role__c != null) {
                    String ownerBusinessRole = currOwner.Business_Role__c;
                    acc.AM__c = ownerBusinessRole == 'AM' ? acc.OwnerId : null;
                    acc.AE__c = ownerBusinessRole == 'AE' ? acc.OwnerId : null;
                }
                acc.Owner_s_Manager_Team__c = currOwner.Manager.Team__c;
                acc.Owner_s_Manager__c = currOwner.ManagerId;
            }
        }

        //update CSM stamps on the relevant accounts
        for (Account acc : relevantAccountsCSMChange) {
            User currCSM = usersMap.get(acc.CSM__c);
            acc.CSM_Manager__c = currCSM.ManagerId;
        }
    }

    public static void handleOngoingUpdates(List<Account> newAccounts, map<Id,Account> oldAccounts){ 

        for(Account acc: newAccounts){

            if(acc.Named_Account__c && (oldAccounts == null || (oldAccounts != null && !oldAccounts.get(acc.Id).Named_Account__c))) { //Account marked as named account
                acc.Named_Account_Start_Date__c = Date.today();
            }
            
            if (oldAccounts != null && oldAccounts.get(acc.Id).Named_Account__c && !acc.Named_Account__c) { //Account unmarked as named account
                acc.Named_Account_End_Date__c = Date.today();
            }
        }
    }
}