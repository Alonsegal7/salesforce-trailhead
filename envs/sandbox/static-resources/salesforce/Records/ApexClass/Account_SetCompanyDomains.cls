public without sharing class Account_SetCompanyDomains {
    public static void Account_SetCompanyDomains(List<Account> newAccounts, map<Id,Account> oldAccounts) {
        try{
            map<String,Company_Domain__c> cdsToCreate= new map<String,Company_Domain__c>();
            map<string,Company_Domain__c> currentDomains= new map<string,Company_Domain__c>();
            list<Account> relevantAccs= new list<Account>();
            list<Company_Domain__c> domainsToDelete= new list<Company_Domain__c>();

            for(Company_Domain__c cd: [select id,Domain__c from Company_Domain__c where Company__c in:newAccounts]){
                currentDomains.put(cd.Domain__c,cd);
            }
            for(Account acc: newAccounts){
                if(acc.RecordTypeId=='0121t000000IQTiAAO'){
                    if(oldAccounts==null&&(acc.Account_Domains__c!=null||acc.website!=null))//insert
                        relevantAccs.add(acc);
                    else if(acc.Account_Domains__c!=oldAccounts.get(acc.Id).Account_Domains__c||
                            acc.website!=oldAccounts.get(acc.Id).website||
                            acc.Manual_Trigger__c!=oldAccounts.get(acc.Id).Manual_Trigger__c&&acc.Manual_Trigger__c=='Update Company Domains'){
                        relevantAccs.add(acc);
                   }
                }
            }
            if(relevantAccs.isEmpty())
                return;

            for(Account acc: relevantAccs){
                list<String> cleanDomainsList= new list<String>();
                if(acc.Account_Domains__c!=null){//handle domains list
                    cleanDomainsList=acc.Account_Domains__c.replace('[','').replace(']','').replace('"','').split(',');
                    for(String domain: cleanDomainsList){
                        if(!currentDomains.containsKey(domain))
                            cdsToCreate.put(domain,new Company_Domain__c(Domain__c=domain,Company__c=acc.Id));
                    }
                }
                string oldWeb='';
                if(acc.website!=null){//handle website
                    if(!cdsToCreate.containsKey(acc.website)&&!currentDomains.containsKey(acc.website))
                        cdsToCreate.put(acc.website,new Company_Domain__c(Domain__c=acc.website,Company__c=acc.Id));
                    if(oldAccounts!=null)//if website changed, remove old website
                        oldWeb=oldAccounts.get(acc.Id).website;
                        if(acc.website!=oldWeb&&currentDomains.containsKey(oldWeb)&&!cleanDomainsList.contains(oldWeb))
                            domainsToDelete.add(currentDomains.get(oldWeb));
                }
            }
            if(!cdsToCreate.values().IsEmpty())
                Database.insert(cdsToCreate.values(), false);//in case there is a duplicate domain, do not fail all other domains
            if(!domainsToDelete.isEmpty())
                delete domainsToDelete;
            }catch(Exception e){
            if(!e.getMessage().contains('DUPLICATE_VALUE')) 
                Utilities.sendDebugEmail('Error in Account_SetDomains ',e,e.getMessage());   
        }

    }
}