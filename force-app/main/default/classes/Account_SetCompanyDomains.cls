public without sharing class Account_SetCompanyDomains {
    public static void Account_SetCompanyDomains(List<Account> newAccounts, Map<Id,Account> oldAccounts) {
        try{
            Map<String,Company_Domain__c> cdsToCreate = new Map<String,Company_Domain__c>();
            Map<string,Company_Domain__c> existingDomains = new Map<string,Company_Domain__c>();
            List<Account> relevantAccs = new List<Account>();
            List<Company_Domain__c> domainsToDelete = new List<Company_Domain__c>();
            List<Account> accsToUpdate = new List<Account>();

            
            for(Account acc : newAccounts){
                if(acc.RecordTypeId == '0121t000000IQTiAAO' && acc.ParentId == null){ //Company RT and Global Company
                    if(oldAccounts == null && (acc.Account_Domains__c != null || acc.website != null)){//insert
                        relevantAccs.add(acc);
                    }
                    else if(acc.Account_Domains__c != oldAccounts.get(acc.Id).Account_Domains__c ||
                        acc.website != oldAccounts.get(acc.Id).website ||
                        acc.Manual_Trigger__c != oldAccounts.get(acc.Id).Manual_Trigger__c && acc.Manual_Trigger__c == 'Update Company Domains'){//update
                            relevantAccs.add(acc);
                            accsToUpdate.add(new account(Id = acc.Id, Manual_Trigger__c = ''));
                    }
                }
            }

            if(relevantAccs.isEmpty())
                return;

            for(Company_Domain__c cd : [SELECT Id, Domain__c FROM Company_Domain__c WHERE Company__c IN: relevantAccs]){
                existingDomains.put(cd.Domain__c, cd);
            }

            for(Account acc : relevantAccs){
                List<String> cleanDomainsList = new List<String>();

                if(acc.Account_Domains__c != null){//handle domains list
                    cleanDomainsList = acc.Account_Domains__c.replace('[','').replace(']','').replace('"','').split(',');
                    for(String domain : cleanDomainsList){
                        if(domain != '' && domain != null && !existingDomains.containsKey(domain)){
                            cdsToCreate.put(domain, new Company_Domain__c(Domain__c = domain, Company__c = acc.Id, Status__c = 'Active'));
                        }
                    }
                }

                string oldWeb = '';
                if(acc.website != null){//handle website
                    if(!cdsToCreate.containsKey(acc.website) && !existingDomains.containsKey(acc.website)){
                        cdsToCreate.put(acc.website, new Company_Domain__c(Domain__c = acc.website, Company__c = acc.Id, Status__c = 'Active'));
                    }
                        
                    if(oldAccounts != null){//if website changed, remove old website
                        oldWeb = oldAccounts.get(acc.Id).website;
                        if(acc.website != oldWeb && existingDomains.containsKey(oldWeb) && !cleanDomainsList.contains(oldWeb)){
                            domainsToDelete.add(existingDomains.get(oldWeb));
                        }
                    }
                }
            }

            if(!cdsToCreate.values().IsEmpty()){
                Database.insert(cdsToCreate.values(), false);//in case there is a duplicate domain, do not fail all other domains
            }

            if(!domainsToDelete.isEmpty()){
                delete domainsToDelete;
            }

            if(!accsToUpdate.isEmpty()){
                update accsToUpdate;
            }
                
            }catch(Exception e){
            if(!e.getMessage().contains('DUPLICATE_VALUE')) 
                Utilities.sendDebugEmail('Error in Account_SetDomains ', e, e.getMessage());   
        }

    }
}