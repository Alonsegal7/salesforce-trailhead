@isTest 
private class Lookup_Ctrl_TEST {
	@testSetup
    private static void setup(){
	    Account acc = new Account(Name='Test1', BillingCountry='Angola', Website='Test1@test1.co.il');
		insert acc;
        insert new Contact(LastName = 'Test1', FirstName = 'Name1', AccountId = acc.Id);
        insert new Contact(LastName = 'Test2', FirstName = 'Name2', AccountId = acc.Id);
        insert new Contact(LastName = 'Test3', FirstName = 'Name3', AccountId = acc.Id);
    }
    
    static testMethod void lookupTest() {
        // TO DO: implement unit test
        List<Contact> contacts = [Select Id, LastName, FirstName, Name From Contact];
        
        Test.startTest();
        Lookup_Ctrl.searchDB('Contact', 'Name', 'Id', 3, 'Name', 'Name', null, 'LastName');
		Lookup_Ctrl.searchDB('Contact', 'Name', 'Id', 3, 'Name_OR_Email', 'Name', null, 'LastName');
        Test.stopTest();
    }
}