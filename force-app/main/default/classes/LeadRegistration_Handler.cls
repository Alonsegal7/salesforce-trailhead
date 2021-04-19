public with sharing class LeadRegistration_Handler {
    static Map<String, Country_Region_Mapping__c> regionsMapping = null;
    static Boolean isPendingReview = false;

    static Boolean maAccount = false;
    static Boolean localCompany = false;
    static Boolean regionalCompany = false;
    static Boolean globalCompany = false;
    static Boolean leadExist = false;

    static List<Account> realtedLocalCompany = null;
    static List<Account> realtedRegionalCompany = null;
    
    public static void isBeforeInsert(List<Lead_Registration__c> newLeadRegs, Map<Id, Lead_Registration__c> oldLeadRegs){
        leadReg_MapRegions(newLeadRegs, oldLeadRegs);
    }

    public static void isBeforeUpdate(List<Lead_Registration__c> newLeadRegs, Map<Id, Lead_Registration__c> oldLeadRegs){
        updateTimestamps(newLeadRegs, oldLeadRegs);
    }

    public static List<Account> updateRelatedCompany(Account relatedAcc, Lead_Registration__c lReg){
        List<Account> newAcc = new List<Account>();
        relatedAcc.Lead_Registration__c = lReg.Id;
        newAcc.add(relatedAcc);

        return newAcc;
    }

    public static List<Account> createRelatedCompany(Lead_Registration__c lReg){
        List<Account> newAcc = new List<Account>();

        Account acc = new Account();
        acc.Name = lReg.Company__c;
        acc.Lead_Registration__c = lReg.Id;
        acc.RecordTypeId = '0121t000000IQTiAAO';
        if(lReg.Regional_Company__c != null){
            acc.ParentId = lReg.Regional_Company__c;
            acc.BillingCountry = lReg.Location__c;
            acc.Account_Territory__c = 'Local';
        }

        else if(lReg.Global_Company__c != null){
            acc.ParentId = lReg.Global_Company__c;
            acc.BillingCountry = lReg.Location__c;
            acc.Account_Territory__c = 'Local';
        }
        newAcc.add(acc);

        return newAcc;
    }

    public static void isAfterInsert(List<Lead_Registration__c> newLeadRegs, Map<Id, Lead_Registration__c> oldLeadRegs){
        system.debug('### test after:');
        Map<String, Lead_Registration__c> convertCreation = new Map<String, Lead_Registration__c>();
        Map<Account, Lead_Registration__c> accountReg = new Map<Account, Lead_Registration__c>();
        Map<String, Account> countryString = new Map<String, Account>();
        Map<Account, Lead_Registration__c> leadRegAccount = new Map<Account, Lead_Registration__c>();
        List<Account> newAccount = new List<Account>();
        List<Lead> newLead = new List<Lead>();
        Boolean isApproved = false;
        Boolean updateAccount = false;
        Account relatedAcc = new Account();

        for(Lead_Registration__c lReg : newLeadRegs){
            if(lReg.Status__c == 'Approved'){
                isApproved = true;
            }

            if(lReg.Local_Company__c != null){
                relatedAcc = [SELECT Id, Lead_Registration__c FROM Account WHERE Id =: lReg.Local_Company__c LIMIT 1];
            }
        }
        system.debug('### isApproved: ' + isApproved);
        system.debug('### realtedLocalCompany: ' + realtedLocalCompany);
    
        if(oldLeadRegs == null){ //if Insert
            if(isApproved == true){
                for(Lead_Registration__c lReg : newLeadRegs){
                    if(lReg.Local_Company__c != null){
                        newAccount = updateRelatedCompany(relatedAcc, lReg);
                        // relatedAcc.Lead_Registration__c = lReg.Id;
                        // newAcc.add(relatedAcc);
                        leadRegAccount.put(newAccount[0], lReg);
                        updateAccount = true;
                    }

                    else{
                        newAccount = createRelatedCompany(lReg);
                        // Account acc = new Account();
                        // acc.Name = lReg.Company__c;
                        // acc.Lead_Registration__c = lReg.Id;
                        // acc.RecordTypeId = '0121t000000IQTiAAO';
                        // newAccount.add(acc);
                        leadRegAccount.put(newAccount[0], lReg);
                        updateAccount = false;
                    }
                }

                if(newAccount != null && updateAccount == true){
                    update newAccount;
                    system.debug('### Inserted Account Id_v1 = ' +newAccount);
                }

                else if(newAccount != null && updateAccount == false){
                    insert newAccount;
                    system.debug('### Inserted Account Id_v2 = ' +newAccount);
                }

                for(Lead_Registration__c lRegRec : newLeadRegs){

                    Lead l = new Lead();
                    l.LastName = lRegRec.First_Name__c;
                    l.Lead_Registration__c = lRegRec.Id;
                    l.Company = lRegRec.Company__c;
                    l.Company_Size__c = lRegRec.Company_Size__c;
                    l.Email = lRegRec.Registered_Email__c;
                    l.LeadSource = 'Deal Reg';
                    l.RecordTypeId = '0121t000000IQTEAA4'; // create partner lead
                    l.Related_Company__c = newAccount[0].Id;
                    l.Title = lRegRec.Title__c;
                    l.Country = lRegRec.Location__c;
                    newLead.add(l);
                }

                if(newLead != null){
                    insert newLead;
                    system.debug('### Inserted Lead Id = ' +newLead);
    
                    List<Lead> leads = [SELECT Id FROM Lead WHERE Id IN: newLead];
                    List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                    for(Lead l : leads){
                        Database.LeadConvert tempLC = new Database.LeadConvert();
                        tempLC.setLeadId(l.Id);
                        tempLC.setConvertedStatus(convertStatus.MasterLabel);
                        tempLC.setOpportunityName('Test Opp');
                        leadsToConvert.add(tempLC);
                    }
                    List<Database.LeadConvertResult> lc = Database.convertLead(leadsToConvert);
                    for(Database.LeadConvertResult lctemp : lc){
                        system.debug('### getAccountId: ' + lctemp.getAccountId());
                        system.debug('### getContactId' + lctemp.getContactId());
                        system.debug('### getContactId' + lctemp.getOpportunityId());
                    }
                }
            }
        }

        else if (oldLeadRegs != null){
            for(Lead_Registration__c lReg : newLeadRegs){
                if(lReg.Status__c != oldLeadRegs.get(lReg.Id).Status__c && isApproved == true){
                    if(lReg.Local_Company__c != null){
                        relatedAcc.Lead_Registration__c = lReg.Id;
                        newAccount.add(relatedAcc);
                        leadRegAccount.put(newAccount[0], lReg);
                        updateAccount = true;
                    }

                    else{
                        newAccount = createRelatedCompany(lReg);
                        // Account acc = new Account();
                        // acc.Name = lReg.Company__c;
                        // acc.Lead_Registration__c = lReg.Id;
                        // acc.RecordTypeId = '0121t000000IQTiAAO';
                        // newAccount.add(acc);
                        leadRegAccount.put(newAccount[0], lReg);
                        updateAccount = false;
                    }
                }
            }

            if(newAccount != null && updateAccount == true){
                update newAccount;
                system.debug('### updated Account Id_v1 = ' +newAccount);
            }

            if(newAccount != null && updateAccount == false){
                insert newAccount;
                system.debug('### updated Account Id_v2 = ' +newAccount);
            }

            for(Lead_Registration__c lRegRec : newLeadRegs){
                Lead l = new Lead();
                l.LastName = lRegRec.First_Name__c;
                l.Lead_Registration__c = lRegRec.Id;
                l.Company = lRegRec.Company__c;
                l.Company_Size__c = lRegRec.Company_Size__c;
                l.Email = lRegRec.Registered_Email__c;
                l.LeadSource = 'Deal Reg';
                l.RecordTypeId = '0121t000000IQTEAA4'; // create partner lead
                l.Related_Company__c = newAccount[0].Id;
                l.Title = lRegRec.Title__c;
                l.Country = lRegRec.Location__c;
                newLead.add(l);
            }

            if(newLead != null){
                insert newLead;
                system.debug('### Inserted Lead Id = ' +newLead);

                List<Lead> leads = [SELECT Id FROM Lead WHERE Id IN: newLead];
                List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                for(Lead l : leads){
                    Database.LeadConvert tempLC = new Database.LeadConvert();
                    tempLC.setLeadId(l.Id);
                    tempLC.setConvertedStatus(convertStatus.MasterLabel);
                    tempLC.setOpportunityName('Test Opp');
                    leadsToConvert.add(tempLC);
                }
                List<Database.LeadConvertResult> lc = Database.convertLead(leadsToConvert);
                for(Database.LeadConvertResult lctemp : lc){
                    system.debug('### getAccountId: ' + lctemp.getAccountId());
                    system.debug('### getContactId' + lctemp.getContactId());
                    system.debug('### getContactId' + lctemp.getOpportunityId());
                }
            }
        }
    }


    public static void leadReg_MapRegions(List<Lead_Registration__c> newLeadRegs, Map<Id, Lead_Registration__c> oldLeadRegs) {
        try{
            Map<String, Country_Region_Mapping__c> regionsMapping = getRegionMapping(newLeadRegs);
            List<Lead_Registration__c> leadRegToCheck = new List<Lead_Registration__c>();
            for(Lead_Registration__c lReg : newLeadRegs){
                String region='';
                
                if(oldLeadRegs == null || (lReg.Manual_Trigger__c != oldLeadRegs.get(lReg.Id).Manual_Trigger__c && lReg.Manual_Trigger__c == 'Match Regions')){
                    if(regionsMapping.containskey(lReg.Location__c)){
                        region = regionsMapping.get(lReg.Location__c).Region__c;
                    }
                    
                    else{
                        region='';
                    }

                    lReg.Region__c = region;
                    
                    if(lReg.Manual_Trigger__c == 'Match Regions'){
                        lReg.Manual_Trigger__c = '';
                    }
                }
                leadRegToCheck.add(lReg);
            }

            if(oldLeadRegs == null){
                validateLeadRegistration_Test(leadRegToCheck);
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Lead_MapRegions ', e, e.getMessage());   
        }
    }

    public static void leadReg_MapRegions_Test(List<Lead_Registration__c> newLeadRegs) {
        try{
            Map<String, Country_Region_Mapping__c> regionsMapping = getRegionMapping(newLeadRegs);
            List<Lead_Registration__c> leadRegToCheck = new List<Lead_Registration__c>();
            for(Lead_Registration__c lReg : newLeadRegs){
                String region='';
                if(regionsMapping.containskey(lReg.Location__c)){
                    region = regionsMapping.get(lReg.Location__c).Region__c;
                }
                
                else{
                    region='';
                }

                lReg.Region__c = region;
                
                if(lReg.Manual_Trigger__c == 'Match Regions'){
                    lReg.Manual_Trigger__c = '';
                }
                leadRegToCheck.add(lReg);
            }

            validateLeadRegistration_Test(leadRegToCheck);
            
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Lead_MapRegions ', e, e.getMessage());   
        }
    }

    public static Map<String, Country_Region_Mapping__c> getRegionMapping(List<Lead_Registration__c> newLeadRegs){
        List<String> leadRegCountry = new List<String>();

        if(regionsMapping == null){
            regionsMapping = new Map<String,Country_Region_Mapping__c>();
            for(Lead_Registration__c lReg : newLeadRegs){
                leadRegCountry.add(lReg.Location__c);
            }
            
            if(leadRegCountry != null){
                for(Country_Region_Mapping__c rm : [SELECT Id, Name, Region__c, Country_Name__c FROM Country_Region_Mapping__c WHERE Country_Name__c IN: leadRegCountry]){
                    regionsMapping.put(rm.Country_Name__c, rm);
                }
            }
        }
        return regionsMapping;
    }

    /*public static Boolean checkPendingAccount(List<Account> accounts, List<String> countryRegionMapping, Map<String, Lead_Registration__c> dealRegistration){
        for(Account maAcc : mondayAccounts){
            for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                if(isPendingReview == false && maAcc.BillingCountry == countryMappingDelReg[0]){
                    system.debug('### Function__c: ' + maAcc.Owner.Function__c);
                    if(maAcc.Owner.Name == 'Accounts Pool' || (maAcc.Owner.Function__c != 'Mid-Market AM' && maAcc.Owner.Function__c != 'Mid-Market AE' &&
                        maAcc.Owner.Function__c != 'Enterprise AM' && maAcc.Owner.Function__c != 'Enterprise AE')){
                            maAccount = true;
                            
                            system.debug('### maAccount: ' + maAccount);
                    }

                    else if(maAcc.Owner.Function__c == 'Mid-Market AM' || maAcc.Owner.Function__c == 'Mid-Market AE' ||
                            maAcc.Owner.Function__c == 'Enterprise AM' || maAcc.Owner.Function__c == 'Enterprise AE'){
                        leadReg.Status__c = 'Pending Review';
                        leadReg.Related_Company__c = maAccId;
                        isPendingReview = true;
                    }
                }
            }
        }
    }*/

    public static void validateLeadRegistration_Test(List<Lead_Registration__c> leadRegList){
        Map<String, Lead_Registration__c> companyWebsiteReg = new Map<String, Lead_Registration__c>();
        List<String> countryMappingDelReg = new List<String>();
        List<String> regionsMappingDelReg = new List<String>();
        List<Account> localCompanyListRegional = new List<Account>();
        List<Account> localCompanyListGlobal = new List<Account>();
        List<Account> local = new List<Account>();
        
        Set<Id> companyDomain = new Set<Id>();
        Set<Id> relatedAccounts = new Set<Id>();

        Boolean maAccount = false;
        Boolean localCompany = false;
        Boolean regionalCompany = false;
        Boolean globalCompany = false;
        Boolean isPendingReview = false;

        Integer counter = 0;
        Integer accountQuerySize = 0;

        for(Lead_Registration__c lReg : leadRegList){
            String stringWebsite = lReg.Company_Website__c;
            String parseWebsite = stringWebsite.replaceFirst('^(https?://)?(www\\.)?', '').split('/')[0];

            companyWebsiteReg.put(parseWebsite, lReg);
            countryMappingDelReg.add(lReg.Location__c);
            regionsMappingDelReg.add(lReg.Region__c);
            system.debug('### countryMappingDelReg: ' + countryMappingDelReg);
            system.debug('### regionsMappingDelReg: ' + regionsMappingDelReg);
        } 

        if(companyWebsiteReg != null){
            Map<Id, Company_Domain__c> comDomainMap = new Map<Id, Company_Domain__c>([SELECT Id, Domain__c, Company__c FROM Company_Domain__c WHERE Domain__c IN: companyWebsiteReg.keySet()]);
            system.debug('### comDomainMap: ' + comDomainMap);
            if(comDomainMap != null){
                for(Company_Domain__c comDomainList : comDomainMap.values()){
                    companyDomain.add(comDomainMap.get(comDomainList.Id).Company__c);
                }
                system.debug('### companyDomain: ' + companyDomain);
                if(companyDomain != null){
                    system.debug('### companyDomain_v2: ' + companyDomain);
                    //child Accounts + Country
                    List<Account> globalAccount = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c FROM Account WHERE Id IN: companyDomain AND RecordType.DeveloperName = 'Company'];
                    system.debug('### globalAccount: ' + globalAccount);

                    List<Account> mondayAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry, Parent.BillingCountry, Parent.ParentId, ParentId
                                                    FROM Account
                                                    WHERE Company__c IN: companyDomain AND RecordType.DeveloperName = 'Monday_Account' AND BillingCountry =: countryMappingDelReg[0]];//monday account with Global company Parent
                    system.debug('### mondayAccounts: ' + mondayAccounts);
                    if(mondayAccounts.isEmpty() || mondayAccounts.size() == 0 || mondayAccounts == null){
                        maAccount = true;
                    }
                    List<Account> regionalCompanyAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Region__c, Owner.Function__c, ParentId
                                                            FROM Account
                                                            WHERE ParentId IN: companyDomain AND RecordType.DeveloperName = 'Company' AND Region__c IN: regionsMappingDelReg]; //regional company with Global Parent
                    system.debug('### regionalCompanyAccounts: ' + regionalCompanyAccounts);
                    if(regionalCompanyAccounts.isEmpty() || regionalCompanyAccounts.size() == 0 || regionalCompanyAccounts == null){
                        regionalCompany = true;
                    }

                    if(!regionalCompanyAccounts.isEmpty() && regionalCompanyAccounts.size() > 0 && regionalCompanyAccounts != null){
                        localCompanyListRegional = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry, ParentId
                                                    FROM Account 
                                                    WHERE ParentId IN: regionalCompanyAccounts AND RecordType.DeveloperName = 'Company' AND BillingCountry =: countryMappingDelReg[0]];
                    }

                    if(localCompanyListRegional.isEmpty()){
                        localCompanyListGlobal = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry, ParentId
                                                FROM Account 
                                                WHERE ParentId IN: globalAccount AND RecordType.DeveloperName = 'Company' AND BillingCountry =: countryMappingDelReg[0]];
                    }
                    system.debug('### localCompanyListGlobal: ' + localCompanyListGlobal);
                    if((localCompanyListRegional.isEmpty() || localCompanyListRegional.size() == 0 || localCompanyListRegional == null) &&
                        (localCompanyListGlobal.isEmpty() || localCompanyListGlobal.size() == 0 || localCompanyListGlobal == null)){
                        localCompany = true;
                    }
                    
                    // List<Account> localCompanyAccounts = [SELECT Id, Name, OwnerId, Company__c FROM Account WHERE ParentId IN: regionalCompanyAccounts]; //local company with regional parent
                    List<Account> localCompanyAccounts = new List<Account>();
                    List<Lead> relatedLeadCompany = [SELECT Id, Name, CreatedDate, Related_Company__c, Created_Lead_Month__c FROM Lead WHERE Related_Company__c IN: companyDomain AND Created_Lead_Month__c <= 30];
                    system.debug('### relatedLeadCompany: ' + relatedLeadCompany);
                    if(relatedLeadCompany.isEmpty() || relatedLeadCompany.size() == 0 || relatedLeadCompany == null){
                        leadExist = true;
                    }
                    
                    if(maAccount == false){
                        system.debug('### mondayAccounts_v1: ' + mondayAccounts);
                        // isPendingReview = checkPendingAccount(mondayAccounts, companyWebsiteReg, countryMappingDelReg); //List<Account>, Map<String,Lead_Reg>, List<String>
                        for(Account maAcc : mondayAccounts){
                            if(regionalCompanyAccounts != null){
                                system.debug('### maAcc.Parent.BillingCountry: ' + maAcc.Parent.BillingCountry);
                                system.debug('### maAcc.BillingCountry: ' + maAcc.BillingCountry);
                                system.debug('### maAcc.Parent.ParentId: ' + maAcc.Parent.ParentId);
                                system.debug('### regionalCompanyAccounts[0].Id: ' + regionalCompanyAccounts[0].Id);

                                if(maAcc.ParentId == regionalCompanyAccounts[0].Id){//MA Account Parent = Regional
                                    system.debug('### ');
                                    realtedRegionalCompany = new List<Account>();
                                    realtedRegionalCompany.add(maAcc.Parent);
                                    system.debug('### realtedRegionalCompany: ' + realtedRegionalCompany);
                                }

                                else if(maAcc.Parent.BillingCountry == maAcc.BillingCountry && localCompany == false && (maAcc.ParentId == localCompanyListRegional[0].Id || maAcc.ParentId == localCompanyListGlobal[0].Id)){
                                    realtedLocalCompany = new List<Account>();
                                    realtedLocalCompany.add(maAcc.Parent);
                                    system.debug('### realtedLocalCompany: ' + realtedLocalCompany);
                                }
                            }
                            
                            for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                // if(isPendingReview == false && maAcc.BillingCountry == countryMappingDelReg[0]){
                                    system.debug('### Function__c: ' + maAcc.Owner.Function__c);
                                    if(maAcc.Owner.Name == 'Accounts Pool' || (maAcc.Owner.Function__c != 'Mid-Market AM' && maAcc.Owner.Function__c != 'Mid-Market AE' &&
                                        maAcc.Owner.Function__c != 'Enterprise AM' && maAcc.Owner.Function__c != 'Enterprise AE' && maAcc.Owner.Function__c != 'Partner')){
                                            maAccount = true;
                                            system.debug('### maAccount: ' + maAccount);
                                    }
                
                                    else if(maAcc.Owner.Function__c == 'Mid-Market AM' || maAcc.Owner.Function__c == 'Mid-Market AE' ||
                                            maAcc.Owner.Function__c == 'Enterprise AM' || maAcc.Owner.Function__c == 'Enterprise AE' || maAcc.Owner.Function__c == 'Partner'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = maAcc.Id;
                                        isPendingReview = true;
                                    }
                                // }

                                if(realtedLocalCompany != null){
                                    leadReg.Local_Company__c = realtedLocalCompany[0].Id;
                                }

                                if(realtedRegionalCompany != null){
                                    leadReg.Regional_Company__c = realtedRegionalCompany[0].Id;
                                }
                            }
                        }

                        if(isPendingReview == false){
                            if(!localCompanyListRegional.isEmpty()){
                                for(Account localAccount : localCompanyListRegional){
                                    for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                        system.debug('### Function__c: ' + localAccount.Owner.Function__c);
                                        if(localAccount.Owner.Name == 'Accounts Pool' || (localAccount.Owner.Function__c != 'Mid-Market AM' && localAccount.Owner.Function__c != 'Mid-Market AE' &&
                                            localAccount.Owner.Function__c != 'Enterprise AM' && localAccount.Owner.Function__c != 'Enterprise AE' && localAccount.Owner.Function__c != 'Partner')){
                                                localCompany = true;
                                                
                                                system.debug('### localAccount: ' + localAccount);
                                        }
    
                                        else if(localAccount.Owner.Function__c == 'Mid-Market AM' || localAccount.Owner.Function__c == 'Mid-Market AE' ||
                                                localAccount.Owner.Function__c == 'Enterprise AM' || localAccount.Owner.Function__c == 'Enterprise AE' || localAccount.Owner.Function__c == 'Partner'){
                                            leadReg.Status__c = 'Pending Review';
                                            leadReg.Related_Company__c = localAccount.Id;
                                            isPendingReview = true;
                                        }
    
                                        leadReg.Regional_Company__c = localAccount.ParentId;
                                    }
                                }
                            }
    
                            else if(!localCompanyListGlobal.isEmpty()){
                                for(Account localAccount : localCompanyListGlobal){
                                    for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                        system.debug('### Function__c: ' + localAccount.Owner.Function__c);
                                        if(localAccount.Owner.Name == 'Accounts Pool' || (localAccount.Owner.Function__c != 'Mid-Market AM' && localAccount.Owner.Function__c != 'Mid-Market AE' &&
                                            localAccount.Owner.Function__c != 'Enterprise AM' && localAccount.Owner.Function__c != 'Enterprise AE' && localAccount.Owner.Function__c != 'Partner')){
                                                localCompany = true;
                                                
                                                system.debug('### localAccount: ' + localAccount);
                                        }
    
                                        else if(localAccount.Owner.Function__c == 'Mid-Market AM' || localAccount.Owner.Function__c == 'Mid-Market AE' ||
                                                localAccount.Owner.Function__c == 'Enterprise AM' || localAccount.Owner.Function__c == 'Enterprise AE' || localAccount.Owner.Function__c == 'Partner'){
                                            leadReg.Status__c = 'Pending Review';
                                            leadReg.Related_Company__c = localAccount.Id;
                                            isPendingReview = true;
                                        }
    
                                        leadReg.Global_Company__c = localAccount.ParentId;
                                    }
                                }
                            }
                        }

                        if(isPendingReview == false && regionalCompanyAccounts != null){
                            for(Account regionalAccount : regionalCompanyAccounts){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### Function__c: ' + regionalAccount.Owner.Function__c);
                                    if(regionalAccount.Owner.Name == 'Accounts Pool' || (regionalAccount.Owner.Function__c != 'Mid-Market AM' && regionalAccount.Owner.Function__c != 'Mid-Market AE' &&
                                        regionalAccount.Owner.Function__c != 'Enterprise AM' && regionalAccount.Owner.Function__c != 'Enterprise AE' && regionalAccount.Owner.Function__c != 'Partner')){
                                            regionalCompany = true;
                                            
                                            system.debug('### maAccount: ' + maAccount);
                                    }

                                    else if(regionalAccount.Owner.Function__c == 'Mid-Market AM' || regionalAccount.Owner.Function__c == 'Mid-Market AE' ||
                                            regionalAccount.Owner.Function__c == 'Enterprise AM' || regionalAccount.Owner.Function__c == 'Enterprise AE' || regionalAccount.Owner.Function__c == 'Partner'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = regionalAccount.Id;
                                        isPendingReview = true;
                                    }
                                }
                            }
                        }

                        if(isPendingReview == false){
                            for(Account globalAcc : globalAccount){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### Function__c: ' + globalAcc.Owner.Function__c);
                                    if(globalAcc.Owner.Name == 'Accounts Pool' || (globalAcc.Owner.Function__c != 'Mid-Market AM' && globalAcc.Owner.Function__c != 'Mid-Market AE' &&
                                        globalAcc.Owner.Function__c != 'Enterprise AM' && globalAcc.Owner.Function__c != 'Enterprise AE' && globalAcc.Owner.Function__c != 'Partner')){
                                            globalCompany = true;
                                            
                                            system.debug('### maAccount: ' + maAccount);
                                    }

                                    else if(globalAcc.Owner.Function__c == 'Mid-Market AM' || globalAcc.Owner.Function__c == 'Mid-Market AE' ||
                                            globalAcc.Owner.Function__c == 'Enterprise AM' || globalAcc.Owner.Function__c == 'Enterprise AE' || globalAcc.Owner.Function__c == 'Partner'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = globalAcc.Id;
                                        isPendingReview = true;
                                    }
                                }
                            }
                        }
                    }

                    else if(maAccount == true && localCompany == false){
                        if(!localCompanyListRegional.isEmpty()){
                            for(Account localAccount : localCompanyListRegional){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### Function__c: ' + localAccount.Owner.Function__c);
                                    if(localAccount.Owner.Name == 'Accounts Pool' || (localAccount.Owner.Function__c != 'Mid-Market AM' && localAccount.Owner.Function__c != 'Mid-Market AE' &&
                                        localAccount.Owner.Function__c != 'Enterprise AM' && localAccount.Owner.Function__c != 'Enterprise AE' && localAccount.Owner.Function__c != 'Partner')){
                                            localCompany = true;
                                            
                                            system.debug('### localAccount: ' + localAccount);
                                    }

                                    else if(localAccount.Owner.Function__c == 'Mid-Market AM' || localAccount.Owner.Function__c == 'Mid-Market AE' ||
                                            localAccount.Owner.Function__c == 'Enterprise AM' || localAccount.Owner.Function__c == 'Enterprise AE' || localAccount.Owner.Function__c == 'Partner'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = localAccount.Id;
                                        isPendingReview = true;
                                    }

                                    leadReg.Regional_Company__c = localAccount.ParentId;
                                }
                            }
                        }

                        else if(!localCompanyListGlobal.isEmpty()){
                            for(Account localAccount : localCompanyListGlobal){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### Function__c: ' + localAccount.Owner.Function__c);
                                    if(localAccount.Owner.Name == 'Accounts Pool' || (localAccount.Owner.Function__c != 'Mid-Market AM' && localAccount.Owner.Function__c != 'Mid-Market AE' &&
                                        localAccount.Owner.Function__c != 'Enterprise AM' && localAccount.Owner.Function__c != 'Enterprise AE' && localAccount.Owner.Function__c != 'Partner')){
                                            localCompany = true;
                                            
                                            system.debug('### localAccount: ' + localAccount);
                                    }

                                    else if(localAccount.Owner.Function__c == 'Mid-Market AM' || localAccount.Owner.Function__c == 'Mid-Market AE' ||
                                            localAccount.Owner.Function__c == 'Enterprise AM' || localAccount.Owner.Function__c == 'Enterprise AE' || localAccount.Owner.Function__c == 'Partner'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = localAccount.Id;
                                        isPendingReview = true;
                                    }

                                    leadReg.Global_Company__c = localAccount.ParentId;
                                }
                            }
                        }

                        if(isPendingReview == false && regionalCompany == false){
                            for(Account regionalAccount : regionalCompanyAccounts){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### Function__c: ' + regionalAccount.Owner.Function__c);
                                    if(regionalAccount.Owner.Name == 'Accounts Pool' || (regionalAccount.Owner.Function__c != 'Mid-Market AM' && regionalAccount.Owner.Function__c != 'Mid-Market AE' &&
                                        regionalAccount.Owner.Function__c != 'Enterprise AM' && regionalAccount.Owner.Function__c != 'Enterprise AE' && regionalAccount.Owner.Function__c != 'Partner')){
                                            regionalCompany = true;
                                            
                                            system.debug('### regionalCompany: ' + regionalCompany);
                                    }

                                    else if(regionalAccount.Owner.Function__c == 'Mid-Market AM' || regionalAccount.Owner.Function__c == 'Mid-Market AE' ||
                                            regionalAccount.Owner.Function__c == 'Enterprise AM' || regionalAccount.Owner.Function__c == 'Enterprise AE' || regionalAccount.Owner.Function__c == 'Partner'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = regionalAccount.Id;
                                        isPendingReview = true;
                                    }

                                    leadReg.Global_Company__c = regionalAccount.ParentId;
                                }
                            }
                        }

                        if(isPendingReview == false){
                            for(Account globalAcc : globalAccount){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### Function__c: ' + globalAcc.Owner.Function__c);
                                    if(globalAcc.Owner.Name == 'Accounts Pool' || (globalAcc.Owner.Function__c != 'Mid-Market AM' && globalAcc.Owner.Function__c != 'Mid-Market AE' &&
                                        globalAcc.Owner.Function__c != 'Enterprise AM' && globalAcc.Owner.Function__c != 'Enterprise AE' && globalAcc.Owner.Function__c != 'Partner')){
                                            globalCompany = true;
                                            
                                            system.debug('### maAccount: ' + maAccount);
                                    }

                                    else if(globalAcc.Owner.Function__c == 'Mid-Market AM' || globalAcc.Owner.Function__c == 'Mid-Market AE' ||
                                            globalAcc.Owner.Function__c == 'Enterprise AM' || globalAcc.Owner.Function__c == 'Enterprise AE' || globalAcc.Owner.Function__c == 'Partner'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = globalAcc.Id;
                                        isPendingReview = true;
                                    }
                                }
                            }
                        }
                    }

                    else if(maAccount == true && localCompany == true && regionalCompany == false){
                        system.debug('@@@ regionalCompanyAccounts: ' + regionalCompanyAccounts);
                        for(Account regionalAccount : regionalCompanyAccounts){
                            for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                system.debug('### Function__c: ' + regionalAccount.Owner.Function__c);
                                if(regionalAccount.Owner.Name == 'Accounts Pool' || (regionalAccount.Owner.Function__c != 'Mid-Market AM' && regionalAccount.Owner.Function__c != 'Mid-Market AE' &&
                                    regionalAccount.Owner.Function__c != 'Enterprise AM' && regionalAccount.Owner.Function__c != 'Enterprise AE' && regionalAccount.Owner.Function__c != 'Partner')){
                                        regionalCompany = true;
                                        
                                        system.debug('### maAccount: ' + maAccount);
                                }

                                else if(regionalAccount.Owner.Function__c == 'Mid-Market AM' || regionalAccount.Owner.Function__c == 'Mid-Market AE' ||
                                        regionalAccount.Owner.Function__c == 'Enterprise AM' || regionalAccount.Owner.Function__c == 'Enterprise AE' || regionalAccount.Owner.Function__c == 'Partner'){
                                    leadReg.Status__c = 'Pending Review';
                                    leadReg.Related_Company__c = regionalAccount.Id;
                                    isPendingReview = true;
                                }

                                leadReg.Global_Company__c = regionalAccount.ParentId;
                            }
                        }

                        if(isPendingReview == false){
                            for(Account globalAcc : globalAccount){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### Function__c: ' + globalAcc.Owner.Function__c);
                                    if(globalAcc.Owner.Name == 'Accounts Pool' || (globalAcc.Owner.Function__c != 'Mid-Market AM' && globalAcc.Owner.Function__c != 'Mid-Market AE' &&
                                        globalAcc.Owner.Function__c != 'Enterprise AM' && globalAcc.Owner.Function__c != 'Enterprise AE' && globalAcc.Owner.Function__c != 'Partner')){
                                            globalCompany = true;
                                            
                                            system.debug('### maAccount: ' + maAccount);
                                    }

                                    else if(globalAcc.Owner.Function__c == 'Mid-Market AM' || globalAcc.Owner.Function__c == 'Mid-Market AE' ||
                                            globalAcc.Owner.Function__c == 'Enterprise AM' || globalAcc.Owner.Function__c == 'Enterprise AE' || globalAcc.Owner.Function__c == 'Partner'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = globalAcc.Id;
                                        isPendingReview = true;
                                    }

                                    leadReg.Global_Company__c = globalAcc.Id;
                                }
                            } 
                        }
                    }

                    else if(maAccount == true && localCompany == true && regionalCompany == true && globalCompany == false){
                        for(Account globalAcc : globalAccount){
                            for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                system.debug('### Function__c: ' + globalAcc.Owner.Function__c);
                                if(globalAcc.Owner.Name == 'Accounts Pool' || (globalAcc.Owner.Function__c != 'Mid-Market AM' && globalAcc.Owner.Function__c != 'Mid-Market AE' &&
                                    globalAcc.Owner.Function__c != 'Enterprise AM' && globalAcc.Owner.Function__c != 'Enterprise AE' && globalAcc.Owner.Function__c != 'Partner')){
                                        globalCompany = true;
                                        
                                        system.debug('### maAccount: ' + maAccount);
                                }

                                else if(globalAcc.Owner.Function__c == 'Mid-Market AM' || globalAcc.Owner.Function__c == 'Mid-Market AE' ||
                                        globalAcc.Owner.Function__c == 'Enterprise AM' || globalAcc.Owner.Function__c == 'Enterprise AE' || globalAcc.Owner.Function__c == 'Partner'){
                                    leadReg.Status__c = 'Pending Review';
                                    leadReg.Related_Company__c = globalAcc.Id;
                                    isPendingReview = true;
                                }

                                leadReg.Global_Company__c = globalAcc.Id;
                            }
                        }
                    }

                    system.debug('@@@ maAccount: ' + maAccount);
                    system.debug('@@@ localCompany: ' + localCompany);
                    system.debug('@@@ regionalCompany: ' + regionalCompany);
                    system.debug('@@@ globalCompany: ' + globalCompany);
                    system.debug('@@@ isPendingReview: ' + isPendingReview);

                    if(maAccount == true && localCompany == true && regionalCompany == true && globalCompany == true && isPendingReview == false){
                        system.debug('@@@ without lead: ' + relatedLeadCompany);
                        if(leadExist == false){
                            for(Lead l : relatedLeadCompany){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    if(l.Status != 'Nurturing' || l.Status != 'Qualified'){
                                        system.debug('### l.Status: ' + l.Status);
                                        leadReg.Status__c = 'Pending Review';
                                    }
    
                                    else{
                                        leadExist = true;
                                    }
                                }
                            }
                        }
                        system.debug('@@@ leadExist: ' + leadExist);
                        if(leadExist == true){
                            system.debug('@@@ with lead: ');
                            for(Lead_Registration__c finalLeadReg : leadRegList){
                                if(finalLeadReg.Company_Size__c != '1500+'){        
                                    finalLeadReg.Status__c = 'Approved';
                                    finalLeadReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                                    system.debug('### status_v1: ' + finalLeadReg.Status__c);
                                }
        
                                if(finalLeadReg.Company_Size__c == '1500+'){
                                    finalLeadReg.Status__c = 'Pending Review';
                                }
                            }
                        }
                    }
                }
            }

            //if no Domain exists --> no Account exists --> no need to search
            else{
                for(Lead_Registration__c lReg : companyWebsiteReg.values()){
                    if(lReg.Company_Size__c != '1500+'){        
                        lReg.Status__c = 'Approved';
                        lReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                        system.debug('### status: ' + lReg.Status__c);
                    }

                    if(lReg.Company_Size__c == '1500+'){
                        lReg.Status__c = 'Pending Review';
                    }
                }
            }
        }
    }

    public static void updateTimestamps(List<Lead_Registration__c> newLeadRegs, Map<Id, Lead_Registration__c> oldLeadRegs){
        List<Lead_Registration__c> leadRegToUpdate = new List<Lead_Registration__c>();

        for(Lead_Registration__c lReg : newLeadRegs){
            if(lReg.Status__c != oldLeadRegs.get(lReg.Id).Status__c && lReg.Status__c == 'Approved' && oldLeadRegs.get(lReg.Id).Status__c == 'Pending Review'){
                if(lReg.Related_Company__c != null && lReg.Related_Lead__c == null && lReg.No_Existing_Reocrds__c == false){
                    lReg.Timestamp_Manually_Approved__c = System.Today();
                    lReg.Approved_By__c = UserInfo.getUserId();
                }
            }
        }
    }
}