@isTest
public without sharing class Batch_PartnersPOSurveySendTest {
    @isTest
    public static void test1(){
        Account a = TestObjectCreator.CreateAccount();
        insert a;
        list<Contact> con_list = new list<Contact>{
            new Contact(
                LastName = 'Test',
                FirstName = 'Test',
                Email = 'test@monday.com',
                AccountId = a.Id
            ),
            new Contact(
                LastName = 'Test2',
                FirstName = 'Test2',
                Email = 'test2@monday.com',
                AccountId = a.Id
            )
        };
        insert con_list;
        Survey__c s = new Survey__c(
            Account__c = a.Id,
            Survey_Sent_Date__c = Date.today(),
            Survey_Type__c = 'Partners - Post Onboarding',
            Survey_Status__c = 'Future'
        );
        insert s;
        Test.startTest();
        Batch_PartnersPOSurveySend batch = new Batch_PartnersPOSurveySend();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        list<Survey__c> survey_list = [select Id from Survey__c];
        system.assertEquals(3, survey_list.size()); //should create 1 surveys for the second contact and another survey for future date - so total 3
    }

    @isTest
    public static void test2(){
        String sch = '0 35 11 * * ?';
        Test.startTest();
        String jobId = System.schedule('myJobTestJobName', sch, new Batch_PartnersPOSurveySend());
        Test.stopTest();
    }
}