@isTest
public with sharing class ServiceOpportunityCreationTest {
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
    static void Checkopportunitycreation(){
        Account accountforserviceId = [SELECT Id,Active_Contract__c FROM Account limit 1];
        Test.startTest();
        User userRecord1 = [SELECT Id FROM User LIMIT 1][0];
        System.runAs(userRecord1){
            List<Id>accountsforserviceIds = new List<Id>();
            accountsforserviceIds.add(accountforserviceId.Id);
            ServiceOpportunityCreation.createServiceOpportunities(accountsforserviceIds);   
            test.stopTest();
        }
        opportunity opp = [SELECT Id FROM Opportunity];
        //query of the opp that has been created 
        system.assertNotEquals(opp.Id,null); // check if the opp created 
        //system.assertEquals(user2.Email, acc.Owner_s_Email__c); //check if the type correct 
        //system.assertEquals(user2.Email, acc.Owner_s_Email__c);// check if the active contract is the same as the account active contract 
    }
}
    
  
