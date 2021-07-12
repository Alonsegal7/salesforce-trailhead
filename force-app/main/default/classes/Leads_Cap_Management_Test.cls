@isTest
public class Leads_Cap_Management_Test {
    @TestSetup
	static void setup(){
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Id partnerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        Id internalLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Internal_Lead').getRecordTypeId();
        Id partnerCompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
		Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;

        Lead intLead = new Lead(LastName='LeadForTestInt', Status='Received', LeadSource='g2crowd', Company='LeadForTest', Email='lead1@test.for', recordTypeId=internalLeadRecordTypeId);
        insert intLead;

        Lead parLead = new Lead(LastName='LeadForTestPar', Status='Received', LeadSource='g2crowd', Company='LeadForTest', Email='lead2@test.for', recordTypeId=partnerLeadRecordTypeId);
        insert parLead;
	}

	static testmethod void test_salesUserLeadsCapCreation(){
        Id internalLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Internal_Lead').getRecordTypeId();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
		Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		//insert manager;
        User manager=[select id from User where ProfileId =: admin.Id limit 1];
		User user = new User(Alias='standt1', ManagerId=manager.Id, Country='United Kingdom',Email='user1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = profile.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com', should_get_leads_from_BigBrain__c=true);
		insert user;
        
        Leads_Cap__c lc=[select id from Leads_Cap__c where User__c=:user.Id limit 1];
        System.assertNotEquals(lc, null);

        user.Manual_Trigger__c='Create Leads Cap';
        update user;

        lead intLead=[select id from Lead where recordtypeid=:internalLeadRecordTypeId];
        intLead.OwnerId=user.Id;
        update intLead;

        Database.executeBatch(new Lead_Cap_CalcOpenLeads());

	}

    static testmethod void test_partnersUserLeadsCapCreation(){
        Id partnerCompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Id partnerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        Account pCompany = new Account(Name='Partner Company', RecordTypeId=partnerCompanyRecordTypeId,Signature_Approval_Status__c='Approved');
		insert pCompany;
        pCompany.Partner_Company_Status__c='Signed';
        update pCompany;
        Leads_Cap__c lc=[select id from Leads_Cap__c where Channel_Partner__c=:pCompany.Id limit 1];
        System.assertNotEquals(lc, null);
        pCompany.Manual_Trigger__c='Create Leads Cap';
        update pCompany;

        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager=[select id from User where ProfileId =: admin.Id limit 1];
        Contact con = new Contact(AccountId=pCompany.Id);
        User parUser = new User(contactId=con.Id, ProfileId=admin.Id, Alias = 'parCon',Country='United Kingdom',Email='parCon@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='par', LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='parcom@monday.com');
        insert parUser;
        
        lead parLead=[select id from Lead where recordtypeid=:partnerLeadRecordTypeId];
        parLead.Partner_Company__c=pCompany.Id;
        parLead.OwnerId=parUser.Id;
        update parLead;

        Database.executeBatch(new Lead_Cap_CalcOpenLeads());


	}

    static testmethod void test_leadCapMonitoringController(){
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user=[select id from User where ProfileId =: admin.Id limit 1];
        user.should_get_leads_from_BigBrain__c=true;
        update user;

        Leads_Cap__c lc=LeadsCap_MonitorWidgetController.getLeadCapDetails(string.valueof(user.id));
    }
}
