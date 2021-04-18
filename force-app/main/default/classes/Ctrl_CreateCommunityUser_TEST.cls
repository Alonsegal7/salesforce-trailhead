@isTest 
private class Ctrl_CreateCommunityUser_TEST {

	@isTest
	private static void testName() {
		Globals.CodeOff = true;
		Account a = TestObjectCreator.CreateAccount();
		insert a;

		Globals.CodeOff = true;
		Contact c = TestObjectCreator.CreateContact(a);
		c.Contact_Role__c = 'Evaluator';
		insert c;

		Ctrl_CreateCommunityUser.getInitialParams(c.Id);

	}
}