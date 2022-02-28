@isTest
public without sharing class Batch_PartnersPOSurveySendTest {
    @isTest
    public static void test1(){
        Account a = TestObjectCreator.CreateAccount();
        a.Next_PO_Survey_Date__c = Date.today();
        insert a;
        Contact con = new Contact(
            LastName = 'Test',
            FirstName = 'Test',
            Email = 'test@monday.com',
            AccountId = a.Id,
            Of_Post_Onboarding_Surveys__c = 0
        );
        insert con;
        Test.startTest();
        Batch_PartnersPOSurveySend batch = new Batch_PartnersPOSurveySend();
        Database.executeBatch(batch, 30);
        Test.stopTest();
    }

    @isTest
    public static void test2(){
        String sch = '0 35 11 * * ?';
        Test.startTest();
        String jobId = System.schedule('myJobTestJobName', sch, new Batch_PartnersPOSurveySend());
        Test.stopTest();
    }
}
