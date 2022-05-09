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
        
        TestObjectCreator.persistImmediate=true;
        Account comp = TestObjectCreator.CreateCompany();
        
        Contract con = TestObjectCreator.CreateContract(comp);
        con.Primary_Renewal_Owner__c = userRecord.Id;
        con.EndDate = dueDate;
        con.Status__c = 'Active';
        update con;
        
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        ma.Active_Contract__c = con.Id;
        ma.ARR__c = 100;
        update ma;
        
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem qli = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        
        Contract_Product__c conProd = new Contract_Product__C (Contract__c = con.Id);
        insert conProd;

        Contract_Event__c conEvent = new Contract_Event__c(isrecurring__c = true, Contract__c = con.Id, Contract_Product__c = conProd.Id, Start_Date__c = System.today(), Quote_Line_Item__c = qli.Id);
        insert conEvent;

        List<Id> contractIdList = new List<Id>{con.Id};
        
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
