@isTest
public with sharing class CoSellRequestServiceTest {
    @TestSetup
    static void makeData(){
        Id partnerOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        Id internalOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();

        Account a = TestObjectCreator.CreateAccount();
        insert a;
        Opportunity opp1 = TestObjectCreator.CreateOpp(a);
        insert opp1;
        opp1.Expected_Plan_Seats__c = 40;
        opp1.Expected_Plan_Tier__c = 'Enterprise';
        opp1.Expected_Plan_Period__c = 'Yearly';
        opp1.RecordTypeId = partnerOppRT;
        opp1.StageName = 'Closed Won';
        opp1.Transition_to_GB__c = true;
        opp1.Claimed_ARR__c = 10000;
        update opp1;

        Opportunity opp2 = TestObjectCreator.CreateOpp(a);
        insert opp2;
        opp2.Expected_Plan_Seats__c = 40;
        opp2.Expected_Plan_Tier__c = 'Enterprise';
        opp2.Expected_Plan_Period__c = 'Yearly';
        opp2.RecordTypeId = internalOppRT;
        opp2.StageName = 'Closed Won';
        opp2.Transition_to_GB__c = true;
        opp2.Claimed_ARR__c = 10000;
        update opp2;
        
        Co_Sell_Request__c csr = new Co_Sell_Request__c(
            Main_Opportunity__c = opp1.Id,
            Secondary_Opportunity__c = opp2.Id,
            Type__c = 'Associate',
            Monday_Account__c = a.Id
        );
        insert csr;
    }

    static testmethod void test1(){
        Co_Sell_Request__c csr = [select Id from Co_Sell_Request__c limit 1];
        csr.Status__c = 'Approved';
        update csr;
    }
}