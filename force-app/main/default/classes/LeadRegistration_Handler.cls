public with sharing class LeadRegistration_Handler {
    static Map<String, Country_Region_Mapping__c> regionsMapping = null;
    static Boolean isPendingReview = false;

    static Boolean maAccount = false;
    static Boolean localCompany = false;
    static Boolean regionalCompany = false;
    static Boolean globalCompany = false;
    static Boolean leadExist = false;

    static List<Account> realtedLocalCompany = null;
    
    public static void isBeforeInsert(List<Lead_Registration__c> newLeadRegs, Map<Id, Lead_Registration__c> oldLeadRegs){
        leadReg_MapRegions(newLeadRegs, oldLeadRegs);
    }

    public static void isBeforeUpdate(List<Lead_Registration__c> newLeadRegs, Map<Id, Lead_Registration__c> oldLeadRegs){
        updateTimestamps(newLeadRegs, oldLeadRegs);
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

        for(Lead_Registration__c lReg : newLeadRegs){
            if(lReg.Status__c == 'Approved'){
                isApproved = true;
            }
        }
        system.debug('### isApproved: ' + isApproved);
        system.debug('### realtedLocalCompany: ' + realtedLocalCompany);
    
        if(oldLeadRegs == null && realtedLocalCompany != null){
            if(isApproved == true){
                for(Account acc : realtedLocalCompany){
                    for(Lead_Registration__c lReg : newLeadRegs){
                        if(lReg.Local_Company__c != null){
                            acc.Lead_Registration__c = lReg.Id;
                            newAccount.add(acc);
                            leadRegAccount.put(newAccount[0], lReg);
                        }
                    }
                }

                if(newAccount != null){
                    update newAccount;
                    system.debug('### Inserted Account Id_v1 = ' +newAccount);
                }

                for(Lead_Registration__c lRegRec : newLeadRegs){
                    Lead l = new Lead();
                    l.LastName = lRegRec.First_Name__c;
                    l.Lead_Registration__c = lRegRec.Id;
                    l.Company = lRegRec.Company__c;
                    l.Company_Size__c = lRegRec.Company_Size__c;
                    l.Email = lRegRec.Registered_Email__c;
                    l.LeadSource = 'Deal Reg';
                    l.RecordTypeId = '0121t000000IQT4AAO'; // create partner lead
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

        /*else if(oldLeadRegs == null && realtedLocalCompany == null){
            for(Lead_Registration__c lReg : newLeadRegs){
                Account acc = new Account();
                acc.Name = lReg.Company__c;
                acc.Lead_Registration__c = lReg.Id;
                acc.RecordTypeId = '0121t000000IQTiAAO';
                newAccount.add(acc);

                if(newAccount != null){
                    leadRegAccount.put(newAccount[0], lReg);
                }
            }
    
            if(leadRegAccount != null){
                insert newAccount;
                system.debug('### Inserted Account Id_v2 = ' +newAccount);
                
                for(Lead_Registration__c lRegRec : leadRegAccount.values()){
                    Lead l = new Lead();
                    l.LastName = lRegRec.First_Name__c;
                    l.Lead_Registration__c = lRegRec.Id;
                    l.Company = lRegRec.Company__c;
                    l.Company_Size__c = lRegRec.Company_Size__c;
                    l.Email = lRegRec.Registered_Email__c;
                    l.LeadSource = 'Deal Reg';
                    l.RecordTypeId = '0121t000000IQT4AAO'; // create partner lead
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
        }*/

        else if (oldLeadRegs != null){
            for(Lead_Registration__c lReg : newLeadRegs){
                if(lReg.Status__c != oldLeadRegs.get(lReg.Id).Status__c && isApproved == true){
                    for(Account acc : realtedLocalCompany){
                        if(lReg.Local_Company__c != null){
                            acc.Lead_Registration__c = lReg.Id;
                            newAccount.add(acc);
                            leadRegAccount.put(newAccount[0], lReg);
                        }
                    }

                    if(newAccount != null){
                        update newAccount;
                        system.debug('### Inserted Account Id_v1 = ' +newAccount);
                    }

                    for(Lead_Registration__c lRegRec : newLeadRegs){
                        Lead l = new Lead();
                        l.LastName = lRegRec.First_Name__c;
                        l.Lead_Registration__c = lRegRec.Id;
                        l.Company = lRegRec.Company__c;
                        l.Company_Size__c = lRegRec.Company_Size__c;
                        l.Email = lRegRec.Registered_Email__c;
                        l.LeadSource = 'Deal Reg';
                        l.RecordTypeId = '0121t000000IQT4AAO'; // create partner lead
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

                /*Account acc = new Account();
                    acc.Name = lReg.Company__c;
                    acc.Lead_Registration__c = lReg.Id;
                    acc.RecordTypeId = '0121t000000IQTiAAO';
                    newAccount.add(acc);
    
                    if(newAccount != null){
                        leadRegAccount.put(newAccount[0], lReg);
                    }

                if(leadRegAccount != null){
                    insert newAccount;
                    system.debug('### Inserted Account Id_v3 = ' +newAccount);
                    
                    for(Lead_Registration__c lRegRec : leadRegAccount.values()){
                        Lead l = new Lead();
                        l.LastName = lRegRec.First_Name__c;
                        l.Lead_Registration__c = lRegRec.Id;
                        l.Company = lRegRec.Company__c;
                        l.Email = lRegRec.Registered_Email__c;
                        l.LeadSource = 'Deal Reg';
                        l.RecordTypeId = '0121t000000IQT4AAO';
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
                            leadsToConvert.add(tempLC);
                        }
                        List<Database.LeadConvertResult> lc = Database.convertLead(leadsToConvert);
                        for(Database.LeadConvertResult lctemp : lc){
                            system.debug('### getAccountId: ' + lctemp.getAccountId());
                            system.debug('### getContactId' + lctemp.getContactId());
                            system.debug('### getContactId' + lctemp.getOpportunityId());
                        }
                    }
                }*/
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
                            counter++;
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
                system.debug('### comDomainMap: ' + companyDomain);
                if(companyDomain != null){
                    //child Accounts + Country
                    Map<Id, Account> allChildAccounts = new Map<Id, Account>([
                        SELECT Id, Name, OwnerId, Company__c, Region__c, ParentId, Company_Website__c, Owner.name, Owner.Function__c, BillingCountry, RecordType.DeveloperName
                        FROM Account
                        WHERE (Id IN: companyDomain OR ParentId IN: companyDomain OR Company__c IN: companyDomain)]); //find accounts/company__c/parentId with the domain
                    
                    List<Account> mondayAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry, Parent.BillingCountry, Parent.ParentId FROM Account WHERE Company__c IN: companyDomain AND RecordType.DeveloperName = 'Monday_Account' AND BillingCountry IN: countryMappingDelReg];//monday account with Global company Parent
                    system.debug('### mondayAccounts: ' + mondayAccounts[0].Parent.ParentId);
                    if(mondayAccounts == null){
                        maAccount = true;
                    }
                    List<Account> regionalCompanyAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Region__c, Owner.Function__c FROM Account WHERE ParentId IN: companyDomain AND RecordType.DeveloperName = 'Company' AND Region__c IN: regionsMappingDelReg]; //regional company with Global Parent
                    system.debug('### regionalCompanyAccounts: ' + regionalCompanyAccounts);
                    List<Account> globalAccount = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c FROM Account WHERE Id IN: companyDomain AND RecordType.DeveloperName = 'Company'];
                    system.debug('### globalAccount: ' + globalAccount);
                    // List<Account> localCompanyAccounts = [SELECT Id, Name, OwnerId, Company__c FROM Account WHERE ParentId IN: regionalCompanyAccounts]; //local company with regional parent
                    List<Account> localCompanyAccounts = new List<Account>();
                    system.debug('### allChildAccounts size: ' + allChildAccounts.size());
                    accountQuerySize = allChildAccounts.size();  
                    Map<Id, Lead> relatedLeadCompany = new Map<Id, Lead>([SELECT Id, Name, CreatedDate, Related_Company__c, Created_Lead_Month__c FROM Lead WHERE Related_Company__c IN: companyDomain AND Created_Lead_Month__c <= 30]);

                    if(mondayAccounts != null){
                        // isPendingReview = checkPendingAccount(mondayAccounts, companyWebsiteReg, countryMappingDelReg); //List<Account>, Map<String,Lead_Reg>, List<String>
                        for(Account maAcc : mondayAccounts){
                            if(regionalCompanyAccounts != null){
                                system.debug('### maAcc.Parent.BillingCountry: ' + maAcc.Parent.BillingCountry);
                                system.debug('### maAcc.BillingCountry: ' + maAcc.BillingCountry);
                                system.debug('### maAcc.Parent.ParentId: ' + maAcc.Parent.ParentId);
                                system.debug('### regionalCompanyAccounts[0].Id: ' + regionalCompanyAccounts[0].Id);
                                if(maAcc.ParentId == globalAccount[0].Id){//MA Account Parent = Global
                                    system.debug('### ');
                                }

                                if(maAcc.ParentId == regionalCompanyAccounts[0].Id){//MA Account Parent = Regional
                                    system.debug('### ');
                                }

                                else{// MA Account Parent = Local
                                    if(maAcc.Parent.BillingCountry == maAcc.BillingCountry){
                                        realtedLocalCompany = new List<Account>();
                                        realtedLocalCompany.add(maAcc.Parent);
                                        system.debug('### realtedLocalCompany: ' + realtedLocalCompany);
                                    }
                                }
                            }
                            
                            for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                if(isPendingReview == false && maAcc.BillingCountry == countryMappingDelReg[0]){
                                    system.debug('### Function__c: ' + maAcc.Owner.Function__c);
                                    if(maAcc.Owner.Name == 'Accounts Pool' || (maAcc.Owner.Function__c != 'Mid-Market AM' && maAcc.Owner.Function__c != 'Mid-Market AE' &&
                                        maAcc.Owner.Function__c != 'Enterprise AM' && maAcc.Owner.Function__c != 'Enterprise AE')){
                                            maAccount = true;
                                            counter++;
                                            system.debug('### maAccount: ' + maAccount);
                                    }
                
                                    else if(maAcc.Owner.Function__c == 'Mid-Market AM' || maAcc.Owner.Function__c == 'Mid-Market AE' ||
                                            maAcc.Owner.Function__c == 'Enterprise AM' || maAcc.Owner.Function__c == 'Enterprise AE'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = maAcc.Id;
                                        isPendingReview = true;
                                    }
                                }

                                else if(maAcc.BillingCountry != countryMappingDelReg[0]){
                                    maAccount = true;
                                }

                                if(realtedLocalCompany != null){
                                    leadReg.Local_Company__c = realtedLocalCompany[0].Id;
                                }
                            }
                        }

                        if(isPendingReview == false){
                            if(regionalCompanyAccounts != null){
                                localCompanyAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry FROM Account WHERE ParentId IN: regionalCompanyAccounts AND RecordType.DeveloperName = 'Company']; //get MA Account Parent (Should be local)
                            }

                            else{
                                localCompanyAccounts = [SELECT Id, Name, OwnerId, Owner.name, Company__c, Owner.Function__c, BillingCountry FROM Account WHERE ParentId IN: globalAccount AND RecordType.DeveloperName = 'Company']; //get MA Account Parent (Should be local)
                            }
                            
                            if(localCompanyAccounts != null){
                                for(Account localAccount : localCompanyAccounts){
                                    for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                        if(isPendingReview == false && localAccount.BillingCountry == countryMappingDelReg[0]){
                                            system.debug('### Function__c: ' + localAccount.Owner.Function__c);
                                            if(localAccount.Owner.Name == 'Accounts Pool' || (localAccount.Owner.Function__c != 'Mid-Market AM' && localAccount.Owner.Function__c != 'Mid-Market AE' &&
                                                localAccount.Owner.Function__c != 'Enterprise AM' && localAccount.Owner.Function__c != 'Enterprise AE')){
                                                    localCompany = true;
                                                    counter++;
                                                    system.debug('### localAccount: ' + localAccount);
                                            }
        
                                            else if(localAccount.Owner.Function__c == 'Mid-Market AM' || localAccount.Owner.Function__c == 'Mid-Market AE' ||
                                                    localAccount.Owner.Function__c == 'Enterprise AM' || localAccount.Owner.Function__c == 'Enterprise AE'){
                                                leadReg.Status__c = 'Pending Review';
                                                leadReg.Related_Company__c = localAccount.Id;
                                                isPendingReview = true;
                                            }
                                        }

                                        else{
                                            localCompany = true;
                                        }
                                    }
                                }
                            }
                        }

                        if(isPendingReview == false && regionalCompanyAccounts != null){
                            for(Account regionalAccount : regionalCompanyAccounts){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    if(isPendingReview == false && regionalAccount.Region__c == countryMappingDelReg[0]){
                                        system.debug('### Function__c: ' + regionalAccount.Owner.Function__c);
                                        if(regionalAccount.Owner.Name == 'Accounts Pool' || (regionalAccount.Owner.Function__c != 'Mid-Market AM' && regionalAccount.Owner.Function__c != 'Mid-Market AE' &&
                                            regionalAccount.Owner.Function__c != 'Enterprise AM' && regionalAccount.Owner.Function__c != 'Enterprise AE')){
                                                regionalCompany = true;
                                                counter++;
                                                system.debug('### maAccount: ' + maAccount);
                                        }
    
                                        else if(regionalAccount.Owner.Function__c == 'Mid-Market AM' || regionalAccount.Owner.Function__c == 'Mid-Market AE' ||
                                                regionalAccount.Owner.Function__c == 'Enterprise AM' || regionalAccount.Owner.Function__c == 'Enterprise AE'){
                                            leadReg.Status__c = 'Pending Review';
                                            leadReg.Related_Company__c = regionalAccount.Id;
                                            isPendingReview = true;
                                        }
                                    }

                                    else{
                                        regionalCompany = true;
                                    }
                                }
                            }
                        }

                        if(isPendingReview == false){
                            for(Account globalAcc : globalAccount){
                                for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                    system.debug('### Function__c: ' + globalAcc.Owner.Function__c);
                                    if(globalAcc.Owner.Name == 'Accounts Pool' || (globalAcc.Owner.Function__c != 'Mid-Market AM' && globalAcc.Owner.Function__c != 'Mid-Market AE' &&
                                        globalAcc.Owner.Function__c != 'Enterprise AM' && globalAcc.Owner.Function__c != 'Enterprise AE')){
                                            globalCompany = true;
                                            counter++;
                                            system.debug('### maAccount: ' + maAccount);
                                    }

                                    else if(globalAcc.Owner.Function__c == 'Mid-Market AM' || globalAcc.Owner.Function__c == 'Mid-Market AE' ||
                                            globalAcc.Owner.Function__c == 'Enterprise AM' || globalAcc.Owner.Function__c == 'Enterprise AE'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = globalAcc.Id;
                                        isPendingReview = true;
                                    }
                                }
                            }
                        }
                    }

                    if(maAccount == true && localCompany == true && regionalCompany == true && globalCompany == true && isPendingReview == false){
                        for(Lead l : relatedLeadCompany.values()){
                            for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                if(l.Status != 'Nurturing' && l.Status != 'Qualified'){
                                    leadReg.Status__c = 'Pending Review';
                                }

                                else{
                                    leadExist = true;
                                }
                            }
                        }
                    }

                    if(maAccount == true || localCompany == true || regionalCompany == true || globalCompany == true || leadExist == true || isPendingReview == false){
                        for(Lead_Registration__c finalLeadReg : leadRegList){
                            if(finalLeadReg.Company_Size__c != '1500+'){        
                                finalLeadReg.Status__c = 'Approved';
                                finalLeadReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                                system.debug('### status: ' + finalLeadReg.Status__c);
                            }
    
                            if(finalLeadReg.Company_Size__c == '1500+'){
                                finalLeadReg.Status__c = 'Pending Review';
                            }
                        }
                    }

                    /*if(allChildAccounts != null){
                        for(Account acc : allChildAccounts.values()){
                            for(Lead_Registration__c leadReg : companyWebsiteReg.values()){
                                system.debug('### billing' + allChildAccounts.get(acc.Id).BillingCountry);
                                system.debug('### country' + countryMappingDelReg[0]);
                                
                                // for all Child Accounts under the Global Company
                                if(allChildAccounts.get(acc.Id).ParentId != null){
                                    if(isPendingReview == false && allChildAccounts.get(acc.Id).BillingCountry == countryMappingDelReg[0]){
                                        system.debug('### Function__c: ' + allChildAccounts.get(acc.Id).Owner.Function__c);
                                        if(allChildAccounts.get(acc.Id).Owner.Name == 'Accounts Pool' || (allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AE' &&
                                        allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AE')){
                                            if(allChildAccounts.get(acc.Id).RecordType.DeveloperName == 'Monday_Account'){
                                                maAccount = true;
                                                counter++;
                                                system.debug('### maAccount: ' + maAccount);
                                            }
    
                                            else if(allChildAccounts.get(acc.Id).RecordType.DeveloperName == 'Company'){
                                                localCompany = true;
                                                counter++;
                                                system.debug('### localCompany: ' + localCompany);
                                            }
                                            
                                        }
    
                                        else if(allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AE' ||
                                                allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AE'){
                                            leadReg.Status__c = 'Pending Review';
                                            leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                            isPendingReview = true;
                                        }
                                    }
    
                                    if(isPendingReview == false && allChildAccounts.get(acc.Id).RecordType.DeveloperName == 'Company' && allChildAccounts.get(acc.Id).Region__c == regionsMappingDelReg[0]){
                                        if(allChildAccounts.get(acc.Id).Owner.Name == 'Accounts Pool' || (allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AE' &&
                                            allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AE')){
                                                regionalCompany = true;
                                                counter++;
                                                system.debug('### regionalCompany: ' + regionalCompany);
                                        }
    
                                        else if(allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AE' ||
                                        allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AE'){
                                            leadReg.Status__c = 'Pending Review';
                                            leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                            isPendingReview = true;
                                        }
                                    }
                                }

                                // for Global Company
                                else if(allChildAccounts.get(acc.Id).ParentId == null && isPendingReview == false && allChildAccounts.get(acc.Id).Company__c == null && allChildAccounts.get(acc.Id).RecordType.DeveloperName == 'Company'){
                                    if(allChildAccounts.get(acc.Id).Owner.Name == 'Accounts Pool' || (allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AE' &&
                                        allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AE')){
                                        globalCompany = true;
                                        counter++;
                                    }

                                    else if(allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AE' ||
                                        allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AE'){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                    }
                                }

                                // if there is a Lead related to the Global Company
                                else if(relatedLeadCompany != null && isPendingReview == false){
                                    for(Lead l : relatedLeadCompany.values()){
                                        if(l.Status != 'Nurturing' && l.Status != 'Qualified'){
                                            leadReg.Status__c = 'Pending Review';
                                            leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                        }
                                    }
                                }

                                // if all conditions meets & no Lead is related
                                if(counter == accountQuerySize && relatedLeadCompany == null){//and company size != 1500+ or = 1500+ set status
                                    for(Lead_Registration__c finalLeadReg : leadRegList){
                                        if(finalLeadReg.Company_Size__c != '1500+'){        
                                            finalLeadReg.Status__c = 'Approved';
                                            finalLeadReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                                            system.debug('### status: ' + finalLeadReg.Status__c);
                                        }
                
                                        if(finalLeadReg.Company_Size__c == '1500+'){
                                            finalLeadReg.Status__c = 'Pending Review';
                                        }
                                    }
                                }
                            }
                        }
                    }*/
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

    public static void validateLeadRegistration_Test_v2(List<Lead_Registration__c> leadRegList){
        Map<String, Lead_Registration__c> companyWebsiteReg = new Map<String, Lead_Registration__c>();
        List<String> countryMappingDelReg = new List<String>();
        List<String> regionsMappingDelReg = new List<String>();
        
        Set<Id> companyDomain = new Set<Id>();

        Boolean maAccount = false;
        Boolean localCompany = false;
        Boolean regionalCompany = false;
        Boolean globalCompany = false;
        Boolean isPendingReview = false;

        List<Account> MAAccountIds = new List<Account>();
        List<Account> localCompanyIds = new List<Account>();
        List<Account> regionalCompanyIds = new List<Account>();
        List<Account> globalCompanyIds = new List<Account>();

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
                system.debug('### comDomainMap: ' + companyDomain);
                if(companyDomain != null){
                    //child Accounts + Country
                    Map<Id, Account> allChildAccounts = new Map<Id, Account>([
                        SELECT Id, Name, OwnerId, Company__c, Region__c, ParentId, Account_Territory__c, Company_Website__c, Owner.name, Account_Country__c, Owner.Function__c, BillingCountry, Owner.isActive, RecordType.DeveloperName
                        FROM Account
                        WHERE (Id IN: companyDomain OR ParentId IN: companyDomain OR Company__c IN: companyDomain)]); //find accounts/company__c/parentId with the domain
                    
                    Map<Id, Lead> relatedLeadCompany = new Map<Id, Lead>([SELECT Id, Name, Related_Company__c FROM Lead WHERE Related_Company__c IN: companyDomain]);

                    if(allChildAccounts != null){
                        for(Account acc : allChildAccounts.values()){
                            system.debug('### billing' + allChildAccounts.get(acc.Id).BillingCountry);
                            system.debug('### country' + countryMappingDelReg[0]);
                            if(allChildAccounts.get(acc.Id).ParentId != null){
                                if(allChildAccounts.get(acc.Id).RecordType.DeveloperName == 'Monday_Account'){
                                    if(allChildAccounts.get(acc.Id).BillingCountry == countryMappingDelReg[0]){
                                        for(Lead_Registration__c leadReg : leadRegList){
                                            //if existing withoud opp/lead
                                            system.debug('### Function__c: ' + allChildAccounts.get(acc.Id).Owner.Function__c);
                                            if(allChildAccounts.get(acc.Id).Owner.Name == 'Accounts Pool' || (allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AE' &&
                                            allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AE')){
                                                // if(leadReg.Company_Size__c != '1500+'){
                                                    maAccount = true;
                                                    system.debug('### maAccount: ' + maAccount);
                                                // }

                                                // if(leadReg.Company_Size__c == '1500+'){
                                                //     leadReg.Status__c = 'Pending Review';
                                                //     leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                                //     leadReg.Only_Lead_Creation__c = true;
                                                // }
                                            }
        
                                            else if(allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AE' ||
                                            allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AE'){
                                                leadReg.Status__c = 'Pending Review';
                                                leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                                isPendingReview = true;
                                            }
                                        }
                                        MAAccountIds.add(acc);
                                    }
                                }

                                if(isPendingReview == false){
                                    system.debug('### in company: ');
                                    if(allChildAccounts.get(acc.Id).RecordType.DeveloperName == 'Company'){
                                        if(allChildAccounts.get(acc.Id).BillingCountry == countryMappingDelReg[0]){
                                            for(Lead_Registration__c leadReg : leadRegList){
                                                //if existing withoud opp/lead
                                                if(allChildAccounts.get(acc.Id).Owner.Name == 'Accounts Pool' || (allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AE' &&
                                                allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AE')){
                                                    // if(leadReg.Company_Size__c != '1500+'){
                                                        localCompany = true;
                                                        system.debug('### localCompany: ' + localCompany);
                                                    // }
    
                                                    // if(leadReg.Company_Size__c == '1500+'){
                                                    //     leadReg.Status__c = 'Pending Review';
                                                    //     leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                                    //     leadReg.Only_Lead_Creation__c = true;
                                                    // }
                                                }
            
                                                else if(allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AE' ||
                                                allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AE'){
                                                    system.debug('### localCompany_v2: ' + localCompany);
                                                    leadReg.Status__c = 'Pending Review';
                                                    leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                                    isPendingReview = true;
                                                }
                                            }
                                            localCompanyIds.add(acc);
                                        }
                                        
                                        if(isPendingReview == false){
                                            if(allChildAccounts.get(acc.Id).Region__c == regionsMappingDelReg[0]){
                                                for(Lead_Registration__c leadReg : leadRegList){
                                                    //if existing withoud opp/lead
                                                    if(allChildAccounts.get(acc.Id).Owner.Name == 'Accounts Pool' || (allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AE' &&
                                                    allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AE')){
                                                        // if(leadReg.Company_Size__c != '1500+'){
                                                            regionalCompany = true;
                                                            system.debug('### regionalCompany: ' + regionalCompany);
                                                        // }
        
                                                        // if(leadReg.Company_Size__c == '1500+'){
                                                        //     leadReg.Status__c = 'Pending Review';
                                                        //     leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                                        //     leadReg.Only_Lead_Creation__c = true;
                                                        // }
                                                    }
                
                                                    else if(allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AE' ||
                                                    allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AE'){
                                                        leadReg.Status__c = 'Pending Review';
                                                        leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                                        isPendingReview = true;
                                                    }
                                                }
                                                regionalCompanyIds.add(acc);
                                            }
                                        }
                                    }
                                }
                                
                            }

                            if(isPendingReview == false){
                                if(allChildAccounts.get(acc.Id).ParentId == null && allChildAccounts.get(acc.Id).Company__c == null && allChildAccounts.get(acc.Id).RecordType.DeveloperName == 'Company'){
                                    for(Lead_Registration__c leadReg : leadRegList){
                                        if(allChildAccounts.get(acc.Id).Owner.Name == 'Accounts Pool' || (allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Mid-Market AE' &&
                                            allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AM' && allChildAccounts.get(acc.Id).Owner.Function__c != 'Enterprise AE')){
                                        // if(leadReg.Company_Size__c != '1500+'){
                                            globalCompany = true;
                                        }

                                        else if(allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Mid-Market AE' ||
                                            allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AM' || allChildAccounts.get(acc.Id).Owner.Function__c == 'Enterprise AE'){
                                            leadReg.Status__c = 'Pending Review';
                                            leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                                        }
                                        globalCompanyIds.add(acc);
                                    }
                                }
                            }
                        }

                        if(relatedLeadCompany != null){
                            for(Lead l : relatedLeadCompany.values()){
                                // Integer leadCreation = (System.today() - l.CreatedDate.date());
                                if(l.Status != 'Nurturing' && l.Status != 'Qualified'){
                                    for(Account accs : allChildAccounts.values()){
                                        for(Lead_Registration__c leadReg : leadRegList){
                                            leadReg.Status__c = 'Pending Review';
                                            leadReg.Related_Company__c = allChildAccounts.get(accs.Id).Id;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                if(maAccount = true && localCompany == true && regionalCompany == true && globalCompany == true){//and company size != 1500+ or = 1500+ set status
                    for(Lead_Registration__c finalLeadReg : leadRegList){
                        finalLeadReg.Status__c = 'Approved';
                        finalLeadReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                        // leadReg.Related_Company__c = notAccPoolMap.get(acc.Id).Id;
                        if(finalLeadReg.Company_Size__c != '1500+'){        
                            finalLeadReg.Status__c = 'Approved';
                            finalLeadReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                            system.debug('### status: ' + finalLeadReg.Status__c);
                        }

                        if(finalLeadReg.Company_Size__c == '1500+'){
                            finalLeadReg.Status__c = 'Pending Review';
                            // leadReg.Related_Company__c = allChildAccounts.get(acc.Id).Id;
                        }
                    }
                }
            }
        }
    }

    public static void validateLeadRegistration(List<Lead_Registration__c> leadRegList){
        Map<String, Lead_Registration__c> companyWebsiteReg = new Map<String, Lead_Registration__c>();
        List<String> regionsMappingDelReg = new List<String>();
        Set<Id> companyDomain = new Set<Id>();

        for(Lead_Registration__c lReg : leadRegList){
            String stringWebsite = lReg.Company_Website__c;
            String parseWebsite = stringWebsite.replaceFirst('^(https?://)?(www\\.)?', '').split('/')[0];

            companyWebsiteReg.put(parseWebsite, lReg);
            regionsMappingDelReg.add(lReg.Location__c);
        }

        if(companyWebsiteReg != null){
            Map<String, String> regionsMappingString = new Map<String, String>();
            Map<Id, Country_Region_Mapping__c> regionsMapping = new Map<Id, Country_Region_Mapping__c>(
                [SELECT Id, Name, Region__c, Country_Name__c
                FROM Country_Region_Mapping__c
                WHERE Country_Name__c IN: regionsMappingDelReg]);
            
            for(Country_Region_Mapping__c rm: regionsMapping.values()){
                regionsMappingString.put(rm.Country_Name__c, rm.Region__c);//ex: United Kingdom, EMEA
            }
            
            Map<Id, Company_Domain__c> comDomainMap = new Map<Id, Company_Domain__c>([SELECT Id, Domain__c, Company__c FROM Company_Domain__c WHERE Domain__c IN: companyWebsiteReg.keySet()]);

            if(comDomainMap != null){
                for(Company_Domain__c comDomainList : comDomainMap.values()){
                    companyDomain.add(comDomainMap.get(comDomainList.Id).Company__c);
                }

                if(companyDomain != null){
                    Map<Id, Account> notAccPoolMap = new Map<Id, Account>([
                        SELECT Id, Name, OwnerId, Company__c, ParentId, Account_Territory__c, Company_Website__c, Owner.name, Account_Country__c, Owner.Function__c, BillingCountry
                        FROM Account
                        WHERE (Id IN: companyDomain OR ParentId IN: companyDomain OR Company__c IN: companyDomain) AND Region__c IN: regionsMappingString.values()]); //find accounts/company__c/parentId with the domain
                    
                    if(notAccPoolMap != null){
                        List<Opportunity> opp = [SELECT Id, StageName, AccountId FROM Opportunity WHERE AccountId IN: notAccPoolMap.keySet() AND (StageName != 'Closed Won' OR StageName != 'Closed Lost')];
                        List<Lead> leads = [SELECT Id, Name, Related_Company__c, Domain_From_Email__c FROM Lead WHERE Domain_From_Email__c IN: companyWebsiteReg.keySet() AND Related_Company__c IN: notAccPoolMap.keySet()];
                        
                        Map<Id, Account> accountWithRegion = new Map<Id, Account>([
                            SELECT Id, Name, OwnerId, Company__c, ParentId, Account_Territory__c, Company_Website__c, Owner.name, Account_Country__c, Owner.Function__c, BillingCountry
                            FROM Account
                            WHERE Id IN: notAccPoolMap.keySet() AND Region__c IN: regionsMappingString.values()]);

                        if(accountWithRegion != null){ //if domain exist with region
                            for(Account acc : notAccPoolMap.values()){
                                for(Lead_Registration__c leadReg : leadRegList){
                                    //if region and country exist with the parent/company/id
                                    if(leadReg.Region__c == notAccPoolMap.get(acc.Id).Region__c && leadReg.Location__c == notAccPoolMap.get(acc.Id).BillingCountry){
                                        // and have an open Opp/ no Opp with relevant role owner
                                        if((opp != null || opp == null || leads != null) && (notAccPoolMap.get(acc.Id).Owner.Function__c == 'Mid-Market AM' || notAccPoolMap.get(acc.Id).Owner.Function__c == 'Mid-Market AE' ||
                                        notAccPoolMap.get(acc.Id).Owner.Function__c == 'Enterprise AM' || notAccPoolMap.get(acc.Id).Owner.Function__c == 'Enterprise AE')){
                                            leadReg.Status__c = 'Pending Review';
                                        }
    
                                        // and have no Opp with relevant role owner
                                        if(opp == null && leads == null && (notAccPoolMap.get(acc.Id).Owner.Name == 'Account Pool' || notAccPoolMap.get(acc.Id).Owner.Function__c != 'Mid-Market AM' || notAccPoolMap.get(acc.Id).Owner.Function__c != 'Mid-Market AE' ||
                                        notAccPoolMap.get(acc.Id).Owner.Function__c != 'Enterprise AM' || notAccPoolMap.get(acc.Id).Owner.Function__c != 'Enterprise AE')){
                                            if(leadReg.Company_Size__c != '1500'){// automatic Approve - put timestamp for Automatic
                                                leadReg.Status__c = 'Approved';
                                                leadReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                                                leadReg.Related_Company__c = notAccPoolMap.get(acc.Id).Id;
                                                leadReg.Only_Lead_Creation__c = true;
                                            }
    
                                            if(leadReg.Company_Size__c == '1500+'){
                                                leadReg.Status__c = 'Pending Review';
                                                leadReg.Related_Company__c = notAccPoolMap.get(acc.Id).Id;
                                                leadReg.Only_Lead_Creation__c = true;
                                            }
                                        }
                                    }

                                    if(leadReg.Region__c == notAccPoolMap.get(acc.Id).Region__c && leadReg.Location__c != notAccPoolMap.get(acc.Id).BillingCountry){
                                        leadReg.Status__c = 'Pending Review';
                                        leadReg.Related_Company__c = notAccPoolMap.get(acc.Id).Id;
                                        leadReg.Only_Lead_Creation__c = true;
                                    }
                                }
                            }
                        }

                        else{ //if domain exist with region

                        }
                        
                    }
                }
            }

            else{
                system.debug('### test:');
                List<Account> newAccount = new List<Account>();
                for(Lead_Registration__c lReg : companyWebsiteReg.values()){
                    if(lReg.Company_Size__c != '1500+'){
                        lReg.Status__c = 'Approved';
                        lReg.Timestamp_Automatic_Approved__c = Date.TODAY();
                        lReg.No_Existing_Reocrds__c = true;

                        // Account acc = new Account();
                        // acc.Name = lReg.Company__c;
                        // acc.Lead_Registration__c = lReg.Id;
                        // acc.RecordTypeId = '0121t000000IQTiAAO';
                        // newAccount.add(acc);
                    }

                    if(lReg.Company_Size__c == '1500+'){
                        lReg.Status__c = 'Pending Review';
                    }
                }

                // if(newAccount != null){
                //     insert newAccount;
                // }
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