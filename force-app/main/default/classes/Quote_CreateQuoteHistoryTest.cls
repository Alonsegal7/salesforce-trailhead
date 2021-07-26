@isTest
public with sharing class Quote_CreateQuoteHistoryTest {
    @TestSetup
    static void makeData(){
        TestObjectCreator.persistImmediate = true;
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
    }
    @isTest
    static void createQuoteHistory(){
        Test.startTest();
        Quote q = [SELECT Id, DH_Quote_Status__c FROM Quote limit 1];
        q.DH_Quote_Status__c='Approved';
        update q;
        Test.stopTest();

    }
}