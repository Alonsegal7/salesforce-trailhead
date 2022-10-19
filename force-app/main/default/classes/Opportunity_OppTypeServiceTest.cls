@isTest
public without sharing class Opportunity_OppTypeServiceTest {
    
    @TestSetup
    static void makeData(){

        Profile adminProf = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile salesProf = [SELECT Id FROM Profile WHERE Name='monday Sales - AM'];
        
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@a.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = adminProf.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
        insert manager;

        User user1 = new User(Alias = 'user1',Country='Israel',Email='user1@a.com',EmailEncodingKey='UTF-8', LastName='user1', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = salesProf.Id,TimeZoneSidKey='America/Los_Angeles', UserName='user1@monday.com', ManagerId = manager.Id, Function__c = 'Enterprise AM', Group__c = 'Sales', Business_Role__c = 'AM', Segment__c = 'Enterprise', Seniority__c = 'Rep');        
        insert user1;

        Account compA = new Account(Name = 'compA - Enterprise', RecordTypeId = Utilities.companyRecordTypeId, OwnerId = user1.Id, NumberOfEmployees = 1600, BillingCountry = 'Israel', BillingCountryCode = 'IL', Region__c = 'EMEA', Website = 'compa.com', Account_Domains__c = '["compa.fr","compa.net"]');
        insert compA;

        Account mondayAccount1 = new Account(Name = 'mondayAccountA1', Pulse_Account_Id__c = '00011', ARR__c = 0, OwnerId = user1.Id, BillingCountry = 'Israel', BillingCountryCode = 'IL',ParentId = compA.Id, Company__c = compA.Id, RecordTypeId = Utilities.MARecordTypeId);
        insert mondayAccount1;

        Contract contract1= new Contract(Name='Contract Test',Seats__c=5,AccountId=compA.Id);
        insert contract1;

        Contract_Product__c conProd1 = new Contract_Product__c (Contract__c=contract1.Id);
        insert conProd1;

        Contract_Event__c conEvent1= new Contract_Event__c(Contract__c=contract1.id,Contract_Product__c=conProd1.Id,IsRecurring__c=true,Status__c='Valid',Calculate_ARR__c=true,ARR__c=100);
        insert conEvent1;

        Opportunity opp1 = new Opportunity(Name = 'opp1 - NB with cc', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),First_Subscription_Claimed_on_Opp__c=true);
        Opportunity opp2 = new Opportunity(Name = 'opp2 - NB No cc', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),Prior_ARR__c=0);
        Opportunity opp3 = new Opportunity(Name = 'opp3 - Downgrade', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),Expected_ARR__c=-1000);
        Opportunity opp4 = new Opportunity(Name = 'opp4 - Service', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),Type='Service');
        Opportunity opp5 = new Opportunity(Name = 'opp5 - Expansion', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),Prior_ARR__c=1000);
        Opportunity opp6 = new Opportunity(Name = 'opp6 - DG on Renewal', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),Selected_Company_Contract__c=contract1.Id,Total_Renewal_ARR__c=50);
        Opportunity opp7 = new Opportunity(Name = 'opp7 - Exp on Renewal', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),Selected_Company_Contract__c=contract1.Id,Total_Renewal_ARR__c=200);
        Opportunity opp8 = new Opportunity(Name = 'opp8 - Flat Renewal', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),Selected_Company_Contract__c=contract1.Id,Total_Renewal_ARR__c=100);
        insert new list<Opportunity>{opp1,opp2,opp3,opp4,opp5,opp6,opp7,opp8};
    }

    @isTest
    static void shouldSetNewBusinessCC() {
        Opportunity opp1=[select id from Opportunity where Name='opp1 - NB with cc'];
        update opp1;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp1.Id];
        System.assertEquals('New Business', opp.Opportunity_Type_V2__c);
    }
    @isTest
    static void shouldSetNewBusinessSO() {
        Opportunity opp2=[select id from Opportunity where Name='opp2 - NB No cc'];
        update opp2;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp2.Id];
        System.assertEquals('New Business', opp.Opportunity_Type_V2__c);
    }
    @isTest
    static void shouldSetDowngrade() {
        Opportunity opp3=[select id from Opportunity where Name='opp3 - Downgrade'];
        update opp3;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp3.Id];
        System.assertEquals('Downgrade', opp.Opportunity_Type_V2__c);
    }
    @isTest
    static void shouldSetService() {
        Opportunity opp4=[select id from Opportunity where Name='opp4 - Service'];
        update opp4;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp4.Id];
        System.assertEquals('Service', opp.Opportunity_Type_V2__c);
    }
    @isTest
    static void shouldSetExpansion() {
        Opportunity opp5=[select id from Opportunity where Name='opp5 - Expansion'];
        update opp5;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp5.Id];
        System.assertEquals('Expansion', opp.Opportunity_Type_V2__c);
    }
    @isTest
    static void shouldSetDGOnRenewal() {
        Opportunity opp6=[select id from Opportunity where Name='opp6 - DG on Renewal'];
        update opp6;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp6.Id];
        System.assertEquals('Downgrade on Renewal', opp.Opportunity_Type_V2__c);
    }
    @isTest
    static void shouldSetExpOnRenewal() {
        Opportunity opp7=[select id from Opportunity where Name='opp7 - Exp on Renewal'];
        update opp7;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp7.Id];
        System.assertEquals('Expansion on Renewal', opp.Opportunity_Type_V2__c);
    }
    @isTest
    static void shouldSetFlatRenewal() {
        Opportunity opp8=[select id from Opportunity where Name='opp8 - Flat Renewal'];
        opp8.Manual_Trigger__c='Calc Opp Type';
        update opp8;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp8.Id];
        System.assertEquals('Flat Renewal', opp.Opportunity_Type_V2__c);
    }
    @isTest
    static void shouldSetNBOnCreate() {
        Account compA = [select id from Account where name='compA - Enterprise'];
        Account mondayAccount1 = [select id from Account where Pulse_Account_Id__c='00011'];
        User user1 = [select id from User where email='user1@a.com'];
        Opportunity opp9 = new Opportunity(Name = 'opp9 - NB with cc Insert', AccountId = mondayAccount1.Id, Company__c = compA.Id, StageName = 'Validation', OwnerId = user1.Id, CurrencyIsoCode='USD', Billing_Ids__c='123401', Pricing_Version__c='8', Expected_Plan_Seats__c=60, Expected_Plan_Tier__c='Enterprise', Expected_Plan_Period__c='Yearly', Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)', CloseDate = System.today(),First_Subscription_Claimed_on_Opp__c=true);
        insert opp9;
        Opportunity opp=[select Id,Opportunity_Type_V2__c from Opportunity where Id=:opp9.Id];
        System.assertEquals('New Business', opp.Opportunity_Type_V2__c);
    }
}
