@isTest
public class MondayAccountHelperTest {
    @isTest
	static void shouldUpdateCompanyField() {
        Test.startTest();
        TestObjectCreator.persistImmediate = true;
        
        Account companyA = TestObjectCreator.CreateCompany();
        Account companyB = TestObjectCreator.CreateCompany();
        Account mondayAccount = TestObjectCreator.CreateMondayAccount(companyA);
        
        Sale__c sale = new Sale__c(Company__c=companyA.Id, Monday_Account__c=mondayAccount.Id, Close_Date__c=Date.newInstance(2019, 12, 1));
        insert sale;
        
        Contact contact = new Contact(Company__c=companyA.Id, Email='kuku@dudo.com', LastName='kuku', Monday_Account__c=mondayAccount.Id);
        insert contact;
        
        Opportunity opp = new Opportunity(Company__c=companyA.Id, Name='opp123', StageName='Qualified', CloseDate=system.today(), Expected_Plan_Name__c='100 users', Monday_Account__c=mondayAccount.Id, AccountId=mondayAccount.Id);
        insert opp;
        
        mondayAccount.Company__c = companyB.Id;
        update mondayAccount;
        
        sale = [select Id, Company__c from Sale__c where Id=:sale.Id limit 1];
        System.assertEquals(companyB.Id, sale.Company__c);
        
        contact = [select Id, Company__c from Contact where Id=:contact.Id limit 1];
        System.assertEquals(companyB.Id, contact.Company__c);
        
        opp = [select Id, Company__c from Opportunity where Id=:opp.Id LIMIT 1];
        System.assertEquals(companyB.Id, opp.Company__c);
        
        TestObjectCreator.persistImmediate = true;
		Test.stopTest();        
    }
}