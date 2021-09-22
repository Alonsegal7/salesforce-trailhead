@isTest
public with sharing class Team_ComponentWidgetTest {
    public static testmethod void createTeam() {
        Id mondayAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Id companyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();

        Account companyAcc = new Account();
        companyAcc.RecordTypeId = companyAccRecordTypeId;
        companyAcc.Name = 'Test Company';
        insert companyAcc;

        Account mondayAcc = new Account();
        mondayAcc.RecordTypeId = mondayAccRecordTypeId;
        mondayAcc.Name = 'Test MA';
        mondayAcc.Company__c = companyAcc.Id;
        insert mondayAcc;

        Contact con = new Contact();
		con.LastName = 'Contact Test';
		con.FirstName = 'Team';
		con.Email = 'test@testteam.com';
		con.AccountId = mondayAcc.Id;
		con.Company__c = companyAcc.Id;
		insert con;

        Team__c teamRec = new Team__c();
        teamRec.Monday_Account__c = mondayAcc.Id;
        teamRec.Name = 'Team Test';
        teamRec.Department__c = 'Accounting, Tax & Finance';
        teamRec.Contact__c = con.Id;
        insert teamRec;

        Team_ComponentWidget.getTeams(mondayAcc.Id);
    }
}
