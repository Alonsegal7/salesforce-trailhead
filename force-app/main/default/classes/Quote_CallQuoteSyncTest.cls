
@isTest
public class Quote_CallQuoteSyncTest {
    @TestSetup
    static void makeData(){
        TestObjectCreator.persistImmediate = true;

        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Contract contract = TestObjectCreator.CreateContract(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
        quoteNewCont.DH_Quote_Status__c='Won';
        quoteNewCont.Document_Type__c='Sales Order';
        //insert quoteNewCont;
        TestObjectCreator.persistImmediate = false;

    }
    @isTest
    static void RunSyncTest() {
        Test.startTest();
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        testQuote.Sync_Request_Timestamp_iConduct__c= Datetime.now();
        update testQuote; 
        Test.stopTest();
    }
}
