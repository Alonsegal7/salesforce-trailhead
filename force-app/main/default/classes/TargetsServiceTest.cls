@isTest
public class TargetsServiceTest {
	static testMethod void shouldLinkSalesToTarget() {
        Test.startTest();
        
        Account company = new Account(Name='test company');
        insert company;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
        User user = new User(Alias = 'standt1',Country='United Kingdom', ManagerId=manager.Id, Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing1234@monday.com');
		insert user;

        Sale__c sale = new Sale__c(Owner__c=user.Id, Close_Date__c=Date.newInstance(2019, 12, 17), Company__c=company.Id);
        insert sale;
        Target__c[] targets = new Target__c[]{new Target__c(User__c=user.Id, Target_Date__c=Date.newInstance(2019, 12, 1))};

		TargetsService.updateSalesOnTargetCreation(targets);
        Sale__c updatedSale = [select Id, Target__c from Sale__c where Id=:sale.Id limit 1];
        System.assertEquals(updatedSale.Target__c, targets[0].Id);
		Test.stopTest();        
    }
    
    static testMethod void shouldLinkSaleOnCreate() {
        Test.startTest();
        
        Account company = new Account(Name='test company');
        insert company;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
		User user = new User(Alias = 'standt1',Country='United Kingdom', ManagerId=manager.Id, Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;
        
        Target__c target = new Target__c(User__c=user.Id, Target_Date__c=Date.newInstance(2019, 12, 1));
        insert target;
        
        Target__c cpmTarget = new Target__c(User__c=manager.Id, Target_Date__c=Date.newInstance(2019, 12, 2));
        insert cpmTarget;

        Sale__c sale = new Sale__c(Owner__c=user.Id, RecordTypeId='0121t000000IQYOAA4',Close_Date__c=Date.newInstance(2019, 12, 17), Company__c=company.Id);
        Sale__c partnersSale = new Sale__c(Owner__c=user.Id,Owner_s_Manager__c=manager.Id, RecordTypeId='0121t000000IQYTAA4',Close_Date__c=Date.newInstance(2019, 12, 17), Company__c=company.Id);

      	
        TargetsService.updateSaleTarget(sale);
        System.assertEquals(sale.Target__c, target.Id);
        TargetsService.updateSaleTarget(partnersSale);
        System.assertEquals(partnersSale.Target__c, cpmTarget.Id);
		Test.stopTest();        
    }
}