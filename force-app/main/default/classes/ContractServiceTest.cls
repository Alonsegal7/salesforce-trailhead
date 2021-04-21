@isTest
public class ContractServiceTest {

    @isTest
	static void handleQuoteFinalized() {
        Test.startTest();
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
        update quoteNewCont;
        quoteNewCont.Manual_Trigger__c = 'Create Active Contract';
        update quoteNewCont;
            
        TestObjectCreator.persistImmediate = false;
        Test.stopTest();
    }
    

}