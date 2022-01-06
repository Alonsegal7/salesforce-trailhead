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
            //ischanged(OwnerId)
            //&& RecordTypeId == '0121t000000IQTi'
            if(acc.OwnerId != oldAcc_map.get(acc.Id).OwnerId && acc.RecordTypeId == '0121t000000IQTi'){
                companyOwnerChanged.add(acc);
            }
        }
        //we check the condition in 2 steps to prevent the cmt & user query from running on every before update, but only when company owner is changed
        if(companyOwnerChanged.isEmpty()) return; 
        
        String userSeniority = [select Seniority__c from User where Id =: UserInfo.getUserId()].Seniority__c;
        for(Account acc: companyOwnerChanged){
            //OwnerId != $CustomMetadata.Environment_Variable__mdt.Accounts_Pool_ID.Value__c
            //&& priorvalue(OwnerId) != $CustomMetadata.Environment_Variable__mdt.Accounts_Pool_ID.Value__c
            //&& ISPICKVAL($User.Seniority__c, 'Rep') 
            if(acc.OwnerId != accountsPoolID_cmt && oldAcc_map.get(acc.Id).OwnerId != accountsPoolID_cmt && userSeniority == 'Rep'){
                acc.addError('Only sales management can change company owners');
            }
        }
    }
}
