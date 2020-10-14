@isTest
public class OnContactUpdateTest {
	static testMethod void testContact() {
       Test.startTest();
       Account c = new Account(Name='company 1');
       insert c;
	   Contact o = new Contact(Email='moshe@david.com', LastName='david', FirstName='moshe');
	   insert o;
       Test.stopTest();
	}
}