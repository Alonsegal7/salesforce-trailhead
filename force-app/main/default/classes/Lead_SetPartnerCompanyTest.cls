@isTest
public without sharing class Lead_SetPartnerCompanyTest {
    
    @TestSetup
    static void makeData(){
        User partnerUser = TestObjectCreator.createValidPartnerUser();
        Account comp1 = TestObjectCreator.CreateCompany();
        insert comp1;
        Lead preLead = new Lead(
            LastName = 'Test lName1',
            Company = 'Testco',
            Email = 'test@testco.com',
            Related_Company__c = comp1.Id,
            RecordTypeId = Utilities.preLeadRecordTypeId
        );
    }

    @isTest
    static void shouldSetPartnerCompanyOnLeadPoolLead() {
        
        User partnerUser = [SELECT Id FROM User WHERE Email='demo1@randomdemodomain.com'];
        Lead preLeadToDist = [SELECT Id, OwnerId FROM Lead WHERE Email = 'test@testco.com'];
        Account partnerCompany = [SELECT Id FROM Account WHERE Name = 'testPartner'];
        
        Test.startTest();
        preLeadToDist.OwnerId = partnerUser.Id;
        update partnerUser;
        Test.stopTest();
        
        preLeadToDist = [SELECT Id, RecordTypeId, Partner_Company__c FROM Lead WHERE Email = 'test@testco.com'];
        System.assertEquals(Utilities.partnerCompanyRecordTypeId, preLeadToDist.RecordTypeId);
        System.assertEquals(partnerCompany.Id, preLeadToDist.Parent_Company__c);
    }
}
