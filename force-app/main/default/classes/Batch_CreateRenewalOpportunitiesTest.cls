@isTest
public without sharing class Batch_CreateRenewalOpportunitiesTest {
    
    public static Profile profileId;
    public static User userRecord;

    @isTest
    public static void shouldRunBatch() {
        
        date dueDate = System.today().addMonths(Batch_CreateRenewalOpportunities.getMonthToAdd());

        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;
        
        Account comp = TestObjectCreator.CreateCompany();
        insert comp;
        
        Contract con = TestObjectCreator.CreateContract(comp);
        con.Primary_Renewal_Owner__c = userRecord.Id;
        con.EndDate = dueDate;
        con.Status__c = 'Active';
        insert con;
        
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        ma.Active_Contract__c = con.Id;
        ma.ARR__c = 100;
        insert ma;

        con.Main_Monday_Account_Related__c= ma.Id;
        update con;

        TestObjectCreator.persistImmediate=true;
        Opportunity opportunity= TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem qli = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);  
        Contract_Product__c conProd = new Contract_Product__C (Contract__c = con.Id);
        Billing_Entity__c BE = TestObjectCreator.CreateBE();
        Contract_Event__c conEvent = new Contract_Event__c(isrecurring__c = true, Contract__c = con.Id, Contract_Product__c = conProd.Id, Start_Date__c = System.today(), Quote_Line_Item__c = qli.Id,Billing_Entity__c=BE.id);     
        opportunity.StageName = 'Closed Won';
        update opportunity;
        ma= [SELECT Id,of_open_opps__c,Active_Contract__c FROM Account WHERE ARR__c = 100 LIMIT 1];
        system.debug('NoaM Con'+ con);
        system.debug('NoaM Con event'+ conEvent.Billing_Entity__c);
        system.debug('NoaM Con event'+ conEvent);
        system.debug('NoaM Con st'+ con.Status__c);
        system.debug('NoaM Con end date'+ con.EndDate);
        system.debug('NoaM con pro'+ con.Primary_Renewal_Owner__c);
        system.debug('NoaM ma'+ ma);
        system.debug('NoaM ma of open opps'+ ma.Active_Contract__c);
        system.debug('NoaM Con'+ ma.of_open_opps__c);
        contract quary = [SELECT Id,
        (SELECT Id, Billing_Entity__c FROM Contract_Events__r ORDER BY CreatedDate DESC LIMIT 1)
        FROM Contract WHERE Id =:con.Id];
        system.debug('NoaM quary'+quary.Contract_Events__r[0]);
        
        Test.startTest();
        Batch_CreateRenewalOpportunities batch = new Batch_CreateRenewalOpportunities(dueDate);
        Database.executeBatch(batch, 20);
        Test.stopTest();

        Opportunity newOpp = [SELECT Id, Type, CloseDate FROM Opportunity WHERE Selected_Company_Contract__c =: con.Id];
        con = [SELECT Id, Renewal_Opportunity_Creation_Status__c FROM Contract WHERE Id =: con.Id];
        System.assertNotEquals(newOpp.Id, null);
        System.assertEquals(newOpp.Type, 'Flat Renewal');
        System.assertEquals(newOpp.CloseDate, dueDate);
        System.assertEquals(con.Renewal_Opportunity_Creation_Status__c, 'Completed');
    }
    
    @isTest
    public static void shouldRunSchedule() {
        String sch = '0 0 0 * * ?';
        Test.startTest();
        String jobId = System.schedule('myJobTestJobName', sch, new Batch_CreateRenewalOpportunities());
        Test.stopTest();
        System.assertNotEquals(jobId, null);
    }
}