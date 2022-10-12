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
        insert conProd;
        Billing_Entity__c BE = TestObjectCreator.CreateBE();
        Contract_Event__c conEvent = new Contract_Event__c(isrecurring__c = true, Contract__c = con.Id, Contract_Product__c = conProd.Id, Start_Date__c = System.today(), Quote_Line_Item__c = qli.Id,Billing_Entity__c=BE.id,ARR__c=100,Status__c='Valid'); 
        insert conEvent;    
        opportunity.StageName = 'Closed Won';
        update opportunity; 
        // Apex_Services_Status__mdt renewalShouldRunCMT = [SELECT Id, Label, Status__c FROM Apex_Services_Status__mdt WHERE Label = 'RenewalAutomaticCreation'][0];
        // renewalShouldRunCMT.Status__c = 'Active';
        // update renewalShouldRunCMT;
        system.debug('CMT '+ renewalShouldRunCMT);  
        Test.startTest();
        Batch_CreateRenewalOpportunities batch = new Batch_CreateRenewalOpportunities(dueDate);
        Database.executeBatch(batch, 20);
        Test.stopTest();
        con = [SELECT Id, Renewal_Opportunity_Creation_Status__c FROM Contract WHERE Id =: con.Id];
        Opportunity newOpp = [SELECT Id, Type, CloseDate FROM Opportunity WHERE Selected_Company_Contract__c =: con.Id];
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