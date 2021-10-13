public with sharing class DealRegistration_SearchLogic {

    public static Boolean leadExist = false;
    public static List<Contact> existingCon = new List<Contact>();
    public static Set<String> registeredEmail = new Set<String>();
    public static Map<String, Contact> emailToConMap = new Map<String, Contact>();
    public static Boolean existingContact = false;
    public static Boolean isPendingReview = false;

    public static void validateDealRegistration(List<Deal_Registration__c> leadRegList){
        Map<String, Deal_Registration__c> companyWebsiteReg = new Map<String, Deal_Registration__c>();
        List<String> countryMappingDelReg = new List<String>();
        List<String> regionsMappingDelReg = new List<String>();
        List<Account> localCompanyListRegional = new List<Account>();
        List<Account> localCompanyListGlobal = new List<Account>();
        
        Set<Id> companyDomain = new Set<Id>();

        Boolean maAccount = false;
        Boolean localCompany = false;
        Boolean regionalCompany = false;
        Boolean globalCompany = false;
        // Boolean isPendingReview = false;

        for(Deal_Registration__c lReg : leadRegList){
            String stringWebsite = lReg.Company_Website__c;
            String parseWebsite = stringWebsite.replaceFirst('^(https?://)?(www\\.)?', '').split('/')[0];

            companyWebsiteReg.put(parseWebsite, lReg);
            countryMappingDelReg.add(lReg.Company_Location__c);
            regionsMappingDelReg.add(lReg.Region__c);
            registeredEmail.add(lReg.Registered_Email__c);
        }

        for(Contact con : [SELECT Id, Email FROM Contact WHERE Email IN: registeredEmail]){
            emailToConMap.put(con.Email, con);
        }

        if(companyWebsiteReg != null){
            try {
                Map<Id, Company_Domain__c> comDomainMap = new Map<Id, Company_Domain__c>([SELECT Id, Domain__c, Company__c FROM Company_Domain__c WHERE Domain__c IN: companyWebsiteReg.keySet() LIMIT 1]);
                if(!comDomainMap.isEmpty()){
                    for(Company_Domain__c comDomainList : comDomainMap.values()){
                        companyDomain.add(comDomainMap.get(comDomainList.Id).Company__c);
                    }
                    
                    if(companyDomain != null){
                        List<Account> globalAccount = queryGlobalAccounts(companyDomain);
                        List<Account> mondayAccounts = queryMondayAccounts(companyDomain, countryMappingDelReg[0]);
                        List<Account> regionalCompanyAccounts = queryRegionalAccounts(companyDomain, regionsMappingDelReg);
                        if(mondayAccounts.isEmpty() || mondayAccounts.size() == 0 || mondayAccounts == null){
                            maAccount = true;
                        }
                        system.debug('### maAccount_v1: ' + maAccount);
                        if(regionalCompanyAccounts.isEmpty() || regionalCompanyAccounts.size() == 0 || regionalCompanyAccounts == null){
                            regionalCompany = true;
                        }
                        system.debug('### regionalCompany: ' + regionalCompany);
                        system.debug('### countryMappingDelReg[0]: ' + countryMappingDelReg[0]);
                        system.debug('### regionalCompanyAccounts: ' + regionalCompanyAccounts);
                        if(!regionalCompanyAccounts.isEmpty() && regionalCompanyAccounts.size() > 0 && regionalCompanyAccounts != null){
                            system.debug('### in empty: ');
                            localCompanyListRegional = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry, ParentId
                                                        FROM Account 
                                                        WHERE ParentId IN: regionalCompanyAccounts AND RecordType.DeveloperName = 'Company' AND BillingCountry =: countryMappingDelReg[0]];
                        }
                        system.debug('### localCompanyListRegional: ' + localCompanyListRegional);
                        if(localCompanyListRegional.isEmpty()){
                            system.debug('### in not empty: ');
                            localCompanyListGlobal = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry, ParentId
                                                    FROM Account 
                                                    WHERE ParentId IN: globalAccount AND RecordType.DeveloperName = 'Company' AND BillingCountry =: countryMappingDelReg[0]];
                        }
                        
                        if((localCompanyListRegional.isEmpty() || localCompanyListRegional.size() == 0 || localCompanyListRegional == null) &&
                            (localCompanyListGlobal.isEmpty() || localCompanyListGlobal.size() == 0 || localCompanyListGlobal == null)){
                            localCompany = true;
                        }
                        system.debug('### localCompany: ' + localCompany);
                        // List<Account> localCompanyAccounts = new List<Account>();
                        List<Lead> relatedLeadCompany = [SELECT Id, Name, CreatedDate, Related_Company__c, Created_Lead_Month__c FROM Lead WHERE Related_Company__c IN: companyDomain AND Created_Lead_Month__c <= 30 AND Status != 'Nurturing' AND Status != 'Qualified'];
                        if(relatedLeadCompany.isEmpty() || relatedLeadCompany.size() == 0 || relatedLeadCompany == null){
                            leadExist = true;
                        }
                        
                        if(maAccount == false){
                            system.debug('### ### maAccount:' + maAccount);
                            system.debug('### mondayAccounts List:' + mondayAccounts);
                            isPendingReview = checkPendingAccount(mondayAccounts, companyWebsiteReg, countryMappingDelReg); //List<Account>, Map<String,Lead_Reg>, List<String>
                            system.debug('### ### isPendingReview:' + isPendingReview);
                            for(Account maAcc : mondayAccounts){
                                for(Deal_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### ### localCompanyListRegional:' + localCompanyListRegional);
                                    system.debug('### ### regionalCompanyAccounts:' + regionalCompanyAccounts);
                                    if(localCompanyListRegional != null && !localCompanyListRegional.isEmpty() && localCompanyListRegional.size() > 0){
                                        leadReg.Local_Company__c = localCompanyListRegional[0].Id;
                                        system.debug('### ### leadReg.Local_Company__c:' + leadReg.Local_Company__c);
                                    }

                                    if(regionalCompanyAccounts != null && !regionalCompanyAccounts.isEmpty() && regionalCompanyAccounts.size() > 0){
                                        leadReg.Regional_Company__c = regionalCompanyAccounts[0].Id;
                                        system.debug('### ### leadReg.Regional_Company__c:' + leadReg.Regional_Company__c);
                                    }

                                    leadReg.Global_Company__c = globalAccount[0].Id;
                                    system.debug('### ### leadReg.Global_Company__c:' + leadReg.Global_Company__c);
                                }
                            }

                            if(isPendingReview == false){ //check local
                                if(localCompanyListRegional != null && !localCompanyListRegional.isEmpty() && localCompanyListRegional.size() > 0){
                                    localRegionalCompanyChecking(localCompanyListRegional, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id); //Map(website, dealReg), List(Country)
                                }
        
                                else if(!localCompanyListGlobal.isEmpty() && localCompanyListGlobal != null && localCompanyListGlobal.size() > 0){
                                    localGlobalCompanyChecking(localCompanyListGlobal, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                                }
                            }

                            if(isPendingReview == false && regionalCompany == false){ //check regional
                                regionalCompanyChecking(regionalCompanyAccounts, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                            }

                            if(isPendingReview == false){ //check global
                                globalCompanyChecking(globalAccount, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                            }
                        }

                        else if(maAccount == true && localCompany == false){
                            if(localCompanyListRegional != null && !localCompanyListRegional.isEmpty() && localCompanyListRegional.size() > 0){
                                localRegionalCompanyChecking(localCompanyListRegional, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                            }

                            else if(!localCompanyListGlobal.isEmpty() && localCompanyListGlobal != null && localCompanyListGlobal.size() > 0){
                                localGlobalCompanyChecking(localCompanyListGlobal, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                            }

                            if(isPendingReview == false && regionalCompany == false){ //check regional
                                regionalCompanyChecking(regionalCompanyAccounts, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                            }

                            if(isPendingReview == false){ //check global
                                globalCompanyChecking(globalAccount, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                            }
                        }

                        else if(maAccount == true && localCompany == true && regionalCompany == false){
                            regionalCompanyChecking(regionalCompanyAccounts, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);

                            if(isPendingReview == false){
                                globalCompanyChecking(globalAccount, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                            }
                        }

                        else if(maAccount == true && localCompany == true && regionalCompany == true && globalCompany == false){
                            globalCompanyChecking(globalAccount, companyWebsiteReg, countryMappingDelReg, globalAccount[0].Id);
                        }

                        //Looking for related Leads
                        for(Deal_Registration__c leadReg : companyWebsiteReg.values()){
                            leadReg.Status__c = 'Pending Review'; //Ksenia - attemp to solve empty status scenarios
                            //finding and conecting duplicate contact
                            if(!emailToConMap.isEmpty() && emailToConMap.containsKey(leadReg.Registered_Email__c)){
                                leadReg.Related_Contact__c = emailToConMap.get(leadReg.Registered_Email__c).Id;
                                leadReg.Status__c = 'Pending Review';
                            }

                            //No Related Account was found
                            if(leadReg.Related_Account__c == null){
                                if(leadExist == false){
                                    for(Lead l : relatedLeadCompany){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Lead__c = l.Id;
                                    }
                                }

                                //after completing all the resaearch for all the Accounts and Lead -> update the Deal Reg Status
                                else{
                                    if(leadReg.Company_Size__c != '1500+' && leadReg.Related_Contact__c == null){
                                        leadReg.Status__c = 'Approved';
                                        leadReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                                    }
            
                                    else if(leadReg.Company_Size__c == '1500+'){
                                        leadReg.Status__c = 'Pending Review';
                                    }
                                }
                                
                            }
                        }
                    }
                }

                //if no Domain exists --> no Account exists --> no need to search
                else{
                    for(Deal_Registration__c lReg : companyWebsiteReg.values()){
                        lReg.Status__c = 'Pending Review'; //Ksenia - attemp to solve empty status scenarios
                        if((!emailToConMap.isEmpty() && emailToConMap.containsKey(lReg.Registered_Email__c)) || lReg.Company_Size__c == '1500+'){
                            lReg.Related_Contact__c = emailToConMap.get(lReg.Registered_Email__c).Id;
                            lReg.Status__c = 'Pending Review';
                        }

                        else if(lReg.Company_Size__c != '1500+'  && lReg.Related_Contact__c == null){
                            lReg.Status__c = 'Approved';
                            lReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                        }
                    }
                }
            }

            catch(Exception e){
                Utilities.sendDebugEmail('Error in DealRegistration_SearchLogic line 210:  ', e, e.getMessage());
            }
            
        }
    }

    //Help methods
    public static List<Account> queryGlobalAccounts(Set<Id> companyDomain){
        List<Account> globalAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c FROM Account WHERE Id IN: companyDomain AND RecordType.DeveloperName = 'Company' LIMIT 1];
        return globalAccounts;
    }

    public static List<Account> queryMondayAccounts(Set<Id> companyDomain, String countryMappingDelReg){
        Id mondayAccounyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        List<Account> mondayAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry, Parent.BillingCountry, Parent.ParentId, ParentId
                                        FROM Account
                                        WHERE Company__c IN: companyDomain AND RecordTypeId =: mondayAccounyId AND BillingCountry =: countryMappingDelReg];//monday account with Global company Parent
        system.debug('### mondayAccounts: ' + mondayAccounts);
        return mondayAccounts;
    }

    public static List<Account> queryRegionalAccounts(Set<Id> companyDomain, List<String> regionsMappingDelReg){
        List<Account> regionalCompanyAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Region__c, Owner.Function__c, ParentId
                                                FROM Account
                                                WHERE ParentId IN: companyDomain AND RecordType.DeveloperName = 'Company' AND Region__c IN: regionsMappingDelReg AND Account_Territory__c =: 'Regional']; //regional company with Global Parent
        system.debug('### regionsMappingDelReg_v1: ' + regionsMappingDelReg);
        return regionalCompanyAccounts;
    }

    public static Boolean checkPendingAccount(List<Account> accounts,  Map<String, Deal_Registration__c> dealRegistration, List<String> countryRegionMapping){
        system.debug('### checkPendingAccount: ');
        Boolean isPending = false;
        for(Account acc : accounts){
            for(Deal_Registration__c leadReg : dealRegistration.values()){
                system.debug('### Account Id: ' + acc.Id);
                system.debug('### Account Name: ' + acc.Name);
                system.debug('### Function: ' + acc.Owner.Function__c);
                if(acc.Owner.Name == 'Accounts Pool' || (acc.Owner.Function__c != 'Mid-Market AM' && acc.Owner.Function__c != 'Mid-Market AE' &&
                    acc.Owner.Function__c != 'Enterprise AM' && acc.Owner.Function__c != 'Enterprise AE' && acc.Owner.Function__c != 'Partner')){
                        system.debug('### NOT Function');
                }

                else if(acc.Owner.Function__c == 'Mid-Market AM' || acc.Owner.Function__c == 'Mid-Market AE' ||
                        acc.Owner.Function__c == 'Enterprise AM' || acc.Owner.Function__c == 'Enterprise AE' || acc.Owner.Function__c == 'Partner'){
                    system.debug('### IS Function');
                    leadReg.Status__c = 'Pending Review';
                    system.debug('### leadReg.Related_Account__c: ' + leadReg.Related_Account__c);
                    if(leadReg.Related_Account__c == null){
                        system.debug('### leadReg.Related_Account__c_v2: ' + leadReg.Related_Account__c);
                        leadReg.Related_Account__c = acc.Id;
                    }
                    
                    isPending = true;
                }
            }
        }
        return isPending;
    }

    public static void localRegionalCompanyChecking(List<Account> accounts, Map<String, Deal_Registration__c> dealRegistration, List<String> countryRegionMapping, Id globalAcc){
        isPendingReview = checkPendingAccount(accounts, dealRegistration, countryRegionMapping);
        populateAllRelatedAccounts(accounts, dealRegistration, globalAcc);
    }

    public static void localGlobalCompanyChecking(List<Account> accounts, Map<String, Deal_Registration__c> dealRegistration, List<String> countryRegionMapping, Id globalAcc){
        isPendingReview = checkPendingAccount(accounts, dealRegistration, countryRegionMapping);
        populateLocalGlobalAccounts(accounts, dealRegistration, globalAcc);
    }

    public static void regionalCompanyChecking(List<Account> accounts, Map<String, Deal_Registration__c> dealRegistration, List<String> countryRegionMapping, Id globalAcc){
        isPendingReview = checkPendingAccount(accounts, dealRegistration, countryRegionMapping);
        populateRegionalGlobalAccounts(accounts, dealRegistration, globalAcc);
    }

    public static void globalCompanyChecking(List<Account> accounts, Map<String, Deal_Registration__c> dealRegistration, List<String> countryRegionMapping, Id globalAcc){
        isPendingReview = checkPendingAccount(accounts, dealRegistration, countryRegionMapping);
        populateGlobalAccounts(accounts, dealRegistration, globalAcc);
    }

    public static void populateAllRelatedAccounts(List<Account> accounts, Map<String, Deal_Registration__c> dealRegistration, Id globalAcc){
        try{
            for(Account localAccount : accounts){
                for(Deal_Registration__c leadReg : dealRegistration.values()){
                    leadReg.Regional_Company__c = localAccount.ParentId;
                    leadReg.Local_Company__c = localAccount.Id;
                    leadReg.Global_Company__c = globalAcc;
                }
            }
        }
        catch(Exception e){
            Utilities.sendDebugEmail('Error in DealRegistration_SearchLogic line 316:  ', e, e.getMessage());
        }
    }

    public static void populateLocalGlobalAccounts(List<Account> accounts, Map<String, Deal_Registration__c> dealRegistration, Id globalAcc){
        try{
            for(Account localAccount : accounts){
                for(Deal_Registration__c leadReg : dealRegistration.values()){
                    leadReg.Local_Company__c = localAccount.Id;
                    leadReg.Global_Company__c = globalAcc;
                }
            }
        }
        
        catch(Exception e){
            Utilities.sendDebugEmail('Error in DealRegistration_SearchLogic line 332:  ', e, e.getMessage());
        }
    }
    
    public static void populateRegionalGlobalAccounts(List<Account> accounts, Map<String, Deal_Registration__c> dealRegistration, Id globalAcc){
        try{
            for(Account localAccount : accounts){
                for(Deal_Registration__c leadReg : dealRegistration.values()){
                    leadReg.Regional_Company__c = localAccount.Id;
                    leadReg.Global_Company__c = globalAcc;
                }
                
            }
        }
        
        catch(Exception e){
            Utilities.sendDebugEmail('Error in DealRegistration_SearchLogic line 349:  ', e, e.getMessage());
        }
    }

    public static void populateGlobalAccounts(List<Account> accounts, Map<String, Deal_Registration__c> dealRegistration, Id globalAcc){
        try{
            for(Account localAccount : accounts){
                for(Deal_Registration__c leadReg : dealRegistration.values()){
                    leadReg.Global_Company__c = globalAcc;
                }
            }
        }
        
        catch(Exception e){
            Utilities.sendDebugEmail('Error in DealRegistration_SearchLogic line 364:  ', e, e.getMessage());
        }
    }
}