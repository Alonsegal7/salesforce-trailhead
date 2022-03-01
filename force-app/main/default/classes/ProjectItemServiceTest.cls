@isTest
public with sharing class ProjectItemServiceTest {
    @TestSetup
    static void makeData(){
        TestObjectCreator.persistImmediate = true;
        DateTime dT = System.now();
        Date startDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDate = date.newinstance(dT.year()+1, dT.month(), dT.day());
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);

        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'Onboarding', 10, 1.0);

        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLine) };
        System.debug(opportunityLines);
        Handover__c hnd = new Handover__c (
        Company__c=company.Id,
        Involve_CSM__c='Yes',
        Opportunity__c=opportunity.Id
        );

        insert hnd;

        Profile p = [SELECT Id FROM Profile WHERE Name='monday Sales - AE'];
        User manager2 = [select Id from User where IsActive = true and Profile.Name='monday Sales - AE' limit 1];
		User user = new User(Alias='standt1', IsActive = true ,ManagerId=manager2.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;
    }
    @isTest
    static void UpdateOboardingOwner(){
        Handover__c hnd = [select id,Opportunity__c, Onboarding_Owner__c,AM_Manager_Email__c from Handover__c limit 1];
        User usr = [select id from user where Alias='standt1' limit 1];
        hnd.Onboarding_Owner__c=usr.Id;
        hnd.AM_Manager_Email__c='bla@bla.com';
        update hnd;
        Product2 prod = [select id from Product2 limit 1];

        Project__c proj = [select id , Total_Onboarding_Hours_Free__c, Total_Onboarding_Hours_Paid__c from project__c limit 1];
        Project_Item__c pitm = [select Id, Project_Item_Type__c,Product__c from Project_Item__c where project__c=:proj.Id];
        System.assertEquals(proj.Id, proj.Id);
        System.assertEquals(0, proj.Total_Onboarding_Hours_Free__c);
        System.assertEquals(10, proj.Total_Onboarding_Hours_Paid__c);
        System.assertEquals(prod.Id, pitm.Product__c);
        System.assertEquals('Onboarding- Paid', pitm.Project_Item_Type__c);
    }
}