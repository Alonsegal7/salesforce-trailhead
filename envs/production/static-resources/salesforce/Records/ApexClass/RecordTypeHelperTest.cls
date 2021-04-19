@isTest
public class RecordTypeHelperTest {
	static testMethod void shouldReturnMondayAccount() {
        Test.startTest();
        
        Id mondayAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Account mondayAccount = new Account(Name='monday account', RecordTypeId=mondayAccountRecordTypeId);
		insert mondayAccount;
        System.assertEquals(RecordTypeHelper.devName(mondayAccount.recordTypeID), 'Monday_Account');
        
		Test.stopTest();        
    }
    
    static testMethod void shouldReturnCompany() {
        Test.startTest();
        
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
		Account company = new Account(Name='company', RecordTypeId=companyRecordTypeId);
		insert company;
        System.assertEquals(RecordTypeHelper.devName(company.recordTypeID), 'Company');

		Test.stopTest();  
    }
    
    static testMethod void shouldNull() {
        Test.startTest();
        System.assertEquals(RecordTypeHelper.devName(null), null);
		Test.stopTest();  
    }
}