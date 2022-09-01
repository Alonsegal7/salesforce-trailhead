@isTest
public without sharing class Lead_RelatedCompanyLogicTest {
    
    @TestSetup
    static void makeData(){

        Profile adminProf = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile salesProf = [SELECT Id FROM Profile WHERE Name='monday Sales - AM'];
        
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@a.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = adminProf.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
        insert manager;

        User user1 = new User(Alias = 'user1',Country='Israel',Email='user1@a.com',EmailEncodingKey='UTF-8', LastName='user1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = salesProf.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user1@monday.com', ManagerId = manager.Id, Function__c = 'Enterprise AM', Group__c = 'Sales', Business_Role__c = 'AM', Segment__c = 'Enterprise', Seniority__c = 'Rep');
        User user2 = new User(Alias = 'user2',Country='Israel',Email='user2@a.com',EmailEncodingKey='UTF-8', LastName='user2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = salesProf.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user2@monday.com', ManagerId = manager.Id, Function__c = 'Enterprise AM', Group__c = 'Sales', Business_Role__c = 'AM', Segment__c = 'Enterprise', Seniority__c = 'Rep');
        User user3 = new User(Alias = 'user3',Country='Israel',Email='user3@a.com',EmailEncodingKey='UTF-8', LastName='user3', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = salesProf.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user3@monday.com', ManagerId = manager.Id, Function__c = 'Enterprise AM', Group__c = 'Sales', Business_Role__c = 'AM', Segment__c = 'Enterprise', Seniority__c = 'Rep');
        User user4 = new User(Alias = 'user4',Country='Israel',Email='user4@a.com',EmailEncodingKey='UTF-8', LastName='user4', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = salesProf.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user4@monday.com', ManagerId = manager.Id, Function__c = 'Enterprise AM', Group__c = 'Sales', Business_Role__c = 'AM', Segment__c = 'Enterprise', Seniority__c = 'Rep');
        User user5 = new User(Alias = 'user5',Country='Israel',Email='user5@a.com',EmailEncodingKey='UTF-8', LastName='user5', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = salesProf.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user5@monday.com', ManagerId = manager.Id, Function__c = 'Enterprise AM', Group__c = 'Sales', Business_Role__c = 'AM', Segment__c = 'Enterprise', Seniority__c = 'Rep');
        
        List<User> usersToCreate = new List<User>{user1, user2, user3, user4, user5};
        insert usersToCreate;

        Country_Region_Mapping__c il = new Country_Region_Mapping__c(Name = 'IL', Country_Name__c = 'Israel', Region__c = 'EMEA');
        Country_Region_Mapping__c ca = new Country_Region_Mapping__c(Name = 'CA', Country_Name__c = 'Canada', Region__c = 'NAM');
        Country_Region_Mapping__c br = new Country_Region_Mapping__c(Name = 'BR', Country_Name__c = 'Brazil', Region__c = 'LATAM');

        List<Country_Region_Mapping__c> crm = new List<Country_Region_Mapping__c>{il,ca,br};
        insert crm;
        
        Account compA = new Account(Name = 'compA - Enterprise', RecordTypeId = Utilities.companyRecordTypeId, OwnerId = user1.Id, Strategic_receiver__c = user2.Id, NumberOfEmployees = 1600, BillingCountry = 'Israel', BillingCountryCode = 'IL', Region__c = 'EMEA', Website = 'compa.com', Account_Domains__c = '["compa.fr","compa.net"]');
        Account compB = new Account(Name = 'compB - SMB/MM', RecordTypeId = Utilities.companyRecordTypeId, OwnerId = user1.Id, Strategic_receiver__c = user2.Id, NumberOfEmployees = 350, BillingCountry = 'Canada', BillingCountryCode = 'CA', Region__c = 'NAM', Website = 'compb.com', Account_Domains__c = '["compb.fr","compb.net"]');
        
        List<Account> companiesToCreate = new List<Account>{compA, compB};
        insert companiesToCreate;

        Account regCompA = new Account(Name = 'compA - Enterprise - EMEA', RecordTypeId = Utilities.companyRecordTypeId, OwnerId = user4.Id, Strategic_receiver__c = user5.Id, BillingCountry = 'Israel', BillingCountryCode = 'IL', Region__c = 'EMEA', ParentId = compA.Id, Company__c = compA.Id, Account_Territory__c = 'Regional');
        List<Account> regCompaniesToCreate = new List<Account>{regCompA};
        insert regCompaniesToCreate;

        Account mondayAccountA1 = new Account(Name = 'mondayAccountA1', Pulse_Account_Id__c = '00011', ARR__c = 0, OwnerId = user3.Id, BillingCountry = 'Israel', BillingCountryCode = 'IL',ParentId = compA.Id, Company__c = compA.Id, RecordTypeId = Utilities.MARecordTypeId);
        Account mondayAccountA2 = new Account(Name = 'mondayAccountA2', Pulse_Account_Id__c = '00012', ARR__c = 10000, OwnerId = user3.Id, BillingCountry = 'Israel', BillingCountryCode = 'IL',ParentId = compA.Id, Company__c = compA.Id, RecordTypeId = Utilities.MARecordTypeId);
        Account mondayAccountA3 = new Account(Name = 'mondayAccountA3', Pulse_Account_Id__c = '00013', ARR__c = 15000, OwnerId = user3.Id, BillingCountry = 'Israel', BillingCountryCode = 'IL',ParentId = compA.Id, Company__c = compA.Id, RecordTypeId = Utilities.MARecordTypeId);
        Account mondayAccountA4 = new Account(Name = 'mondayAccountA4', Pulse_Account_Id__c = '00014', ARR__c = 2000, OwnerId = user3.Id, BillingCountry = 'Brazil', BillingCountryCode = 'BR', ParentId = compA.Id, Company__c = compA.Id, RecordTypeId = Utilities.MARecordTypeId);
        Account mondayAccountB1 = new Account(Name = 'mondayAccountB1', Pulse_Account_Id__c = '00021', ARR__c = 0, OwnerId = user3.Id, BillingCountry = 'Canada', BillingCountryCode = 'CA', ParentId = compB.Id, Company__c = compB.Id, RecordTypeId = Utilities.MARecordTypeId);
        Account mondayAccountB2 = new Account(Name = 'mondayAccountB2', Pulse_Account_Id__c = '00022', ARR__c = 1000, OwnerId = user3.Id, BillingCountry = 'Canada', BillingCountryCode = 'CA', ParentId = compB.Id, Company__c = compB.Id, RecordTypeId = Utilities.MARecordTypeId);
        
    List<Account> mondayAccountsToCreate = new List<Account>{mondayAccountA1, mondayAccountA2, mondayAccountA3, mondayAccountA4, mondayAccountB1, mondayAccountB2/*, mondayAccountB3*/};
        insert mondayAccountsToCreate;

        Opportunity oppA1 = new Opportunity(Name = 'oppA1 - ent open il', AccountId = mondayAccountA1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user3.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today());
        Opportunity oppA2 = new Opportunity(Name = 'oppA2 - ent open br', AccountId = mondayAccountA4.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user3.Id, CurrencyIsoCode='USD', Billing_Ids__c='123402', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today());
        Opportunity oppA3 = new Opportunity(Name = 'oppA3 - ent closed il', AccountId = mondayAccountA1.Id, Company__c = compA.Id, StageName = 'Closed Lost', OwnerId = user3.Id, CurrencyIsoCode='USD', Billing_Ids__c='123403', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today());
        Opportunity oppB1 = new Opportunity(Name = 'oppB1 - mm/smb open ca ', AccountId = mondayAccountB1.Id, Company__c = compB.Id, StageName = 'Validation', OwnerId = user3.Id, CurrencyIsoCode='USD', Billing_Ids__c='123404', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today());
        Opportunity oppB2 = new Opportunity(Name = 'oppB2 - mm/smb closed ca', AccountId = mondayAccountB1.Id, Company__c = compB.Id, StageName = 'Closed Lost', OwnerId = user3.Id, CurrencyIsoCode='USD', Billing_Ids__c='123405', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today()); 

        List<Opportunity> oppsToCreate = new List<Opportunity>{oppA1, oppA2, oppA3, oppB1, oppB2};
        insert oppsToCreate;
    }

    @isTest
    static void shouldFindRelatedCompany() {
        Lead rawSignUpA = new Lead(LastName = 'rawSignUpA', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.fr', NumberOfEmployees = 900);
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA};
        
        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c FROM Lead WHERE Id =: rawSignUpA.Id];
        Account compA = [SELECT Id, NumberOfEmployees, Company_Size__c  FROM Account WHERE Name = 'compA - Enterprise'];

        System.assertEquals(true, rawSignUpA.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA.Domain_Exists_On_Creation__c);
        System.assertEquals(compA.Id, rawSignUpA.Related_Company__c);
        System.assertEquals(900, compA.NumberOfEmployees);
        System.assertEquals('251-1500', compA.Company_Size__c);
    }

    @isTest
    static void shouldCreateCompany() { 
        Lead rawSignUpA = new Lead(LastName = 'rawSignUpA', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.br', NumberOfEmployees = 100);
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA};
        
        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, BB_Account_Domain__c, Company_Size__c, NumberOfEmployees, CountryCode, City, Company FROM Lead WHERE Id =: rawSignUpA.Id];
        Account compA = [SELECT Id FROM Account WHERE Name = 'compA - Enterprise'];
        Account newComp = [SELECT Id, Name, Website, NumberOfEmployees, Company_Size__c, BillingCountryCode, BillingCountry, BillingCity, Account_Territory__c FROM Account WHERE Id =: rawSignUpA.Related_Company__c];
        System.assertEquals(true, rawSignUpA.Related_Lead_Code__c);
        System.assertEquals(false, rawSignUpA.Domain_Exists_On_Creation__c);
        System.assertEquals(newComp.Id, rawSignUpA.Related_Company__c);
        System.assertEquals(newComp.Website, rawSignUpA.BB_Account_Domain__c);
        System.assertEquals(newComp.NumberOfEmployees, rawSignUpA.NumberOfEmployees);
        System.assertEquals(newComp.Company_Size__c, rawSignUpA.Company_Size__c);
        System.assertEquals(newComp.BillingCountryCode, rawSignUpA.CountryCode);
        System.assertEquals(newComp.BillingCity, rawSignUpA.City);
        System.assertEquals(newComp.Name, rawSignUpA.Company);
        System.assertEquals(newComp.Account_Territory__c, 'Global');
    }

    @isTest
    static void shouldAssignByRegionalCompanyToLeadRec() {
        Lead rawSignUpA = new Lead(LastName = 'rawSignUpA', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.fr', Country = 'Israel', CountryCode = 'IL');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA};
        
        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Region__c FROM Lead WHERE Id =: rawSignUpA.Id];
        Account compA = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compA - Enterprise'];
        Account regCompA = [SELECT Id, Strategic_receiver__c, OwnerId, Region__c, ParentId FROM Account WHERE Name = 'compA - Enterprise - EMEA'];

        System.assertEquals(true, rawSignUpA.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA.Domain_Exists_On_Creation__c);
        System.assertEquals(compA.Id, rawSignUpA.Related_Company__c);
        System.assertEquals(regCompA.Strategic_receiver__c, rawSignUpA.OwnerId);
        System.assertEquals('Related', rawSignUpA.Distribution_reason__c);
        System.assertEquals('Regional Company Lead Receiver', rawSignUpA.Related_Distribution_Reason__c);
        System.assertEquals('https://monday.lightning.force.com/' +regCompA.Id, rawSignUpA.Related_Record_URL__c);
    }

    @isTest
    static void shouldAssignByRegionalCompanyToOwner() {
        Lead rawSignUpA = new Lead(LastName = 'rawSignUpA', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.fr', Country = 'Israel', CountryCode = 'IL');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA};
        Account regCompA = [SELECT Id, Strategic_receiver__c, OwnerId, Region__c, ParentId FROM Account WHERE Name = 'compA - Enterprise - EMEA'];
        
        User sysAdmin = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'][0];
        System.runAs(sysAdmin) {
            update (new User(Id = regCompA.Strategic_receiver__c, IsActive = false)); //deactivate the regional company's strategic lead reciever
        }

        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Region__c FROM Lead WHERE Id =: rawSignUpA.Id];
        Account compA = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compA - Enterprise'];

        System.assertEquals(true, rawSignUpA.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA.Domain_Exists_On_Creation__c);
        System.assertEquals(compA.Id, rawSignUpA.Related_Company__c);
        System.assertEquals(regCompA.OwnerId, rawSignUpA.OwnerId);
        System.assertEquals('Related', rawSignUpA.Distribution_reason__c);
        System.assertEquals('Regional Company Owner', rawSignUpA.Related_Distribution_Reason__c);
        System.assertEquals('https://monday.lightning.force.com/' +regCompA.Id, rawSignUpA.Related_Record_URL__c);
    }

    @isTest
    static void shouldAssignByRegionalCompanyToGlobalLeadRec() {
        Lead rawSignUpA = new Lead(LastName = 'rawSignUpA', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.fr', Country = 'Israel', CountryCode = 'IL');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA};
        Account regCompA = [SELECT Id, Strategic_receiver__c, OwnerId, Region__c, ParentId FROM Account WHERE Name = 'compA - Enterprise - EMEA'];
        //in this test, instead of deactivting the owner and reciever we are replacing them with accounts pool, should go to the same path as if both users are inactive
        regCompA.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        regCompA.OwnerId = Utilities.AccountsPoolUserId;
        update regCompA;

        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Region__c FROM Lead WHERE Id =: rawSignUpA.Id];
        Account compA = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compA - Enterprise'];

        System.assertEquals(true, rawSignUpA.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA.Domain_Exists_On_Creation__c);
        System.assertEquals(compA.Id, rawSignUpA.Related_Company__c);
        System.assertEquals(compA.Strategic_receiver__c, rawSignUpA.OwnerId);
        System.assertEquals('Related', rawSignUpA.Distribution_reason__c);
        System.assertEquals('Global Company Lead Receiver', rawSignUpA.Related_Distribution_Reason__c);
        System.assertEquals('https://monday.lightning.force.com/' +compA.Id, rawSignUpA.Related_Record_URL__c);
    }

    @isTest
    static void shouldAssignByGlobalCompanyToGlobalLeadRec() {
        //in this test we are creating a signup to the same company but from a different region, the idea is to test the scenario where no regional company is matched. should go to the same path as above - as if a regioal company is matched and both the owner and reciever aren't active users
        Lead rawSignUpA = new Lead(LastName = 'rawSignUpA', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.fr', Country = 'Canada', CountryCode = 'CA');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA};
        Account compA = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compA - Enterprise'];

        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Region__c FROM Lead WHERE Id =: rawSignUpA.Id];

        System.assertEquals(true, rawSignUpA.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA.Domain_Exists_On_Creation__c);
        System.assertEquals(compA.Id, rawSignUpA.Related_Company__c);
        System.assertEquals(compA.Strategic_receiver__c, rawSignUpA.OwnerId);
        System.assertEquals('Related', rawSignUpA.Distribution_reason__c);
        System.assertEquals('Global Company Lead Receiver', rawSignUpA.Related_Distribution_Reason__c);
        System.assertEquals('https://monday.lightning.force.com/' +compA.Id, rawSignUpA.Related_Record_URL__c);
    }

    @isTest
    static void shouldAssignByGlobalCompanyToGlobalOwner() {
        //in this test we are creating a signup to the same company but from a different region, the idea is to test the scenario where no regional company is matched. should go to the same path as above - as if a regioal company is matched and both the owner and reciever aren't active users
        Lead rawSignUpA = new Lead(LastName = 'rawSignUpA', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.fr', Country = 'Canada', CountryCode = 'CA');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA};
        Account compA = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compA - Enterprise'];

        User sysAdmin = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator'][0];
        System.runAs(sysAdmin) {
            update (new User(Id = compA.Strategic_receiver__c, IsActive = false)); //deactivate the company's strategic lead reciever
        }

        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Region__c FROM Lead WHERE Id =: rawSignUpA.Id];

        System.assertEquals(true, rawSignUpA.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA.Domain_Exists_On_Creation__c);
        System.assertEquals(compA.Id, rawSignUpA.Related_Company__c);
        System.assertEquals(compA.OwnerId, rawSignUpA.OwnerId);
        System.assertEquals('Related', rawSignUpA.Distribution_reason__c);
        System.assertEquals('Global Company Owner', rawSignUpA.Related_Distribution_Reason__c);
        System.assertEquals('https://monday.lightning.force.com/' +compA.Id, rawSignUpA.Related_Record_URL__c);
    }

    @isTest
    static void shouldAssignByAccountsAndOppsSMBToPayingMAOwner() {

        Lead rawSignUpB = new Lead(LastName = 'rawSignUpB', Company = 'CompB', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compb.com', Country = 'Canada', CountryCode = 'CA');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpB};
        Account compB = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compB - SMB/MM'];

        compB.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        compB.OwnerId = Utilities.AccountsPoolUserId;
        update compB;

        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpB = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Region__c FROM Lead WHERE Id =: rawSignUpB.Id];
        Account MAb2 = [SELECT Id, OwnerId, Pulse_Account_Id__c FROM Account WHERE Company__c =: compB.Id AND Arr__c > 0 ORDER BY Arr__c DESC LIMIT 1]; //highest paying MA under the related company

        System.assertEquals(true, rawSignUpB.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpB.Domain_Exists_On_Creation__c);
        System.assertEquals('Related', rawSignUpB.Distribution_reason__c);
        System.assertEquals('Paying Monday Account Owner', rawSignUpB.Related_Distribution_Reason__c);
        System.assertEquals(MAb2.OwnerId, rawSignUpB.OwnerId);
        System.assertEquals('00022', MAb2.Pulse_Account_Id__c);
        System.assertEquals(compB.Id, rawSignUpB.Related_Company__c);
        System.assertEquals('https://monday.lightning.force.com/' +MAb2.Id, rawSignUpB.Related_Record_URL__c);
    }

    @isTest 
    static void shouldAssignByAccountsAndOppsSMBToOpenOppOwner() {

        Lead rawSignUpB = new Lead(LastName = 'rawSignUpB', Company = 'CompB', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compb.com', Country = 'Canada', CountryCode = 'CA');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpB};
        Account compB = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compB - SMB/MM'];

        compB.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        compB.OwnerId = Utilities.AccountsPoolUserId;
        update compB;

        //updating MAb2 to be non paying monday account so the related logic will go for opportunities
        Account MAb2 = [SELECT Id, OwnerId FROM Account WHERE Pulse_Account_Id__c = '00022']; //highest paying MA under the related company
        MAb2.ARR__c = 0;
        update MAb2;

        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        Opportunity oppB1 = [SELECT Id, OwnerId FROM Opportunity WHERE Company__c =: compB.Id AND IsClosed = false ORDER BY CreatedDate DESC LIMIT 1];
        rawSignUpB = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Region__c FROM Lead WHERE Id =: rawSignUpB.Id];

        System.assertEquals(true, rawSignUpB.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpB.Domain_Exists_On_Creation__c);
        System.assertEquals('Related', rawSignUpB.Distribution_reason__c);
        System.assertEquals('Open Oppty Owner', rawSignUpB.Related_Distribution_Reason__c);
        System.assertEquals(oppB1.OwnerId, rawSignUpB.OwnerId);
        System.assertEquals(compB.Id, rawSignUpB.Related_Company__c);
        System.assertEquals('https://monday.lightning.force.com/' +oppB1.Id, rawSignUpB.Related_Record_URL__c);
    }

    @isTest
    static void shouldAssignByAccountsAndOppsSMBNotFound() {
        Lead rawSignUpB = new Lead(LastName = 'rawSignUpB', Company = 'CompB', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compb.com', Country = 'Canada', CountryCode = 'CA');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpB};
        Account compB = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compB - SMB/MM'];

        compB.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        compB.OwnerId = Utilities.AccountsPoolUserId;
        update compB;

        //updating MAb2 to be non paying monday account so the related logic will go for opportunities
        Account MAb2 = [SELECT Id, OwnerId FROM Account WHERE Pulse_Account_Id__c = '00022']; //highest paying MA under the related company
        MAb2.ARR__c = 0;
        update MAb2;

        Opportunity oppB1 = [SELECT Id, OwnerId, StageName FROM Opportunity WHERE Company__c =: compB.Id AND IsClosed = false ORDER BY CreatedDate DESC LIMIT 1];
        delete oppB1;
        
        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpB = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Region__c FROM Lead WHERE Id =: rawSignUpB.Id];

        System.assertEquals(true, rawSignUpB.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpB.Domain_Exists_On_Creation__c);
        System.assertNotEquals('Related', rawSignUpB.Distribution_reason__c);
        System.assertEquals('No Assignment Found', rawSignUpB.Distribution_reason__c);
        System.assertEquals(compB.Id, rawSignUpB.Related_Company__c);
        System.assertEquals(null, rawSignUpB.Related_Record_URL__c);
    }

    @isTest
    static void shouldAssignByAccountsAndOppsENTToPayingMAOwner() {

        Lead rawSignUpA1 = new Lead(LastName = 'rawSignUpA1', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.com', Country = 'Israel', CountryCode = 'IL');
        Lead rawSignUpA2 = new Lead(LastName = 'rawSignUpA2', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.com', Country = 'Brazil', CountryCode = 'BR');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA1, rawSignUpA2};
        Account compA = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compA - Enterprise'];
        Account regCompA = [SELECT Id, Strategic_receiver__c, OwnerId, Region__c, ParentId FROM Account WHERE Name = 'compA - Enterprise - EMEA'];

        compA.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        compA.OwnerId = Utilities.AccountsPoolUserId;
        regCompA.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        regCompA.OwnerId = Utilities.AccountsPoolUserId;
        List<Account> compsToUpdate = new List<Account>{compA, regCompA};
        update compsToUpdate;

        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA1 = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Country, Region__c FROM Lead WHERE Id =: rawSignUpA1.Id];
        rawSignUpA2 = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Country, Region__c FROM Lead WHERE Id =: rawSignUpA2.Id];
        
        Account MAa3 = [SELECT Id, OwnerId, Pulse_Account_Id__c FROM Account WHERE Company__c =: compA.Id AND Arr__c > 0 AND BillingCountry =: rawSignUpA1.Country ORDER BY Arr__c DESC LIMIT 1]; //highest paying MA under the related company in the same country, should catch israel's MA
        Account MAa4 = [SELECT Id, OwnerId, Pulse_Account_Id__c FROM Account WHERE Company__c =: compA.Id AND Arr__c > 0 AND BillingCountry =: rawSignUpA2.Country ORDER BY Arr__c DESC LIMIT 1]; //same - should catch brazil's MA

        System.assertEquals(true, rawSignUpA1.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA1.Domain_Exists_On_Creation__c);
        System.assertEquals('Related', rawSignUpA1.Distribution_reason__c);
        System.assertEquals('Paying Monday Account Owner', rawSignUpA1.Related_Distribution_Reason__c);
        System.assertEquals(MAa3.OwnerId, rawSignUpA1.OwnerId);
        System.assertEquals('00013', MAa3.Pulse_Account_Id__c);
        System.assertEquals(compA.Id, rawSignUpA1.Related_Company__c);
        System.assertEquals('https://monday.lightning.force.com/' +MAa3.Id, rawSignUpA1.Related_Record_URL__c);

        System.assertEquals(true, rawSignUpA2.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA2.Domain_Exists_On_Creation__c);
        System.assertEquals('Related', rawSignUpA2.Distribution_reason__c);
        System.assertEquals('Paying Monday Account Owner', rawSignUpA2.Related_Distribution_Reason__c);
        System.assertEquals(MAa4.OwnerId, rawSignUpA2.OwnerId);
        System.assertEquals('00014', MAa4.Pulse_Account_Id__c);
        System.assertEquals(compA.Id, rawSignUpA2.Related_Company__c);
        System.assertEquals('https://monday.lightning.force.com/' +MAa4.Id, rawSignUpA2.Related_Record_URL__c);

    }

    @isTest
    static void shouldAssignByAccountsAndOppsENTToOpenOppOwner() {
        Lead rawSignUpA1 = new Lead(LastName = 'rawSignUpA1', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.com', Country = 'Israel', CountryCode = 'IL');
        Lead rawSignUpA2 = new Lead(LastName = 'rawSignUpA2', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.com', Country = 'Brazil', CountryCode = 'BR');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA1, rawSignUpA2};
        Account compA = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compA - Enterprise'];
        Account regCompA = [SELECT Id, Strategic_receiver__c, OwnerId, Region__c, ParentId FROM Account WHERE Name = 'compA - Enterprise - EMEA'];

        compA.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        compA.OwnerId = Utilities.AccountsPoolUserId;
        regCompA.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        regCompA.OwnerId = Utilities.AccountsPoolUserId;
        List<Account> compsToUpdate = new List<Account>{compA, regCompA};
        update compsToUpdate;

        List<Account> payingMAsCompA = [SELECT Id, OwnerId, Pulse_Account_Id__c FROM Account WHERE Company__c =: compA.Id AND Arr__c > 0];
        for (Account ma : payingMAsCompA) {
            ma.Arr__c = 0;
        }
        update payingMAsCompA;
        
        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA1 = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Country, Region__c FROM Lead WHERE Id =: rawSignUpA1.Id];
        rawSignUpA2 = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Country, Region__c FROM Lead WHERE Id =: rawSignUpA2.Id];
        
        Opportunity oppA1 = [SELECT Id, OwnerId FROM Opportunity WHERE Company__c =: compA.Id AND IsClosed = false AND Monday_Account_Country__c =: rawSignUpA1.Country ORDER BY CreatedDate DESC LIMIT 1]; //latest opportunity under the related company in the same country
        Opportunity oppA2 = [SELECT Id, OwnerId FROM Opportunity WHERE Company__c =: compA.Id AND IsClosed = false AND Monday_Account_Country__c =: rawSignUpA2.Country ORDER BY CreatedDate DESC LIMIT 1]; //latest opportunity under the related company in the same country
        
        System.assertEquals(true, rawSignUpA1.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA1.Domain_Exists_On_Creation__c);
        System.assertEquals('Related', rawSignUpA1.Distribution_reason__c);
        System.assertEquals('Open Oppty Owner', rawSignUpA1.Related_Distribution_Reason__c);
        System.assertEquals(oppA1.OwnerId, rawSignUpA1.OwnerId);
        System.assertEquals(compA.Id, rawSignUpA1.Related_Company__c);
        System.assertEquals('https://monday.lightning.force.com/' +oppA1.Id, rawSignUpA1.Related_Record_URL__c);

        System.assertEquals(true, rawSignUpA2.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA2.Domain_Exists_On_Creation__c);
        System.assertEquals('Related', rawSignUpA2.Distribution_reason__c);
        System.assertEquals('Open Oppty Owner', rawSignUpA2.Related_Distribution_Reason__c);
        System.assertEquals(oppA2.OwnerId, rawSignUpA2.OwnerId);
        System.assertEquals(compA.Id, rawSignUpA2.Related_Company__c);
        System.assertEquals('https://monday.lightning.force.com/' +oppA2.Id, rawSignUpA2.Related_Record_URL__c);
    }

    @isTest
    static void shouldAssignByAccountsAndOppsENTNotFound() {
        Lead rawSignUpA1 = new Lead(LastName = 'rawSignUpA1', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.com', Country = 'Israel', CountryCode = 'IL');
        Lead rawSignUpA2 = new Lead(LastName = 'rawSignUpA2', Company = 'CompA', RecordTypeId = Utilities.rawSignupRecordTypeId, BB_Account_Domain__c = 'compa.com', Country = 'Brazil', CountryCode = 'BR');
        List<Lead> rawSignUps = new List<Lead>{rawSignUpA1, rawSignUpA2};
        Account compA = [SELECT Id, Strategic_receiver__c, OwnerId FROM Account WHERE Name = 'compA - Enterprise'];
        Account regCompA = [SELECT Id, Strategic_receiver__c, OwnerId, Region__c, ParentId FROM Account WHERE Name = 'compA - Enterprise - EMEA'];

        compA.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        compA.OwnerId = Utilities.AccountsPoolUserId;
        regCompA.Strategic_receiver__c = Utilities.AccountsPoolUserId;
        regCompA.OwnerId = Utilities.AccountsPoolUserId;
        List<Account> compsToUpdate = new List<Account>{compA, regCompA};
        update compsToUpdate;

        List<Account> payingMAsCompA = [SELECT Id, OwnerId, Pulse_Account_Id__c FROM Account WHERE Company__c =: compA.Id AND Arr__c > 0];
        for (Account ma : payingMAsCompA) {
            ma.Arr__c = 0;
        }
        update payingMAsCompA;

        List<Opportunity> openOppsCompA = [SELECT Id, OwnerId, StageName FROM Opportunity WHERE Company__c =: compA.Id AND IsClosed = false];
        delete openOppsCompA;
        
        Test.startTest();
        insert rawSignUps;
        Test.stopTest();
        
        rawSignUpA1 = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Country, Region__c FROM Lead WHERE Id =: rawSignUpA1.Id];
        rawSignUpA2 = [SELECT Id, Related_Company__c, Domain_Exists_On_Creation__c, Related_Lead_Code__c, OwnerId, Distribution_reason__c, Related_Distribution_Reason__c, Related_Record_URL__c, Country, Region__c FROM Lead WHERE Id =: rawSignUpA2.Id];
        
        System.assertEquals(true, rawSignUpA1.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA1.Domain_Exists_On_Creation__c);
        System.assertNotEquals('Related', rawSignUpA1.Distribution_reason__c);
        System.assertEquals('No Assignment Found', rawSignUpA1.Distribution_reason__c);
        System.assertEquals(compA.Id, rawSignUpA1.Related_Company__c);
        System.assertEquals(null, rawSignUpA1.Related_Record_URL__c);
        
        System.assertEquals(true, rawSignUpA2.Related_Lead_Code__c);
        System.assertEquals(true, rawSignUpA2.Domain_Exists_On_Creation__c);
        System.assertNotEquals('Related', rawSignUpA2.Distribution_reason__c);
        System.assertEquals('No Assignment Found', rawSignUpA2.Distribution_reason__c);
        System.assertEquals(compA.Id, rawSignUpA2.Related_Company__c);
        System.assertEquals(null, rawSignUpA2.Related_Record_URL__c);
    }
}