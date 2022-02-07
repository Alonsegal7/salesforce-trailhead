@isTest
public class BatchPartnersSendPostOnBoardingSurveyTst {
    @TestSetup
    static void makeData(){
        Account mondayAcc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId(), Name = 'testMOnday', primary_pulse_account_id__c = '12345', Account_Source_Type__c = 'Inbound', Sign_Up_Date__c = Date.today());
        insert mondayAcc;

        Contact con = new Contact(AccountId = mondayAcc.Id, Email = 'test@monday.com', LastName = 'test');
        insert con;

        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR__c = 10000;
        update opp;

        opp.CloseDate = Date.today().addDays(-90);
        opp.Expected_Plan_Period__c = 'Yearly';
        opp.Expected_Plan_Tier__c = 'Enterprise';
        opp.Expected_Plan_Seats__c = 20;
        update opp;
    }

    static testmethod void testNewBusiness(){
        Test.startTest();
        Database.executeBatch(new Batch_PartnersSendPostOnBoardingSurvey());
        Test.stopTest();

        Opportunity opp = [select Id from Opportunity limit 1];
        Contact con = [select Id, Of_Post_Onboarding_Surveys__c, Last_Opportunity_For_Survey__c from Contact limit 1];
        System.assertEquals(1, con.Of_Post_Onboarding_Surveys__c);
        System.assertEquals(String.valueOf(opp.Id), con.Last_Opportunity_For_Survey__c);
    }

    static testmethod void testNewBusiness_dryRun(){
        Date dateForTest = Date.today().addDays(-90);
        Test.startTest();
        Database.executeBatch(new Batch_PartnersSendPostOnBoardingSurvey(true, dateForTest));
        Test.stopTest();
    }

    static testmethod void testExpansionProToEnt(){
        Account mondayAcc = [select Id from Account limit 1];
        Opportunity lastopp = [select Id from Opportunity limit 1];
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR__c = 10000;
        update opp;

        opp.CloseDate = Date.today().addDays(-91);
        opp.Expected_Plan_Period__c = 'Yearly';
        opp.Expected_Plan_Tier__c = 'Pro';
        opp.Expected_Plan_Seats__c = 15;
        update opp;

        Test.startTest();
        Database.executeBatch(new Batch_PartnersSendPostOnBoardingSurvey());
        Test.stopTest();

        
        Contact con = [select Id, Of_Post_Onboarding_Surveys__c, Last_Opportunity_For_Survey__c from Contact limit 1];
        System.assertEquals(1, con.Of_Post_Onboarding_Surveys__c);
        System.assertEquals(String.valueOf(lastopp.Id), con.Last_Opportunity_For_Survey__c);
    }

    static testmethod void testExpansionProToEnt_dryRun(){
        Account mondayAcc = [select Id from Account limit 1];
        Opportunity lastopp = [select Id from Opportunity limit 1];
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR__c = 10000;
        update opp;

        opp.CloseDate = Date.today().addDays(-91);
        opp.Expected_Plan_Period__c = 'Yearly';
        opp.Expected_Plan_Tier__c = 'Pro';
        opp.Expected_Plan_Seats__c = 15;
        update opp;

        Test.startTest();
        Database.executeBatch(new Batch_PartnersSendPostOnBoardingSurvey(true, Date.today().addDays(-90)));
        Test.stopTest();
    }

    static testmethod void testExpansionEntToEnt(){
        Account mondayAcc = [select Id from Account limit 1];
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR__c = 10000;
        update opp;

        opp.CloseDate = Date.today().addDays(-91);
        opp.Expected_Plan_Period__c = 'Yearly';
        opp.Expected_Plan_Tier__c = 'Enterprise';
        opp.Expected_Plan_Seats__c = 15;
        update opp;

        Test.startTest();
        Database.executeBatch(new Batch_PartnersSendPostOnBoardingSurvey());
        Test.stopTest();

        Contact con = [select Id, Of_Post_Onboarding_Surveys__c, Last_Opportunity_For_Survey__c from Contact limit 1];
        System.assertEquals(0, con.Of_Post_Onboarding_Surveys__c);
        System.assertEquals(null, con.Last_Opportunity_For_Survey__c);
    }

    static testmethod void testExpansionEntToEnt_dryRun(){
        Account mondayAcc = [select Id from Account limit 1];
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR__c = 10000;
        update opp;

        opp.CloseDate = Date.today().addDays(-91);
        opp.Expected_Plan_Period__c = 'Yearly';
        opp.Expected_Plan_Tier__c = 'Enterprise';
        opp.Expected_Plan_Seats__c = 15;
        update opp;

        Test.startTest();
        Database.executeBatch(new Batch_PartnersSendPostOnBoardingSurvey(true, Date.today().addDays(-90)));
        Test.stopTest();
    }

    static testmethod void testDateInput(){
        Date dateForTest = Date.today().addDays(-90);
        Test.startTest();
        Database.executeBatch(new Batch_PartnersSendPostOnBoardingSurvey(dateForTest));
        Test.stopTest();
    }

    static testmethod void testScheduler(){
        String cronExpr = '0 0 0 15 3 ? 2022';
        String jobRunningTime = '2022-03-15 00:00:00';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('myJobTestJobName', cronExpr, new Batch_PartnersSendPostOnBoardingSurvey());
        Test.stopTest();
    }
}