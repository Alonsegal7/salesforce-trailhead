/* *
* Test class for validating the methods from CloneOpportunityController class
* */

@isTest
class CloneOpportunityControllerTest {
    @testSetup
    static void createTestData() {
       
    }
    
    @isTest
    static void getOpportunityLineItems_test() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;

		User csm = new User(Alias='standt1', ManagerId=manager.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert csm;


        Account company = new Account(Name='Company', OwnerId=csm.Id, Company_Id__c='dudu.com',RecordTypeId='0121t000000IQTiAAO');
        insert company;


        Account mondayAccount = new Account(Name='Monday Account', CSM__c=csm.Id, ParentId=company.Id, OwnerId=csm.Id, primary_pulse_account_id__c='1234');
        insert mondayAccount;

        Sale__c sale = new Sale__c(Company__c=company.Id, Monday_Account__c=mondayAccount.Id, Close_Date__c=Date.newInstance(2019, 12, 1));
        insert sale;
		
        
        Opportunity opp = new Opportunity(Name='Kuku', Expected_Plan_Name__c='dudu', StageName='Qualified', CloseDate=system.today(), AccountId=mondayAccount.Id, Sale__c=sale.Id);
        insert opp;
        
        CloneOpportunityController.cloneOpportunityWithContent(opp, opp.Id);
        Test.stopTest();
    }
}