@isTest
public with sharing class Handover_ThresholdMappingTest {
    @TestSetup
    static void makeData(){

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = TestUtils.getUserWithoutRole(profileId);
        user.Office__c = 'Tel Aviv Office';
        insert user;

        Account mondayAcc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId(), Name = 'testMOnday', primary_pulse_account_id__c = '12345');
        insert mondayAcc;

        Account comp = TestObjectCreator.CreateCompany();
        comp.NumberOfEmployees = 1501;
        comp.Name = 'test1';
        comp.OwnerId = user.Id;
        insert comp;

        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.Company__c = comp.Id;
        opp.Name = 'test1';
        opp.CSM_Package__c = 'Gold';
        opp.CSM_Name_New__c = 'No Dedicated CSM';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        insert opp;

        TestObjectCreator.persistImmediate = true;
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opp, 'New Contract');
        QuoteLineItem quoteLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'Onboarding', 10, 1.0);
        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opp, quoteLine) };
        TestObjectCreator.persistImmediate = false;

        OpportunityLineItem oli = [SELECT Id, PS_Hours__c FROM OpportunityLineItem WHERE Product_Type__c = 'Onboarding' LIMIT 1];
        oli.PS_Hours__c = 10;
        oli.Is_Primary__c = true;
        update oli;

        List<HO_Threshold__c> thresholds = new List<HO_Threshold__c>();
        thresholds.add(new HO_Threshold__c(Name = 'AM test1', Type__c = 'AM'));
        thresholds.add(new HO_Threshold__c(Name = 'CSM test1', Type__c = 'CSM', Always_Pass__c = true));
        thresholds.add(new HO_Threshold__c(Name = 'OB test1', Type__c = 'Onboarding'));
        insert thresholds;

        List<HO_Threshold_Criteria__c> thCrs = new List<HO_Threshold_Criteria__c>();
        //AM criterias
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[0].Id, Criteria_Name__c = 'Min Company Size', Target_Field_API_Name__c = 'Company_Employees__c', Operator__c = 'greaterthen',Value__c = '500', Relevant_for_Link__c = true, Is_Active__c = true));
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[0].Id, Criteria_Name__c = 'Max Company Size', Target_Field_API_Name__c = 'Company_Employees__c', Operator__c = 'lessthen',Value__c = '1500', Relevant_for_Link__c = true, Is_Active__c = true));
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[0].Id, Criteria_Name__c = 'Owners Region', Target_Field_API_Name__c = 'Owner_s_Office_Region__c', Operator__c = 'notequal',Value__c = 'US', Relevant_for_Link__c = true, Is_Active__c = true));
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[0].Id, Criteria_Name__c = 'Requires GB?', Target_Field_API_Name__c = 'Is_Potential_GB_Opportunity__c', Operator__c = 'equal',Value__c = 'FALSE', Relevant_for_Link__c = true, Is_Active__c = true));
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[0].Id, Criteria_Name__c = 'Seats', Target_Field_API_Name__c = 'Expected_Plan_Seats__c', Operator__c = 'greaterthen',Value__c = '100', Relevant_for_Pass__c = true, Is_Active__c = true));
        //CSM criterias
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[1].Id, Criteria_Name__c = 'CSM Package', Target_Field_API_Name__c = 'CSM_Package__c', Operator__c = 'one of',Value__c = 'Bronze;Silver', Relevant_for_Link__c = true, Is_Active__c = true));
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[1].Id, Criteria_Name__c = 'Account CSM', Target_Field_API_Name__c = 'CSM_Name_New__c', Operator__c = 'equal',Value__c = 'No Dedicated CSM', Relevant_for_Link__c = true, Is_Active__c = true));
        //OB criterias
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[2].Id, Criteria_Name__c = 'Onboarding Hours', Target_Field_API_Name__c = 'Onboarding_Hours__c', Operator__c = 'greaterthen',Value__c = '0', Relevant_for_Link__c = true, Is_Active__c = true));
        thCrs.add(new HO_Threshold_Criteria__c(HO_Threshold__c = thresholds[2].Id, Criteria_Name__c = 'Account CSM', Target_Field_API_Name__c = 'CSM_Name_New__c', Operator__c = 'equal',Value__c = 'No Dedicated CSM', Relevant_for_Pass__c = true, Is_Active__c = true));
        insert thCrs;
    }

    @isTest
    static void shouldLinkThresholdToExistingOpp() { 
        
        Opportunity opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        Account comp = [SELECT Id, NumberOfEmployees FROM Account WHERE Name = 'test1' LIMIT 1];
        HO_Threshold__c amTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'AM' LIMIT 1];
        HO_Threshold__c csmTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'CSM' LIMIT 1];
        HO_Threshold__c onboardingTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'Onboarding' LIMIT 1];
        
        System.assertEquals(opp.HO_Threshold_AM__c, null);
        System.assertEquals(opp.HO_Threshold_CSM__c, null);
        System.assertEquals(opp.HO_Threshold_Onboarding__c, null);
        
        Test.startTest();
        
        comp.NumberOfEmployees = 1480;
        update comp;
        opp.CSM_Package__c = 'Silver';
        update opp;
        opp.StageName = 'Buying process';
        update opp;
        
		Test.stopTest();
        
        opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        System.assertEquals(opp.HO_Threshold_AM__c, amTh.Id);
        System.assertEquals(opp.HO_Threshold_CSM__c, csmTh.Id);
        System.assertEquals(opp.HO_Threshold_Onboarding__c, onboardingTh.Id);
    }

    @isTest
    static void shouldNotLinkThresholdToExistingOpp() { 

        Opportunity opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem WHERE Product_Type__c = 'Onboarding'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Product_Type__c = 'Onboarding'];
        
        Test.startTest();
        
        delete qli;
        delete oli;
        opp.StageName = 'Buying process';
        update opp;
        
		Test.stopTest();
        
        opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        System.assertEquals(opp.HO_Threshold_AM__c, null);
        System.assertEquals(opp.HO_Threshold_CSM__c, null);
        System.assertEquals(opp.HO_Threshold_Onboarding__c, null);
    }

    @isTest
    static void shouldRemoveLinkedThresholdToExistingOpp() { 
        
        Opportunity opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        Account comp = [SELECT Id, NumberOfEmployees FROM Account WHERE Name = 'test1' LIMIT 1];
        HO_Threshold__c amTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'AM' LIMIT 1];
        HO_Threshold__c csmTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'CSM' LIMIT 1];
        HO_Threshold__c onboardingTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'Onboarding' LIMIT 1];
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem WHERE Product_Type__c = 'Onboarding'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Product_Type__c = 'Onboarding'];

        System.assertEquals(opp.HO_Threshold_AM__c, null);
        System.assertEquals(opp.HO_Threshold_CSM__c, null);
        System.assertEquals(opp.HO_Threshold_Onboarding__c, null);

        comp.NumberOfEmployees = 1480;
        update comp;
        opp.CSM_Package__c = 'Silver';
        update opp;
        opp.StageName = 'Buying process';
        update opp;

        opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        System.assertEquals(opp.HO_Threshold_AM__c, amTh.Id);
        System.assertEquals(opp.HO_Threshold_CSM__c, csmTh.Id);
        System.assertEquals(opp.HO_Threshold_Onboarding__c, onboardingTh.Id);
        
        Test.startTest();
        
        comp.NumberOfEmployees = 1550;
        update comp;
        delete qli;
        delete oli;
        opp.CSM_Package__c = 'Gold';
        opp.StageName = 'Evaluation';
        update opp;
        
		Test.stopTest();
        
        opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        System.assertEquals(opp.HO_Threshold_AM__c, null);
        System.assertEquals(opp.HO_Threshold_CSM__c, null);
        System.assertEquals(opp.HO_Threshold_Onboarding__c, null);
        
    }

    @isTest
    static void updateThCr() {

        HO_Threshold_Criteria__c thCr = [SELECT Id, Value__c FROM HO_Threshold_Criteria__c WHERE Value__c = '500' LIMIT 1];
        thCr.Value__c = '800';
        update thCr;
    }

    @isTest
    static void shouldPassThreshold() { 

        Opportunity opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        Account comp = [SELECT Id, NumberOfEmployees FROM Account WHERE Name = 'test1' LIMIT 1];
        HO_Threshold__c amTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'AM' LIMIT 1];
        HO_Threshold__c csmTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'CSM' LIMIT 1];
        HO_Threshold__c onboardingTh = [SELECT Id FROM HO_Threshold__c WHERE Type__c = 'Onboarding' LIMIT 1];
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem WHERE Product_Type__c = 'Onboarding'];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Product_Type__c = 'Onboarding'];

        System.assertEquals(opp.HO_Threshold_AM__c, null);
        System.assertEquals(opp.HO_Threshold_CSM__c, null);
        System.assertEquals(opp.HO_Threshold_Onboarding__c, null);
        
        comp.NumberOfEmployees = 1480;
        update comp;
        opp.CSM_Package__c = 'Silver';
        update opp;
        opp.StageName = 'Buying process';
        update opp;
        
        opp = [SELECT Id, StageName, HO_Threshold_AM__c, HO_Threshold_CSM__c, HO_Threshold_Onboarding__c FROM Opportunity WHERE Name = 'test1' LIMIT 1];
        
        Test.startTest();
        
        Boolean hasPassedAM = Handover_ThresholdMapping.checkIfOppPassedThreshold(opp.Id, 'AM');
        Boolean hasPassedCSM = Handover_ThresholdMapping.checkIfOppPassedThreshold(opp.Id, 'CSM');
        Boolean hasPassedOB = Handover_ThresholdMapping.checkIfOppPassedThreshold(opp.Id, 'Onboarding');
        
        Test.stopTest();

        System.assertEquals(hasPassedAM, false);
        System.assertEquals(hasPassedCSM, true);
        System.assertEquals(hasPassedOB, true);
    }

}