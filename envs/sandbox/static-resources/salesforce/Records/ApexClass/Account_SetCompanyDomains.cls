public without sharing class Account_SetCompanyDomains {
    public static void Account_SetCompanyDomains(List<Account> newAccounts, map<Id,Account> oldAccounts) {
        try{
            list<Company_Domain__c> cdsToCreate= new list<Company_Domain__c>();
            for(Account acc: newAccounts){
                if(acc.RecordTypeId=='0121t000000IQTiAAO'&&acc.Account_Domains__c!=null){
                    list<String> cleanDomainsList=acc.Account_Domains__c.replace('[','').replace(']','').replace('"','').split(',');
                    for(String domain: cleanDomainsList){
                        cdsToCreate.add(new Company_Domain__c(Domain__c=domain,Company__c=acc.Id));
                    }
                    cdsToCreate.add(new Company_Domain__c(Domain__c=acc.website,Company__c=acc.Id));
                } 
            }
            if(!cdsToCreate.IsEmpty())
                insert cdsToCreate;
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_SetDomains ',e,e.getMessage());   
        }

    }
}