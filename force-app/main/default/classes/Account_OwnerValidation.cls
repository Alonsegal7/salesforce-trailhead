public without sharing class Account_OwnerValidation {

    public static String accountsPoolID_cmt {
        get {
             if (accountsPoolID_cmt == null) {
                accountsPoolID_cmt = [
                    select Value__c 
                    from Environment_Variable__mdt
                    where DeveloperName = 'Accounts_Pool_ID'
                ].Value__c;
             }
             return accountsPoolID_cmt;
        }
        set;
    }

    // runs in before update
    public static void companyOwnerValidation(List<Account> newAcc_lst, Map<Id,Account> oldAcc_map){  
        List<Account> companyOwnerChanged = new List<Account>();
        for(Account acc: newAcc_lst){
            //company owner change
            if(acc.OwnerId != oldAcc_map.get(acc.Id).OwnerId && acc.RecordTypeId == '0121t000000IQTi'){
                companyOwnerChanged.add(acc);
            }
        }
        //we check the condition in 2 steps to prevent the cmt & user query from running on every before update, but only when company owner is changed
        if(companyOwnerChanged.isEmpty()) return; 
        
        
        String userSeniority = [select Seniority__c from User where Id =: UserInfo.getUserId()].Seniority__c;
        User currentUser = [SELECT Id, Seniority__c, Outbound__c, Group__c FROM User WHERE Id =: UserInfo.getUserId()];

        for(Account acc: companyOwnerChanged){
            if (currentUser.Group__c != 'BizOps' && !acc.Owner_Change_Unlock__c) {
                //non accounts pool, global companies ownership change
                if(!acc.Is_Globally_Managed__c && (acc.Account_Territory__c == 'Global' || acc.Account_Territory__c == '' || acc.Account_Territory__c == null)){
                    acc.addError('Global Company Ownership can only be changed by Bizops and according to the policy.');
                }
                //ownership taken from accounts pool
                // else if(oldAcc_map.get(acc.Id).OwnerId == accountsPoolID_cmt){
                //     acc.addError('Taking Company Ownership from Accounts Pool can only be done by Bizops and according to the policy.');
                // }
                //non accounts pool, other companies ownership change - only managers that are not outbound can change ownership 
                // else if(currentUser.Seniority__c == 'Rep' || currentUser.Outbound__c){
                //     acc.addError('Company Ownership can only be changed by Bizops and according to the policy.');
                // }
            }
        }
    }
}