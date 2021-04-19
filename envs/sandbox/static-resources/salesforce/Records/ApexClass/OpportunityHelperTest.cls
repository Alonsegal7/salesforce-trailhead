@isTest
public class OpportunityHelperTest {
	static testMethod void shouldUpdateCompanyOnAccountChange() {
        Test.startTest();
        
        // Arrange
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id mondayAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;

		User user = new User(Alias='standt1', ManagerId=manager.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;

        Account companyA = new Account(Name='companyA', RecordTypeId=companyRecordTypeId, OwnerId=user.Id, CSM__c=user.Id);
		insert companyA;
        
        Account companyB = new Account(Name='companyB', RecordTypeId=companyRecordTypeId, OwnerId=user.Id, CSM__c=user.Id);
		insert companyB;
        
        Sale__c sale = new Sale__c(Company__c=companyA.Id, Close_Date__c=Date.newInstance(2019, 12, 1));
        insert sale;

        Opportunity opp = new Opportunity(Name='opportunity', StageName='Qualified', Expected_Plan_Name__c='1', CloseDate=system.today(), Company__c=companyA.Id, AccountId=companyA.Id, Sale__c=sale.Id);
        insert opp;
        
        // Act
        opp.AccountId = companyB.Id;
        update opp;
        
        // Assert
        opp = [SELECT Id, Company__c, Monday_Account__c FROM Opportunity WHERE Id =: opp.Id LIMIT 1];
        System.assertEquals(opp.Company__c, companyB.Id);
        System.assertEquals(opp.Monday_Account__c, null);
        
		Test.stopTest();        
    }
    
    static testMethod void shouldUpdateMondayAccountOnAccountChange() {
        Test.startTest();
        
        // Arrange
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id mondayAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
		
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;

		User user = new User(Alias='standt1', ManagerId=manager.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;

        Account companyA = new Account(Name='companyA', RecordTypeId=companyRecordTypeId, OwnerId=user.Id, CSM__c=user.Id, Company_Id__c='1');
		insert companyA;
        
        Account companyB = new Account(Name='companyB', RecordTypeId=companyRecordTypeId, OwnerId=user.Id, CSM__c=user.Id, Company_Id__c='2');
		insert companyB;
        
        Account mondayAccount = new Account(Name='monday account', RecordTypeId=mondayAccountRecordTypeId, Company__c=companyB.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='12');
		insert mondayAccount;

        Account mondayAccount2 = new Account(Name='monday account 2', RecordTypeId=mondayAccountRecordTypeId, Company__c=companyB.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='34');
		insert mondayAccount2;

        Sale__c sale = new Sale__c(Company__c=companyA.Id, Close_Date__c=system.today());
        insert sale;
        
        Opportunity opp = new Opportunity(Name='opportunity', StageName='Qualified', Expected_Plan_Name__c='1', CloseDate=system.today(), Company__c=companyA.Id, AccountId=mondayAccount.Id, Sale__c=sale.Id);
        insert opp;
        
        // Act
        opp.AccountId = mondayAccount2.Id;
        update opp;
        
        // Assert
        opp = [SELECT Id, Company__c, Monday_Account__c FROM Opportunity WHERE Id =: opp.Id LIMIT 1];
        System.assertEquals(opp.Company__c, companyB.Id);
        System.assertEquals(opp.Monday_Account__c, mondayAccount2.Id);
        
        Database.executeBatch(new Opportunity_Snapshot());
        Database.executeBatch(new Sale_Snapshots());

		Test.stopTest();        
    }
}