@isTest
public class IConductServiceTest {
    
    @isTest
	static void handleBillingEntitySync() {
        Test.startTest();
        Billing_Entity__c be = TestObjectCreator.CreateBE();
        insert be;
        
        System.enqueueJob(new IConductService('BillingEntityERPInsertUpdateSync',be.Id));
        Test.stopTest();
    }
    
    @isTest
    public static void handleQuoteSync() {
        Test.startTest();
        
        Billing_Entity__c be = TestObjectCreator.CreateBE();
        insert be;
        
        System.enqueueJob(new IConductService('QuoteERPInsertOnlySync',be.Id));
        Test.stopTest();
    }
}