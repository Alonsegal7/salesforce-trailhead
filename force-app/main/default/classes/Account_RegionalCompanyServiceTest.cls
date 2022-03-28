@isTest
public without sharing class Account_RegionalCompanyServiceTest {
    @TestSetup
    static void makeData(){

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = TestUtils.getUserWithoutRole(profileId);
        user.Office__c = 'Tel Aviv Office';
        insert user;

        Account comp = TestObjectCreator.CreateCompany();
        comp.OwnerId = user.Id;
        comp.Name = 'testco1';
        insert comp;

        Lead lead = TestObjectCreator.createLead();
        lead.Related_Company__c = comp.Id;
        lead.Region__c = 'EMEA';
        insert lead;

        Lead leadUnqualified = TestObjectCreator.createLead();
        leadUnqualified.Related_Company__c = comp.Id;
        leadUnqualified.Region__c = 'EMEA';
        leadUnqualified.Status = 'Unqualified';
        leadUnqualified.LastName = 'test3';
        insert leadUnqualified;

        Account regCompEmea = TestObjectCreator.CreateCompany();
        regCompEmea.OwnerId = user.Id;
        regCompEmea.Name = 'testco1 - EMEA';
        regCompEmea.Account_Territory__c = 'Regional';
        regCompEmea.Region__c = 'EMEA';
        regCompEmea.ParentId = comp.Id;
        regCompEmea.Company__c = comp.Id;
        insert regCompEmea;
    }
    
    @isTest
    static void shouldCreateRegionalCompanyOnCreate() {
        
        Account comp = [SELECT Id FROM Account WHERE Name = 'testco1'];

        Test.startTest();

        Account mondayAcc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId(), 
            Name = 'testMA1', 
            primary_pulse_account_id__c = '12345',
            BillingCountryCode = 'CA',
            BillingCountry = 'Canada',
            Region__c = 'NAM',
            ParentId = comp.Id,
            Company__c = comp.Id);
            insert mondayAcc;
            
        Test.stopTest();

        comp = [SELECT Id, ParentId, Company__c, Account_Territory__c FROM Account WHERE Name = 'testco1'];
        mondayAcc = [SELECT Id, Region__c, ParentId, Company__c FROM Account WHERE primary_pulse_account_id__c = '12345'];
        Account regionalCompany1 = [SELECT Id, Name, Account_Territory__c, Region__c, Company__c, ParentId FROM Account WHERE Id = :mondayAcc.ParentId];

        System.debug('regionalCompany1 name: '+ regionalCompany1.Name + 'Territory: ' + regionalCompany1.Account_Territory__c);
        
        System.assertEquals(mondayAcc.Region__c, 'NAM');
        System.assertEquals(mondayAcc.Company__c, comp.Id);
        System.assertEquals(mondayAcc.ParentId, regionalCompany1.Id);
        
        System.assertEquals(regionalCompany1.Region__c, 'NAM');
        System.assertEquals(regionalCompany1.Account_Territory__c, 'Regional');
        System.assertEquals(regionalCompany1.ParentId, comp.Id);
        System.assertEquals(regionalCompany1.Company__c, comp.Id);
        
        System.assertEquals(comp.Account_Territory__c, 'Global');
        System.assertEquals(comp.ParentId, null);
        System.assertEquals(comp.Company__c, null);
    }

    @isTest
    static void shouldLinkToExistingRegionalCompanyOnCreate() {
        
        Account comp = [SELECT Id FROM Account WHERE Name = 'testco1'];
        Account regCoEmea = [SELECT Id FROM Account WHERE Name = 'testco1 - EMEA'];

        Test.startTest();

        Account mondayAcc2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId(), 
            Name = 'testMA2', 
            primary_pulse_account_id__c = '12345',
            BillingCountryCode = 'IL',
            BillingCountry = 'Israel',
            Region__c = 'EMEA',
            ParentId = comp.Id,
            Company__c = comp.Id);
            insert mondayAcc2;
            
        Test.stopTest();

        comp = [SELECT Id, ParentId, Company__c, Account_Territory__c FROM Account WHERE Name = 'testco1'];
        mondayAcc2 = [SELECT Id, Region__c, ParentId, Company__c FROM Account WHERE primary_pulse_account_id__c = '12345'];
        Account regionalCompany2 = [SELECT Id, Name, Account_Territory__c, Region__c, Company__c, ParentId FROM Account WHERE Id = :mondayAcc2.ParentId];
        
        System.assertEquals(mondayAcc2.Company__c, comp.Id);
        System.assertEquals(mondayAcc2.ParentId, regionalCompany2.Id);
        
        System.assertEquals(regionalCompany2.Id, regCoEmea.Id);
        System.assertEquals(regionalCompany2.Region__c, 'EMEA');
        System.assertEquals(regionalCompany2.Account_Territory__c, 'Regional');
        System.assertEquals(regionalCompany2.ParentId, comp.Id);
        System.assertEquals(regionalCompany2.Company__c, comp.Id);
        
        System.assertEquals(comp.Account_Territory__c, 'Global');
        System.assertEquals(comp.ParentId, null);
        System.assertEquals(comp.Company__c, null);
    }
    
    @isTest
    static void shouldLinkExistingLeadToRegioalCompany() {
        
        Account regCoEmea = [SELECT Id FROM Account WHERE Name = 'testco1 - EMEA'];
        Lead lead = [SELECT Id, Related_Company__c, Parent_Company__c FROM Lead WHERE LastName = 'test'];
        System.assertEquals(lead.Parent_Company__c, regCoEmea.Id);
    }

    @isTest
    static void shouldLinkNewLeadToRegioalCompany() {
        
        Account regCoEmea = [SELECT Id FROM Account WHERE Name = 'testco1 - EMEA'];
        Account comp = [SELECT Id FROM Account WHERE Name = 'testco1'];

        Test.startTest();

        Lead lead2 = TestObjectCreator.createLead();
        lead2.Related_Company__c = comp.Id;
        lead2.LastName = 'test2';
        lead2.Region__c = 'EMEA';
        insert lead2;

        Test.stopTest();
        
        lead2 = [SELECT Id, Related_Company__c, Parent_Company__c FROM Lead WHERE LastName = 'test2'];
        System.assertEquals(lead2.Parent_Company__c, regCoEmea.Id);
    }

    @isTest
    static void shouldLinkResubmittedLeadToRegioalCompany() {
        
        Lead leadUnqualified = [SELECT Id, Related_Company__c, Parent_Company__c FROM Lead WHERE LastName = 'test3'];
        Account regCoEmea = [SELECT Id FROM Account WHERE Name = 'testco1 - EMEA'];

        Test.startTest();

        leadUnqualified.Status = 'Received';
        update leadUnqualified;

        Test.stopTest();
        
        leadUnqualified = [SELECT Id, Related_Company__c, Parent_Company__c FROM Lead WHERE LastName = 'test3'];
        System.assertEquals(leadUnqualified.Parent_Company__c, regCoEmea.Id);
    }
}