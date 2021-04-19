@isTest
public class BillingEntityHandler_TEST 
{
    
    @isTest (seealldata = false)
    static void TestBETrigger()
    {
        Billing_Entity__c be = TestObjectCreator.CreateBE();
        insert be;
    }

}