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
        Quote quote = TestObjectCreator.CreateQuote(opportunity, contract, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quote, 'License', 1, 1.0);
        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
        
		ContractService.handleQuoteFinalized(quote);
            
        TestObjectCreator.persistImmediate = false;
        Test.stopTest();
    }
    
}