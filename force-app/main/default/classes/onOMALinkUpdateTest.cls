@isTest
public class onOMALinkUpdateTest {
    static testMethod void testDummy() {
        Test.startTest();
        Account c = new Account(Name='company 1');
        insert c;
        Opportunity opp = new Opportunity(AccountId=c.Id, Name='test opp', StageName='Closed Lost', CloseDate=System.today());
        insert opp;
        Monday_Account__c m = new Monday_Account__c(Company__c=c.Id);
        insert m;
        OpportunitiesMondayAccountsLink__c  o = new OpportunitiesMondayAccountsLink__c(Opportunity__c=opp.Id, Monday_Account__c=m.Id);
        insert o;
        Test.stopTest();
    }
}