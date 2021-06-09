@isTest
public class OnLeadUpdateTest {
	static testMethod void testLead() {
       Test.startTest();
       Account c = new Account(Name='company 1');
       insert c;
	   Lead  o = new Lead(Email='moshe@david.com', LastName='david', FirstName='moshe', Company='com inc');
	   insert o;
       Test.stopTest();
	}
}