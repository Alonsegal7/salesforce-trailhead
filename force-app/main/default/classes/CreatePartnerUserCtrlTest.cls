@isTest
public class CreatePartnerUserCtrlTest {
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

	static testmethod void test_getFieldsList(){
		Contact con = [select Id, AccountId, Account.IsPartner, Email from Contact limit 1];
        List<String> contactFieldNamesList = new List<String>();
        for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Create_Community_User.getFields()) {
            contactFieldNamesList.add(f.getFieldPath());
        }
		Test.startTest();
		CreatePartnerUserCtrl.resWrapper res = CreatePartnerUserCtrl.getFieldsList(con.Id, con.Email, con.AccountId, con.Account.IsPartner, 'Approved');
		Test.stopTest();
		System.assertEquals(contactFieldNamesList, res.contactFieldNamesList);
	}

    static testmethod void test_getFieldsList_existingUser(){
		Contact con = [select Id, AccountId, Account.IsPartner, Email from Contact limit 1];
        con.Email = UserInfo.getUserEmail();
        update con;
		Test.startTest();
		CreatePartnerUserCtrl.resWrapper res = CreatePartnerUserCtrl.getFieldsList(con.Id, con.Email, con.AccountId, con.Account.IsPartner, 'Approved');
		Test.stopTest();
		System.assertNotEquals(null, res.existingUserId);
	}

    static testmethod void test_ContactGetsApproved_TestTrigger(){
		Contact con = [select Id, Email from Contact limit 1];
        con.Community_User_Approved__c = true;
        con.Send_Welcome_Email__c = true;
		Test.startTest();
        update con;
        Test.stopTest();
        con = [select Id, Community_User__c, Email from Contact limit 1];
        User newUser = [select Id, Email from User where Id =: con.Community_User__c];
		System.assertEquals(con.Email, newUser.Email);
	}

	static testmethod void test_ContactSendWelcomeEmail_TestTrigger(){
		Contact con = [select Id from Contact limit 1];
        con.Community_User__c = UserInfo.getUserId();
        con.Send_Welcome_Email__c = true;
		Test.startTest();
        update con;
        Test.stopTest();
	}

    static testmethod void test_ContactGetsApproved_TestSubmitApproved(){
		Contact con = [select Id, Email from Contact limit 1];
        con.Send_Welcome_Email__c = true;
		Test.startTest();
        User newUser = CreatePartnerUserCtrl.submitNewUserRequest(con.Id, con, 'Approved');
        Test.stopTest();
        con = [select Id, Community_User__c, Email from Contact limit 1];
        System.assertEquals(con.Community_User__c, newUser.Id);
        newUser = [select Id, Email from User where Id =: con.Community_User__c];
		System.assertEquals(con.Email, newUser.Email);
	}

    static testmethod void test_ContactGetsApproved_TestSubmit(){
		Contact con = [select Id, Email from Contact limit 1];
        con.Send_Welcome_Email__c = true;
		Test.startTest();
        CreatePartnerUserCtrl.submitNewUserRequest(con.Id, con, '');
        Test.stopTest();
        con = [select Id, Approval_Status_Partner_Users__c from Contact limit 1];
        System.assertEquals('Pending', con.Approval_Status_Partner_Users__c);
	}
}