@IsTest
public class LMS_AssignmentHandler_TEST  {
    @TestSetup
    public static void setup(){
        /// create Account and Contact for LMS_AssignmentHandler
        TestObjectCreator.persistImmediate = true;
        Account testAccount = TestObjectCreator.CreateAccount();
        System.debug(testAccount);

        Contact testContact = new Contact(Email='test@randomdemodomain.com', FirstName = 'test', LastName = 'tts', AccountId = testAccount.Id);
        insert testContact;
    }

    @IsTest
    public static void runTrigger(){
        ///Insert and Update LMS_Assignment 
        Contact oneContact = [select id from Contact LIMIT 1];
        LMS_Assignment__c testLMS_Assignment = new LMS_Assignment__c(name = 'LMSTest', Contact__c = oneContact.Id, Resource_Name__c='Advanced Workflow Badge');
        Insert testLMS_Assignment;

        testLMS_Assignment.Status__c = 'Completed';
        Update testLMS_Assignment;

    }


}