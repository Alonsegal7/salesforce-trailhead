@isTest
public with sharing class Quote_CloseCorrectionOppTest {
    @TestSetup
    static void makeData(){
        //create required records
        TestObjectCreator.persistImmediate = true;
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Contract contract = TestObjectCreator.CreateContract(company);
        
        //create correction opportunity & related quote
        Id correctionOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Correction_Opportunity').getRecordTypeId();
        opportunity.RecordTypeId = correctionOppRT;
        update opportunity;
        Quote quote = TestObjectCreator.CreateQuote(opportunity, contract, 'New Contract');
        opportunity.SyncedQuoteId = quote.Id;
        update opportunity;
    }

    @isTest
    static void testUpdateOppToClosedWon(){
        Test.startTest();
        Quote q = [SELECT Id FROM Quote limit 1];
        q.DH_Quote_Status__c = 'Won';
        update q;
        Test.stopTest();
        Opportunity o = [SELECT Id, StageName FROM Opportunity limit 1];
        system.assertEquals(o.StageName, 'Closed Won'); //check if opp was set to closed won
    }
}