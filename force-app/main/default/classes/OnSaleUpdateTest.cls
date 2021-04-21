@isTest
public class OnSaleUpdateTest {
    static testMethod void testSale() {
       Test.startTest();
       Account c = new Account(Name='company 1');
       insert c;
	   Sale__c  o = new Sale__c(Company__c=c.Id, Close_Date__c=Date.newInstance(2019, 12, 1));
	   insert o;
       Test.stopTest();
	}
}