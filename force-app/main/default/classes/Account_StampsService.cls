public with sharing class Account_StampsService {

    public static void run(List<Account> newAccounts, map<Id,Account> oldAccounts){
        try {
            // if(oldAccounts == null) getValuesOnCreate(newAccounts);
            UpdateOwnerStamps(newAccounts,oldAccounts);
            handleOngoingUpdates(newAccounts,oldAccounts);
            updateCSMAssignmentTimestamp(newAccounts, oldAccounts);
        } catch(Exception e) {
            Utilities.sendDebugEmail('Error in Account_StampsService',e,e.getMessage());
        }
    }

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
        
        
        Map<Id,User> usersMap = new Map<Id,User>([SELECT Id, Group__c, Business_Role__c, Manager.Team__c, ManagerId,Email FROM USER WHERE Id IN: relevantUsers]);

        //update owner stamps on the relevant accounts
        for (Account acc : relevantAccountsOwnerChange) {
            User currOwner = usersMap.get(acc.OwnerId);
            if (oldAccounts != null) {
                acc.PreviousOwner__c = oldAccounts.get(acc.Id).OwnerId;
            }
            System.debug('Account_OwnerStamps currOwner: '+ currOwner);
            if (currOwner != null) {
                if (currOwner.Business_Role__c != null) {
                    String ownerBusinessRole = currOwner.Business_Role__c;
                    acc.AM__c = ownerBusinessRole == 'AM' ? acc.OwnerId : null;
                    acc.AE__c = ownerBusinessRole == 'AE' ? acc.OwnerId : null;
                }
                if (currOwner.Group__c == 'Partners'){
                    acc.Partner__c = acc.OwnerId;
                }
                acc.Owner_s_Manager_Team__c = currOwner.Manager.Team__c;
                acc.Owner_s_Manager__c = currOwner.ManagerId;
                acc.Owner_s_Email__c = currOwner.Email;
                
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
            if (acc.RecordTypeId == Utilities.CompanyRecordTypeId && (oldAccounts == null || acc.NumberOfEmployees != oldAccounts.get(acc.Id).NumberOfEmployees)) {
                acc.Company_Size__c = acc.NumberOfEmployees != null ? Utilities.getCompanySizeRange(acc.NumberOfEmployees) : null;
            }
        }
    }

    /*  before insert & update
        Update CSM_assignment_Timestamp__c when CSM__c is changed (not null) or if record is created with CSM__c --> based on this item:
            https://monday.monday.com/boards/2016847993/pulses/3133829657
        Object: Account
        Fields: CSM__c and CSM_assignment_Timestamp__c
    */
    public static void updateCSMAssignmentTimestamp(List<Account> newAccounts, Map<Id, Account> oldAccounts){

        for(Account acc : newAccounts){
            if((oldAccounts == null || (oldAccounts != null && acc.CSM__c != oldAccounts.get(acc.Id).CSM__c)) && acc.CSM__c != null){
                acc.CSM_assignment_Timestamp__c = System.today();
            }
        }
    }
}