@istest
public with sharing class SalesOrderErrorHandlingService_Test {

    @TestSetup
    static void makeData(){
        TestObjectCreator.persistImmediate=true;
        DateTime dT = System.now();
        Date startDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDate = date.newinstance(dT.year()+1, dT.month(), dT.day());
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        ma.primary_pulse_account_id__c='12211';
        update ma;

        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        quoteLicenseLine.Duration__c=12;
        quoteLicenseLine.ServiceDate=startDate;
        quoteLicenseLine.End_Date__c=endDate;
        quoteLicenseLine.Duration__c=12;
        quoteLicenseLine.Tier__c='Pro';
        quoteLicenseLine.List_Price__c=38;
        quoteLicenseLine.Net_Per_Unit__c=263;
        quoteLicenseLine.arr__c=123;
        update quoteLicenseLine;

        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };


    }

    @istest
    public static void TestConflicts(){

        quote q = [select id from quote limit 1];
        SalesOrderErrorHandlingService.CallBigBrainPreview(q.id,'3434');
        List<Order_Activation_Conflict__c> confs = [select id from Order_Activation_Conflict__c];
 
        quote q1 = [select id,BigBrain_Preview_API_Status__c,Error_Description__c from quote limit 1];

        system.assertEquals(4, confs.size());
        system.assertEquals('Invalid', q1.BigBrain_Preview_API_Status__c);
        system.assertEquals(null, q1.Error_Description__c);
    }
}