@isTest
public class OnTaskUpdateTriggerTest {
    static testMethod void updateOpportunityWithLastTask() {
        Test.startTest();
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id mondayAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id, TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;

		User user = new User(Alias='standt1', ManagerId=manager.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;

        Account company = new Account(Name='companyA', RecordTypeId=companyRecordTypeId, OwnerId=user.Id, CSM__c=user.Id, Company_Id__c='1');
		insert company;
        
        Account mondayAccount = new Account(Name='monday account', RecordTypeId=mondayAccountRecordTypeId, Company__c=company.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='12');
		insert mondayAccount;

		Opportunity opp = new Opportunity(primary_pulse_account_id__c='123', Expected_Plan_Name__c='dudu', Name='test opp', StageName='Qualified', CloseDate=System.today(), pulse_account_ids__c=null, AccountId=mondayAccount.Id);
		insert opp;
        
        Task task = new Task(Subject='kuku', WhatId=opp.Id, ActivityDate=System.TODAY(), Status='Open');
		insert task;        
        
        opp = [select Id, Next_activity_date__c, Next_activity__c from Opportunity where Id=:opp.Id];
		System.assertEquals(System.TODAY(), opp.Next_activity_date__c);
        System.assertEquals('kuku', opp.Next_activity__c);
        Test.stopTest();
    }
    
    static testMethod void updateLeadWithLastTask() {
        Test.startTest();
		Lead lead = new Lead(LastName='moshe', Company='monday', time_zone_offset__c=-4);
		insert lead;
        
        Task task = new Task(Subject='dudo', WhoId=lead.Id, ActivityDate=System.TODAY(), Status='Open');
		insert task;        
        
        lead = [select Id, Next_activity_date__c, Next_activity__c from Lead where Id=:lead.Id];
		System.assertEquals(System.TODAY(), lead.Next_activity_date__c);
        System.assertEquals('dudo', lead.Next_activity__c);
        Test.stopTest();
    }
    

}