@isTest
private class CalloutHandler_TEST
{
    @isTest (seealldata = false)    
    private static void TestCalloutHandler()
    {
        BigBrain_Callout_Control__mdt Sett = [select id,DELETE__c,INSERT__c,UPDATE__c,Field_Set_Name__c,masterlabel from BigBrain_Callout_Control__mdt where masterlabel=:'Account'];
        system.debug('TESTING sett is '+Sett);
        
        
        Account a = TestObjectCreator.CreateAccount();
        insert a;
        
        a.name = 'TestUpdate';
        update a;
        
        
    }
}