@isTest
public without sharing class CompanyDomain_ServiceTest {
    
    @TestSetup
    static void makeData(){
        String website1 = 'http://www.test1.com';

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = TestUtils.getUserWithoutRole(profileId);
        user.Office__c = 'Tel Aviv Office';
        insert user;

        Account comp = TestObjectCreator.CreateCompany();
        comp.OwnerId = user.Id;
        comp.Name = 'testco1';
        comp.Website = website1;
        insert comp;
    }
    
    @isTest
    static void shouldFormatDomainFromCompanyWebsite() {
        
        Account comp = [SELECT Id FROM Account LIMIT 1];
        Company_Domain__c c1 = [SELECT Id, Domain__c FROM Company_Domain__c WHERE Company__c =: comp.Id];
        System.assertEquals(c1.Domain__c, 'test1.com');
    }
    
    @isTest
    static void shouldFormatDomainFromAddDomains() {
        
        String website2= 'https://www.test2.com/';
        String website3 = 'www.test3.com/test1234';
        Account comp = [SELECT Id FROM Account LIMIT 1];
        
        List<Company_Domain__c> cdList = new List<Company_Domain__c>();
        cdList.add(new Company_Domain__c(Domain__c = website2, Company__c = comp.Id));
        cdList.add(new Company_Domain__c(Domain__c = website3, Company__c = comp.Id));
        
        insert cdList;
        
        Company_Domain__c c2 = [SELECT Id, Domain__c FROM Company_Domain__c WHERE Company__c =: comp.Id AND Domain__c LIKE '%test2%'];
        Company_Domain__c c3 = [SELECT Id, Domain__c FROM Company_Domain__c WHERE Company__c =: comp.Id AND Domain__c LIKE '%test3%'];
        
        System.assertEquals(c2.Domain__c, 'test2.com');
        System.assertEquals(c3.Domain__c, 'test3.com');

    }
}