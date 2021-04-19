@isTest
public class IConductServiceTest {
    
    @isTest
	static void handleBillingEntitySync() {
        Test.startTest();
        Billing_Entity__c be = new Billing_Entity__c(Name = 'Test billing entity');
        insert be;
        
        IConductService.handleBillingEntitySync(be.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void handleQuoteSync() {
        Test.startTest();
        
        Billing_Entity__c be = new Billing_Entity__c(Name = 'Test billing entity');
        insert be;
        
        IConductService.handleQuoteSync(be.Id);
        Test.stopTest();
    }
}