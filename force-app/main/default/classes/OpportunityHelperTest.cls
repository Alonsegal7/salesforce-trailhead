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
        
        Account mondayAccount = new Account(Name='monday account', RecordTypeId=mondayAccountRecordTypeId, Company__c=companyA.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='12');
        insert mondayAccount;
        
        Sale__c sale = new Sale__c(Company__c=companyA.Id, Close_Date__c=Date.newInstance(2019, 12, 1),Monday_Account__c=mondayAccount.Id);
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

        list<Account> Comps= new list<Account>();
        Account companyA = new Account(Name='companyA', RecordTypeId=companyRecordTypeId, OwnerId=user.Id, CSM__c=user.Id, Company_Id__c='1');
        Comps.add(companyA);
        Account companyB = new Account(Name='companyB', RecordTypeId=companyRecordTypeId, OwnerId=user.Id, CSM__c=user.Id, Company_Id__c='2');
        Comps.add(companyB);
        insert Comps;

        list<Account> Accs= new list<Account>();
        Account mondayAccount = new Account(Name='monday account', RecordTypeId=mondayAccountRecordTypeId, Company__c=companyB.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='12');
        Account mondayAccount2 = new Account(Name='monday account 2', RecordTypeId=mondayAccountRecordTypeId, Company__c=companyB.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='34');
        Accs.add(mondayAccount);
        Accs.add(mondayAccount2);
        insert Accs;

        Sale__c sale = new Sale__c(Company__c=companyA.Id, Close_Date__c=system.today(),Monday_Account__c=mondayAccount.Id);
        insert sale;
        
        Opportunity opp = new Opportunity(Name='opportunity', OwnerId=user.Id, Owner_s_Manager__c=manager.Id,StageName='Qualified', Expected_Plan_Name__c='1', CloseDate=system.today(), Company__c=companyA.Id, AccountId=mondayAccount.Id, Sale__c=sale.Id);
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
    static testMethod void shouldUpdateChannelPartner() {
        Id partnerOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        Test.startTest();
		Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        Account mondayAccount = TestObjectCreator.CreateMondayAccount(company);
        mondayAccount.primary_pulse_account_id__c='12345';
        insert mondayAccount;
        GB_Threshold__c gbtPar= TestObjectCreator.CreateGBThreshold('Partner_Opportunity');
        insert gbtPar;
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAccount);
        opp.RecordTypeId=partnerOppRecordTypeId;
        opp.Type='New Business';
        insert opp;
        Contact con = new Contact(AccountId=company.Id);
        User user1 = new User(contactId=con.Id, ProfileId=admin.Id, Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
        insert user1;

        opp.OwnerId=user1.Id;
        opp.Potential_GB_Opp_Override__c='Yes';
        opp.Green_Bucket_Override_Reason__c = 'Test Reason';
        update opp;

		Test.stopTest();        
    }

    static testMethod void shouldCopyOlisToCoSell() {
        Test.startTest();
		Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        Account mondayAccount = TestObjectCreator.CreateMondayAccount(company);
        mondayAccount.primary_pulse_account_id__c='12345';
        insert mondayAccount;

        Product2 prod = TestObjectCreator.CreateProductWithCode('MON-V6-PRO');
        insert prod;
        Product2 prodFree = TestObjectCreator.CreateProductWithCode('MON-V6-PRO-F');
        insert prodFree;
        Pricebook2 pb = TestObjectCreator.CreatePricebook();
        insert pb;
        PricebookEntry pbe1 = TestObjectCreator.CreatePricebookEntry(prod,1);
        insert pbe1;
        PricebookEntry pbe2 = TestObjectCreator.CreatePricebookEntry(prodFree,1);
        insert pbe2;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.id,
                                                    Product2Id = prod.Id,
                                                    UnitPrice = 1,
                                                    UseStandardPrice = false,
                                                    IsActive = true,CurrencyIsoCode='USD');
        insert pbe;

        Opportunity opp1 = TestObjectCreator.CreateOpp(mondayAccount);
        opp1.Billing_Ids__c='111';
        opp1.Pricebook2Id=pb.Id;
        Opportunity opp2 = TestObjectCreator.CreateOpp(mondayAccount);
        opp2.Co_Sell_Opportunity__c=opp1.Id;
        insert new list<Opportunity> {opp1,opp2};
        

        OpportunityLineItem oli= new OpportunityLineItem(OpportunityId=opp1.id,pricebookentryId=pbe.Id,Product2Id=prod.Id, Is_Primary__c=true,Quantity=1,TotalPrice=100);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=opp1.id,pricebookentryId=pbe.Id,Product2Id=prod.Id, Is_Primary__c=true,Quantity=1,TotalPrice=100,CC_Claim_Product__c=true);
        list<OpportunityLineItem> olis= new list<OpportunityLineItem>{oli,oli2};
        insert olis;

        delete oli2;

        opp1.StageName = 'Closed Won';
        opp1.Co_Sell_Opportunity__c=opp2.Id;
        opp1.Main_Co_Sell_Opportunity__c=true;
        //update opp1;

		Test.stopTest();        
    }

    static testMethod void exchangeRateDailyRun() {
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

        Account mondayAccount = new Account(Name='monday account', RecordTypeId=mondayAccountRecordTypeId, Company__c=companyA.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='12');
        insert mondayAccount;

        Sale__c sale = new Sale__c(Company__c=companyA.Id, Close_Date__c=system.today(),Monday_Account__c=mondayAccount.Id);
        insert sale;
        
        Opportunity opp = new Opportunity(Name='opportunity',CurrencyIsoCode='GBP' ,OwnerId=user.Id, Owner_s_Manager__c=manager.Id,StageName='Qualified', Expected_Plan_Name__c='1', CloseDate=system.today(), Company__c=companyA.Id, AccountId=mondayAccount.Id, Sale__c=sale.Id);
        list<Opportunity> opps= new list<Opportunity>{opp};
        Opportunity opp2 = new Opportunity(Name='opportunity',CurrencyIsoCode='EUR' ,OwnerId=user.Id, Owner_s_Manager__c=manager.Id,StageName='Qualified', Expected_Plan_Name__c='1', CloseDate=system.today(), Company__c=companyA.Id, AccountId=mondayAccount.Id, Sale__c=sale.Id);
        opps.add(opp2);
        insert opps;

        ExchangeRate__c er= new ExchangeRate__c(Date__c=date.today(),Currency__c='GBP',Rate__c=1.3);
        insert er;
        
        Database.executeBatch(new Exchange_Rate_Daily_Update());

		Test.stopTest();        
    }

    static testMethod void updateOppType() {

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
       
        
        Account mondayAccount = new Account(Name='monday account', RecordTypeId=mondayAccountRecordTypeId, Company__c=companyA.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='12');
        insert mondayAccount;
        

        Opportunity opp = new Opportunity(Name='opportunity', StageName='Qualified', Expected_Plan_Name__c='1', CloseDate=system.today(), Company__c=companyA.Id, AccountId=mondayAccount.Id);
        insert opp;
        opp = [SELECT Id, Is_Account_Green_Bucket_New__c FROM Opportunity WHERE Id =: opp.Id LIMIT 1];
        System.assertEquals(opp.Is_Account_Green_Bucket_New__c, false);
        
            
        opp.Is_Account_Green_Bucket_New__c = true;
        update opp;
        opp = [SELECT Id, Is_Account_Green_Bucket_New__c FROM Opportunity WHERE Id =: opp.Id LIMIT 1];
        System.assertEquals(opp.Is_Account_Green_Bucket_New__c, true);

                        
    }

    @isTest
    static void shoulDetermineServiceType() {
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
        Account mondayAccount = new Account(Name='monday account', RecordTypeId=mondayAccountRecordTypeId, Company__c=companyA.Id, OwnerId=user.Id, CSM__c=user.Id, primary_pulse_account_id__c='12');
        insert mondayAccount;
        Opportunity opp = new Opportunity(Name='opportunity', StageName='Qualified', Expected_Plan_Name__c='1', CloseDate=system.today(), Company__c=companyA.Id, AccountId=companyA.Id);
        insert opp;
        // Update tyoe for opp 
        opp.Opportunity_Type__c ='Service';
        update opp;
        List<opportunity> oppList = new List<opportunity>();
        oppList.add(opp);
        OpportunityHelper.determineOppType(oppList);            
    }
}