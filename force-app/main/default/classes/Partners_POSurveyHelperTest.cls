@isTest
public without sharing class Partners_POSurveyHelperTest {

    public static Id partnerOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
    public static Id internalOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();

    @TestSetup
    static void makeData(){
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

    }
    static testmethod void test1(){
        Opportunity opp1 = [select Id, AccountId, Name from Opportunity where Expected_Plan_Seats__c = 40 limit 1];
        Partners_POSurveyHelper.baseQuery();
        Partners_POSurveyHelper helper = new Partners_POSurveyHelper(new List<Opportunity>{opp1}, false);
        Set<Id> res = new Set<Id>();
        helper.checkSurveyConditions(res);
    }

    static testmethod void test2(){
        Opportunity opp1 = [select Id, AccountId, Name from Opportunity where Expected_Plan_Seats__c = 40 limit 1];
        Account a = [select Id from Account limit 1];
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
        Partners_POSurveyHelper.baseQuery();
        Partners_POSurveyHelper helper = new Partners_POSurveyHelper(new List<Opportunity>{opp1}, false);
        Set<Id> res = new Set<Id>();
        helper.checkSurveyConditions(res);
    }

    static testmethod void test3(){
        Opportunity opp1 = [select Id, AccountId, Name from Opportunity where Expected_Plan_Seats__c = 40 limit 1];
        Account a = [select Id from Account limit 1];
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

        Opportunity opp3 = TestObjectCreator.CreateOpp(a);
        insert opp3;
        opp3.Expected_Plan_Seats__c = 10;
        opp3.Expected_Plan_Tier__c = 'Enterprise';
        opp3.Expected_Plan_Period__c = 'Yearly';
        opp3.RecordTypeId = partnerOppRT;
        opp3.StageName = 'Closed Won';
        opp3.Transition_to_GB__c = true;
        opp3.Claimed_ARR__c = 10000;
        update opp3;
        opp3.CloseDate = Date.today().addMonths(-1);
        update opp3;
        Partners_POSurveyHelper.baseQuery();
        Partners_POSurveyHelper helper = new Partners_POSurveyHelper(new List<Opportunity>{opp1}, false);
        Set<Id> res = new Set<Id>();
        helper.checkSurveyConditions(res);
    }
}