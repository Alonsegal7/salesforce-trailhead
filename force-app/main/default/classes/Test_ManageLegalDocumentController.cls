@isTest
public with sharing class Test_ManageLegalDocumentController {

    @isTest
	static void ManageLegalDocumentTest() {
        Test.startTest();
        TestObjectCreator.persistImmediate = true;
        
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Contract contract = TestObjectCreator.CreateContract(ma);
        Billing_Entity__c be = TestObjectCreator.CreateBE();
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
        quoteNewCont.Legal_Agreement_Type__c='monday.com SaaS';
        quoteNewCont.Document_Type__c='Sales Order';
        quoteNewCont.Billing_Entity__c=be.Id;
        opportunity.Billing_Entity__c=be.Id;
        opportunity.SyncedQuoteId = quoteNewCont.Id;
        opportunity.company__c=company.id;
        Legal_Document__c ld = new Legal_Document__c(Company__c=company.Id,Document_type__c='SaaS Agreement');
        insert ld;
        update quoteNewCont;
        update opportunity;

        Quote q = ManageLegalDocumentController.getSalesOrderDetails(opportunity.Id);
        list<Legal_Document__c> lglDoc = ManageLegalDocumentController.legalDocExistForCompany(opportunity.Id,'SaaS Agreement');
        TestObjectCreator.persistImmediate = false;
        Test.stopTest();
    }
    

}