@isTest
public without sharing class ServiceOpportunityCreationTest {
    @TestSetup
    static void makeData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userRecord1 = TestUtils.getUserWithoutRole(profileId);
        userRecord1.LastName = 'Test1';
        userRecord1.Created_date__c = date.today();
        insert userRecord1;
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        Account MAaccountRecord = TestObjectCreator.CreateMondayAccount(company);
        insert MAaccountRecord;
        MAaccountRecord.OwnerId = userRecord1.Id;
        MAaccountRecord.Pricing_Version__c = '10';
        MAaccountRecord.CurrencyIsoCode='USD';
        MAaccountRecord.primary_pulse_account_id__c='123';
        update MAaccountRecord; 
        Contract contract = TestObjectCreator.CreateContract(MAaccountRecord);
       
    }

    @isTest
    static void checkOpportunityCreation(){
        Account accountforserviceId = [SELECT Id,Active_Contract__c FROM Account limit 1];
        Id InternalOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        Test.startTest();
        User userRecord1 = [SELECT Id FROM User LIMIT 1][0];
        List<Id>accountsforserviceIds = new List<Id>();
        accountsforserviceIds.add(accountforserviceId.Id);
        ServiceOpportunityCreation.createServiceOpportunities(accountsforserviceIds);   
        test.stopTest();
        opportunity opp = [SELECT Id,Selected_Company_Contract__c,RecordTypeId FROM Opportunity LIMIT 1];

        system.assertNotEquals(opp.Id,null); 
        system.assertEquals(InternalOppRtId,opp.RecordTypeId);
        system.assertEquals(accountforserviceId.Active_Contract__c,opp.Selected_Company_Contract__c);
    }
}