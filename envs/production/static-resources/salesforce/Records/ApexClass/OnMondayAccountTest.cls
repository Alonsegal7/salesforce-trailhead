@isTest
public class OnMondayAccountTest {
    static testMethod void testDummy() {
        Test.startTest();
        Account c = new Account(Name='company 1');
        insert c;
        Monday_Account__c m = new Monday_Account__c(Company__c=c.Id);
        insert m;
        Test.stopTest();
    }
}