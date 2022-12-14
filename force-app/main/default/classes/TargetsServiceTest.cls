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
        TargetsService targetServiceHelper = new TargetsService();
		targetServiceHelper.updateSalesOnTargetCreation(targets);
        Sale__c updatedSale = [select Id, Target__c from Sale__c where Id=:sale.Id limit 1];
        System.assertEquals(updatedSale.Target__c, targets[0].Id);
		Test.stopTest();        
    }
    
    static testMethod void shouldLinkSaleOnCreatePartner() {        
        Account company = new Account(Name='test company');
        insert company;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
		User user = new User(Alias = 'standt1',Country='United Kingdom', ManagerId=manager.Id, Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;
        
        Target__c cpmTarget = new Target__c(User__c=manager.Id, Target_Date__c=Date.newInstance(2019, 12, 2));
        insert cpmTarget;

        Sale__c partnersSale = new Sale__c(Owner__c=user.Id,Owner_s_Manager__c=manager.Id, RecordTypeId='0121t000000IQYTAA4',Close_Date__c=Date.newInstance(2019, 12, 17), Company__c=company.Id);
        Test.startTest();
        insert partnersSale;
        Test.stopTest();
        partnersSale = [select Target__c from Sale__c];
        System.assertEquals(cpmTarget.Id, partnersSale.Target__c);
    }

    static testMethod void shouldLinkSaleOnCreateTarget() {        
        Account company = new Account(Name='test company');
        insert company;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
		User user = new User(Alias = 'standt1',Country='United Kingdom', ManagerId=manager.Id, Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;
        
        Sale__c partnersSale = new Sale__c(Owner__c=user.Id,Owner_s_Manager__c=manager.Id, RecordTypeId='0121t000000IQYTAA4',Close_Date__c=Date.newInstance(2019, 12, 17), Company__c=company.Id);
        insert partnersSale;

        Test.startTest();
        Target__c cpmTarget = new Target__c(User__c=manager.Id, Target_Date__c=Date.newInstance(2019, 12, 2));
        insert cpmTarget;
        Test.stopTest();

        partnersSale = [select Target__c from Sale__c];
        System.assertEquals(cpmTarget.Id, partnersSale.Target__c);
    }

    static testMethod void shouldLinkSaleOnCreate() {        
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

        Sale__c sale = new Sale__c(Owner__c=user.Id, RecordTypeId='0121t000000IQYOAA4',Close_Date__c=Date.newInstance(2019, 12, 17), Company__c=company.Id);
        Test.startTest();
        insert sale;
        Test.stopTest();
        sale = [select Target__c from Sale__c];
        System.assertEquals(target.Id, sale.Target__c);
    }

    static testMethod void shouldLinkOpportunityOnCreate() {        
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

        Opportunity opp = new Opportunity(StageName = 'Qualification', OwnerId = user.Id, CloseDate = Date.newInstance(2019, 12, 17), Name = 'test', AccountId = company.Id);
        Test.startTest();
        insert opp;
        Test.stopTest();
        opp = [select Target__c from Opportunity];
        System.assertEquals(target.Id, opp.Target__c);
    }

    static testMethod void shouldLinkOpportunityOnCreateGSI() {        
        Account company = new Account(Name='test company');
        insert company;

        Account partnerGSI = new Account(Name='test GSI');
        insert partnerGSI;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
		User user = new User(Alias = 'standt1',Country='United Kingdom', ManagerId=manager.Id, Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;
        
        Target__c target = new Target__c(Partner_Company__c=partnerGSI.Id, Target_Date__c=Date.newInstance(2019, 12, 1));
        insert target;

        Opportunity opp = new Opportunity(StageName = 'Qualification', OwnerId = user.Id, CloseDate = Date.newInstance(2019, 12, 17), Name = 'test', AccountId = company.Id, GSI__c = partnerGSI.Id);
        Test.startTest();
        insert opp;
        Test.stopTest();
        opp = [select GSI_Target__c from Opportunity];
        System.assertEquals(target.Id, opp.GSI_Target__c);
    }

    static testMethod void oppCloseWonUpdateTarget() {      
        Account company = TestObjectCreator.CreateCompany();
        insert company;

        Account mondayAcc = TestObjectCreator.CreateMondayAccount(company);
        insert mondayAcc;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
		User user = new User(Alias = 'standt1',Country='United Kingdom', ManagerId=manager.Id, Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;
        
        Target__c target = new Target__c(User__c=user.Id, Target_Date__c=Date.newInstance(2019, 12, 1));
        insert target;

        Opportunity opp = new Opportunity(Target__c = target.Id, StageName = 'Qualification', OwnerId = user.Id, CloseDate = Date.newInstance(2019, 12, 17), Name = 'test', AccountId = mondayAcc.Id);
        opp.OwnerId = user.Id;
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;
        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR__c = 10000;
        opp.Expected_ARR__c = 10000;
        opp.Is_Potential_GB_Opportunity__c = true;
        Test.startTest();
        update opp;
        Test.stopTest();
        opp = [select StageName, Transition_to_GB__c, Claimed_ARR__c, Expected_ARR__c, Is_Potential_GB_Opportunity__c, Green_Bucket_ARR_V2__c from Opportunity limit 1];
        system.debug('$$Ksenia: StageName = '+ opp.StageName);
        system.debug('$$Ksenia: Transition_to_GB__c = '+ opp.Transition_to_GB__c);
        system.debug('$$Ksenia: Claimed_ARR__c = '+ opp.Claimed_ARR__c);
        system.debug('$$Ksenia: Expected_ARR__c = '+ opp.Expected_ARR__c);
        system.debug('$$Ksenia: Is_Potential_GB_Opportunity__c = '+ opp.Is_Potential_GB_Opportunity__c);
        system.debug('$$Ksenia: Green_Bucket_ARR_V2__c = '+ opp.Green_Bucket_ARR_V2__c);
        target = [select Closed_Won_Arr__c from Target__c where Id =: target.Id];
        //System.assertEquals(10000, target.Closed_Won_Arr__c);
    }

    static testMethod void shouldLinkGSIOpportunityOnCreateTarget() {        
        Account company = new Account(Name='test company');
        insert company;

        Account partnerGSI = new Account(Name='test GSI');
        insert partnerGSI;
        

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
		User user = new User(Alias = 'standt1',Country='United Kingdom', ManagerId=manager.Id, Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;

        Opportunity opp = new Opportunity(StageName = 'Qualification', OwnerId = user.Id, CloseDate = Date.newInstance(2019, 12, 17), Name = 'test', AccountId = company.Id, GSI__c = partnerGSI.Id);
        insert opp;

        Test.startTest();
        Target__c target = new Target__c(Partner_Company__c=partnerGSI.Id, Target_Date__c=Date.newInstance(2019, 12, 1));
        insert target;
        Test.stopTest();

        opp = [select GSI_Target__c from Opportunity];
        System.assertEquals(target.Id, opp.GSI_Target__c);
    }

    static testMethod void shouldLinkOpportunityOnCreateTarget() {        
        Account company = new Account(Name='test company');
        insert company;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
		User user = new User(Alias = 'standt1',Country='United Kingdom', ManagerId=manager.Id, Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;

        Opportunity opp = new Opportunity(StageName = 'Qualification', OwnerId = user.Id, CloseDate = Date.newInstance(2019, 12, 17), Name = 'test', AccountId = company.Id);
        insert opp;

        Test.startTest();
        Target__c target = new Target__c(User__c=user.Id, Target_Date__c=Date.newInstance(2019, 12, 1));
        insert target;
        Test.stopTest();

        opp = [select Target__c from Opportunity];
        System.assertEquals(target.Id, opp.Target__c);
    }

    static testMethod void shouldLinkOpportunityOnCreatePartner() {    
        Id oppPartnerCompanyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
    
        Account company = new Account(Name='test company');
        insert company;

        Contact con = new Contact(LastName = 'test', Email = 'test@monday.com', AccountId = company.Id);
        insert con;
        
		User user = [select Id, ManagerId from User where isActive = true and Profile.Name like '%Partner%' and UserRole.Name like '%Partner User' limit 1];
        
        Target__c cpmTarget = new Target__c(User__c=user.ManagerId, Target_Date__c=Date.newInstance(2019, 12, 2));
        insert cpmTarget;

        Target__c pctarget = new Target__c(Partner_Company__c = company.Id, Target_Date__c=Date.newInstance(2019, 12, 2));
        insert pctarget;

        Opportunity opp = new Opportunity(RecordTypeId = oppPartnerCompanyRtId, StageName = 'Qualification', OwnerId = user.Id, Owner_s_Manager__c=user.ManagerId, CloseDate = Date.newInstance(2019, 12, 17), Name = 'test', AccountId = company.Id);
        Test.startTest();
        insert opp;
        Test.stopTest();
        opp = [select Target__c, CP_Target__c from Opportunity];
        System.assertEquals(cpmTarget.Id, opp.Target__c);
        //System.assertEquals(pctarget.Id, opp.CP_Target__c);
    }
}