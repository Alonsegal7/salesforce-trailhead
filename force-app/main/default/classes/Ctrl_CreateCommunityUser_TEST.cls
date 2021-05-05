@isTest 
private class Ctrl_CreateCommunityUser_TEST {
	@TestSetup
	static void setup(){
		Account acc = new Account();
		acc.Name = 'Test CreateCommunityUser';
		acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
		acc.Partner_Type__c = 'Channel';
		acc.Website = 'testmonday.com';
		acc.Partner_Company_Status__c = 'New';
		insert acc;
		Contact con = new Contact();
		con.LastName = 'bla';
		con.FirstName = 'a';
		con.Email = 'test@testmonday.com';
		con.AccountId = acc.Id;
		con.Company__c = acc.Id;
		insert con;
	}

	static testmethod void test1(){
		Contact con = [select Id, Email from Contact limit 1];
		Test.startTest();
		Ctrl_CreateCommunityUser.resWrapper res = Ctrl_CreateCommunityUser.getFieldsList(con.Id, con.Email);
		Test.stopTest();
		System.assertEquals(false, res.contactFieldNamesList.isEmpty());
	}

	static testmethod void test2(){
		Contact con = [select Id, Email from Contact limit 1];
		Test.startTest();
		User newUser = Ctrl_CreateCommunityUser.createUser(con.Id, null, UserInfo.getUserId());
		Ctrl_CreateCommunityUser.resWrapper res = Ctrl_CreateCommunityUser.getFieldsList(con.Id, con.Email);
		Test.stopTest();
		System.assertNotEquals(null, newUser.Id);
		System.assertEquals(null, res.contactFieldNamesList);
		System.assertEquals(newUser.Id, res.existingUserId);
	}
}