@isTest
public class DealRegistration_Handler_Test {
    public static Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
    public static Id partnerCompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
    
    public static Profile profileRecord;
    public static User userRecord;
    public static Account globalAcc = new Account();
    public static Account regionalAcc = new Account();
    public static Account localAcc = new Account();
    public static Account mondayAcc = new Account();
    public static Lead newLead = new Lead();

    @TestSetup
    static void setupTest(){
        Globals.CodeOff = true;
        Country_Region_Mapping__c setting = new Country_Region_Mapping__c();
        setting.Country_Name__c = 'Australia';
        setting.Region__c = 'ANZ';
        setting.Name = 'AU';
        insert setting;
        
        globalAcc = TestObjectCreator.CreateCompany();
        globalAcc.Account_Territory__c = 'Global';
        globalAcc.Website = 'test.com';
        globalAcc.Account_Domains__c = 'test2.com';
        globalAcc.BillingCountry = 'Australia';
        insert globalAcc;
        
        localAcc = TestObjectCreator.CreateCompany();
        localAcc.Account_Territory__c = 'Local';
        localAcc.ParentId = globalAcc.Id;
        localAcc.BillingCountry = 'Australia';
        insert localAcc;
        
        DealRegistration_Controller.getInitialParameters();
        DealRegistration_Controller.getProfileInfo();
        DealRegistration_Controller.runningInASandbox();
    }
    
    @isTest public static void createDealReg_pendingStatus(){
        String pendingCompanySize = '1500+';
        String newDomain = 'newTree.com';
        String companyLocation = 'Australia';
            
        Deal_Registration__c dealRegRecord = createDealRegistration(newDomain, pendingCompanySize, companyLocation);
        insert dealRegRecord;
        
        Deal_Registration__c updateDeal = [SELECT Id, Status__c FROM Deal_Registration__c WHERE Id =: dealRegRecord.Id LIMIT 1];
        updateDeal.Status__c = 'Approved';
        update updateDeal;
    }
    
    @isTest public static void createDealReg_newTree(){
        String approvedCompanySize = '50-99';
        String newDomain = 'newTree.com';
        String companyLocation = 'Australia';
            
        Deal_Registration__c dealRegRecord = createDealRegistration(newDomain, approvedCompanySize, companyLocation);
        insert dealRegRecord;
    }
    
    @isTest public static void createDealReg_onlyGlobalExist(){
        Account globAcc = [SELECT Id, Website FROM Account WHERE Account_Territory__c = 'Global' LIMIT 1];
        
        String approvedCompanySize = '50-99';
        String existingDomain = globAcc.Website;
        String companyLocation = 'Australia';
            
        Deal_Registration__c dealRegRecord = createDealRegistration(existingDomain, approvedCompanySize, companyLocation);
        insert dealRegRecord;
        Deal_Registration__c dReg = [SELECT Id FROM Deal_Registration__c WHERE Id =: dealRegRecord.Id LIMIT 1];
        DealRegistration_Controller.updateDealRegistration(dReg.Id);
    }
    
    @isTest public static void createDealReg_globalRegionalExist(){
        Account globAcc = [SELECT Id, Website FROM Account WHERE Account_Territory__c = 'Global' LIMIT 1];
        
        regionalAcc = TestObjectCreator.CreateCompany();
        regionalAcc.Account_Territory__c = 'Regional';
        regionalAcc.ParentId = globAcc.Id;
        regionalAcc.Company__c = globAcc.Id;
        regionalAcc.BillingCountry = 'Australia';
        regionalAcc.Region__c = 'ANZ';
        insert regionalAcc;
        
        String approvedCompanySize = '50-99';
        String existingDomain = globAcc.Website;
        String companyLocation = 'Australia';
            
        Deal_Registration__c dealRegRecord = createDealRegistration(existingDomain, approvedCompanySize, companyLocation);
        insert dealRegRecord;
    }
    
    @isTest public static void createDealReg_allCompaniesExist(){
        Globals.CodeOff = true;

        Id mondayAccounyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        
        Account globAcc = [SELECT Id, Website FROM Account WHERE Account_Territory__c = 'Global' LIMIT 1];

        regionalAcc = TestObjectCreator.CreateCompany();
        regionalAcc.Account_Territory__c = 'Regional';
        regionalAcc.ParentId = globAcc.Id;
        regionalAcc.Company__c = globAcc.Id;
        regionalAcc.Region__c = 'ANZ';
        regionalAcc.BillingCountry = 'Australia';
        insert regionalAcc;
        
        Account regAcc = [SELECT Id FROM Account WHERE Account_Territory__c = 'Regional' LIMIT 1];
        Account localAccount = [SELECT Id FROM Account WHERE Account_Territory__c = 'Local' LIMIT 1];
        
        localAccount.ParentId = regAcc.Id;
        update localAccount;
        
        Account locAccount = [SELECT Id FROM Account WHERE Id =: localAccount.Id LIMIT 1];
        
        mondayAcc.Name = 'Test Monday Account';
        mondayAcc.RecordTypeId = mondayAccounyId;
        mondayAcc.BillingCountry = 'Australia';
        mondayAcc.ParentId = locAccount.Id;
        mondayAcc.Company__c = globAcc.Id;
        insert mondayAcc;
        
        String approvedCompanySize = '50-99';
        String existingDomain = globAcc.Website;
        String companyLocation = 'Australia';
            
        Deal_Registration__c dealRegRecord = createDealRegistration(existingDomain, approvedCompanySize, companyLocation);
        insert dealRegRecord;
    }
    
    @isTest public static void convertedLeadQueueable(){
        Globals.CodeOff = true;

        Id partnerLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        
        Account globAcc = [SELECT Id, Website FROM Account WHERE Account_Territory__c = 'Global' LIMIT 1];
        
        localAcc = TestObjectCreator.CreateCompany();
        localAcc.Account_Territory__c = 'Local';
        localAcc.ParentId = globAcc.Id;
        localAcc.Company__c = globAcc.Id;
        localAcc.BillingCountry = 'Australia';
        insert localAcc;
        
        String approvedCompanySize = '50-99';
        String existingDomain = globalAcc.Website;
        String companyLocation = 'Australia';
        
        Test.startTest();
        Deal_Registration__c dealRegRecord = createDealRegistration(existingDomain, approvedCompanySize, companyLocation);
        insert dealRegRecord;
        
        Deal_Registration__c reg = [SELECT Id FROM Deal_Registration__c WHERE Id =: dealRegRecord.Id LIMIT 1];
        
        
        newLead = new Lead();
        newLead.LastName = 'Test';
        newLead.FirstName = 'Lead';
        newLead.Deal_Registration__c = dealRegRecord.Id;
        newLead.Company = localAcc.Name;
        newLead.Company_Size__c = dealRegRecord.Company_Size__c;
        newLead.Email = dealRegRecord.Registered_Email__c;
        newLead.LeadSource = dealRegRecord.Source__c;
        newLead.RecordTypeId = partnerLead; // create partner lead
        newLead.Related_Company__c = localAcc.Company__c; //global
        newLead.Parent_Company__c = localAcc.Id; //local
        newLead.Title = dealRegRecord.Title__c;
        newLead.Country = dealRegRecord.Company_Location__c;
        newLead.Use_Cases__c = dealRegRecord.Use_Cases__c;
        newLead.Status = 'Received';
        insert newLead;

        DealRegistration_Handler.convertRelatedLead leadConv = new DealRegistration_Handler.convertRelatedLead(newLead, reg, localAcc);
        
          System.enqueueJob(leadConv);
        Test.stopTest();
    }
    
    @isTest public static void convertedOpportunityQueueable(){
        Globals.CodeOff = true;

        Id partnerLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        
        Account globAcc = [SELECT Id, Website FROM Account WHERE Account_Territory__c = 'Global' LIMIT 1];
        
        Account localAcc = [SELECT Id, Company__c, Name FROM Account WHERE Account_Territory__c = 'Local' LIMIT 1];
        
        String approvedCompanySize = '50-99';
        String existingDomain = globalAcc.Website;
        String companyLocation = 'Australia';
        
        Test.startTest();
        Deal_Registration__c dealRegRecord = createDealRegistration(existingDomain, approvedCompanySize, companyLocation);
        insert dealRegRecord;
        
        Deal_Registration__c reg = [SELECT Id, Expected_Tier__c, Expected_Plan_Seats__c, Expected_Closed_Date__c, Use_Cases__c,
                                    Department__c, OwnerId, Competition_They_re_Evaluating__c, Tools_in_their_Ecosystem__c,
                                    Current_Tool__c, Timeline_Why__c, Pains__c, Champion_Title__c, Source__c, Partner_Marketing_Activity__c, Solution__c
                                    FROM Deal_Registration__c WHERE Id =: dealRegRecord.Id LIMIT 1];
        
        newLead = new Lead();
        newLead.LastName = 'Test';
        newLead.FirstName = 'Lead';
        newLead.Deal_Registration__c = dealRegRecord.Id;
        newLead.Company = localAcc.Name;
        newLead.Company_Size__c = dealRegRecord.Company_Size__c;
        newLead.Email = dealRegRecord.Registered_Email__c;
        newLead.LeadSource = dealRegRecord.Source__c;
        newLead.RecordTypeId = partnerLead; // create partner lead
        newLead.Related_Company__c = localAcc.Company__c; //global
        newLead.Parent_Company__c = localAcc.Id; //local
        newLead.Title = dealRegRecord.Title__c;
        newLead.Country = dealRegRecord.Company_Location__c;
        newLead.Use_Cases__c = dealRegRecord.Use_Cases__c;
        newLead.Status = 'Received';
        insert newLead;
        
        //Lead thisLead = [SELECT Id FROM Lead WHERE Id =: newLead.Id LIMIT 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(newLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Id maAccountIdFromConvert = lcr.getAccountId();
        Id opportunityIdFromConvert = lcr.getOpportunityId();
        
        Lead createdLead = [SELECT Id, Deal_Registration__c, Company, Related_Company__c, ConvertedAccountId, primary_pulse_account_id__c
                            FROM Lead WHERE Deal_Registration__c =: dealRegRecord.Id LIMIT 1];

        DealRegistration_Handler.updateOpportunityMappingConvert oppConv = new DealRegistration_Handler.updateOpportunityMappingConvert(createdLead, reg, opportunityIdFromConvert, maAccountIdFromConvert, localAcc);
        
          System.enqueueJob(oppConv);
        Test.stopTest();
    }
    
    @isTest public static void convertedMaAccountQueueable(){
        Globals.CodeOff = true;

        Id partnerLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        
        Account globAcc = [SELECT Id, Website FROM Account WHERE Account_Territory__c = 'Global' LIMIT 1];
        
        Account localAcc = [SELECT Id, Name, Company__c FROM Account WHERE Account_Territory__c = 'Local' LIMIT 1];
        
        String approvedCompanySize = '50-99';
        String existingDomain = globalAcc.Website;
        String companyLocation = 'Australia';
        
        Test.startTest();
        Deal_Registration__c dealRegRecord = createDealRegistration(existingDomain, approvedCompanySize, companyLocation);
        insert dealRegRecord;
        
        Deal_Registration__c reg = [SELECT Id, Expected_Tier__c, Expected_Plan_Seats__c, Expected_Closed_Date__c, Use_Cases__c,
                                    Department__c, OwnerId, Competition_They_re_Evaluating__c, Tools_in_their_Ecosystem__c,
                                    Current_Tool__c, Timeline_Why__c, Pains__c, Champion_Title__c, Source__c, Partner_Marketing_Activity__c
                                    FROM Deal_Registration__c WHERE Id =: dealRegRecord.Id LIMIT 1];
        
        newLead = new Lead();
        newLead.LastName = 'Test';
        newLead.FirstName = 'Lead';
        newLead.Deal_Registration__c = dealRegRecord.Id;
        newLead.Company = localAcc.Name;
        newLead.Company_Size__c = dealRegRecord.Company_Size__c;
        newLead.Email = dealRegRecord.Registered_Email__c;
        newLead.LeadSource = dealRegRecord.Source__c;
        newLead.RecordTypeId = partnerLead; // create partner lead
        newLead.Related_Company__c = localAcc.Company__c; //global
        newLead.Parent_Company__c = localAcc.Id; //local
        newLead.Title = dealRegRecord.Title__c;
        newLead.Country = dealRegRecord.Company_Location__c;
        newLead.Use_Cases__c = dealRegRecord.Use_Cases__c;
        newLead.Status = 'Received';
        insert newLead;
        
        //Lead thisLead = [SELECT Id FROM Lead WHERE Id =: newLead.Id LIMIT 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(newLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Id maAccountIdFromConvert = lcr.getAccountId();
        Id opportunityIdFromConvert = lcr.getOpportunityId();
        
        Lead createdLead = [SELECT Id, Deal_Registration__c, Company, Related_Company__c, ConvertedAccountId, primary_pulse_account_id__c
                            FROM Lead WHERE Deal_Registration__c =: dealRegRecord.Id LIMIT 1];

        DealRegistration_Handler.updateAccountMappingConvert maAccountConv = new DealRegistration_Handler.updateAccountMappingConvert(createdLead, reg, maAccountIdFromConvert, localAcc);
        
          System.enqueueJob(maAccountConv);
        Test.stopTest();
    }
    
    @isTest public static void createCompanyHierarchyQueueable(){
        Globals.CodeOff = true;

        Id partnerLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        
        Account globAcc = [SELECT Id, Website FROM Account WHERE Account_Territory__c = 'Global' LIMIT 1];
        
        Account localAcc = [SELECT Id, Name, ParentId, Company__c FROM Account WHERE Account_Territory__c = 'Local' LIMIT 1];
        
        String approvedCompanySize = '50-99';
        String existingDomain = globalAcc.Website;
        String companyLocation = 'Australia';
        
        Test.startTest();
        Deal_Registration__c dealRegRecord = createDealRegistration(existingDomain, approvedCompanySize, companyLocation);
        insert dealRegRecord;
        Deal_Registration__c reg = [SELECT Id, Expected_Tier__c, Expected_Plan_Seats__c, Expected_Closed_Date__c, Use_Cases__c,
                                    Department__c, OwnerId, Competition_They_re_Evaluating__c, Tools_in_their_Ecosystem__c,
                                    Current_Tool__c, Timeline_Why__c, Pains__c, Champion_Title__c, Source__c, Regional_Company__c, Global_Company__c,
                                    Company_Location__c, Region__c, Company_Name__c, Company_Website__c, Partner_Marketing_Activity__c
                                    FROM Deal_Registration__c WHERE Id =: dealRegRecord.Id LIMIT 1];
        
        newLead = new Lead();
        newLead.LastName = 'Test';
        newLead.FirstName = 'Lead';
        newLead.Deal_Registration__c = dealRegRecord.Id;
        newLead.Company = localAcc.Name;
        newLead.Company_Size__c = dealRegRecord.Company_Size__c;
        newLead.Email = dealRegRecord.Registered_Email__c;
        newLead.LeadSource = dealRegRecord.Source__c;
        newLead.RecordTypeId = partnerLead; // create partner lead
        newLead.Related_Company__c = localAcc.Company__c; //global
        newLead.Parent_Company__c = localAcc.Id; //local
        newLead.Title = dealRegRecord.Title__c;
        newLead.Country = dealRegRecord.Company_Location__c;
        newLead.Use_Cases__c = dealRegRecord.Use_Cases__c;
        newLead.Status = 'Received';
        insert newLead;

        //Lead thisLead = [SELECT Id FROM Lead WHERE Id =: newLead.Id LIMIT 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(newLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Id maAccountIdFromConvert = lcr.getAccountId();
        Id opportunityIdFromConvert = lcr.getOpportunityId();
        
        Lead createdLead = [SELECT Id, Deal_Registration__c, Company, Related_Company__c, ConvertedAccountId, primary_pulse_account_id__c
                            FROM Lead WHERE Deal_Registration__c =: dealRegRecord.Id LIMIT 1];

        Account mondayAcc = new Account(Id = maAccountIdFromConvert);
        DealRegistration_Handler.createCompanyHierarchy companiesHier = new DealRegistration_Handler.createCompanyHierarchy(reg, localAcc, createdLead, mondayAcc);
        System.enqueueJob(companiesHier);
        Test.stopTest();
    }
    
    private static Deal_Registration__c createDealRegistration(String domain, String companySize, String companyLocation){
        Deal_Registration__c lReg = new Deal_Registration__c();
        lReg.Company_Name__c = 'Test Deal Reg';
        lReg.Company_Website__c = domain;
        lReg.Company_Size__c = companySize;
        lReg.Company_Location__c = companyLocation;
        lReg.First_Name__c = 'Test First';
        lReg.Last_Name__c = 'Test Last';
        lReg.Registered_Email__c = 'test1@test.com';
        lReg.Title__c = 'Test Title';
        lReg.Relationship__c = 'Prospect';
        lReg.Department__c = 'Digital';
        lReg.Use_Cases__c = 'Agile Management';
        lReg.Expected_Closed_Date__c= System.Today();
        lReg.Expected_Tier__c = 'Enterprise';
        lReg.Expected_Plan_Seats__c = 50;
        lReg.Source__c = 'Other';
        lReg.Comments__c = 'Test Comments';
        lReg.Competition_They_re_Evaluating__c = 'Salesforce';
        lReg.Current_Tool__c = 'Asana';
        lReg.Pains__c = 'Ease of use;Unhappy with current tool';
        lReg.Tools_in_their_Ecosystem__c = 'Salesforce;Asana';
        lReg.Region__c = 'EMEA';
        return lReg;
    }
}