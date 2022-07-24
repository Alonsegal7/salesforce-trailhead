@isTest 
public without sharing class BigBrain_CalloutServiceTest {
    @TestSetup
    static void makeData(){
        Account comp = TestObjectCreator.CreateCompany();
        insert comp;
        Account mondayAcc = TestObjectCreator.CreateMondayAccount(comp);
        insert mondayAcc;

        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;
    }

    static testmethod void testNeedToBeSynced_insert(){
        Opportunity opp = [select Need_Sync_to_BB__c from Opportunity limit 1];
        System.assertEquals(true, opp.Need_Sync_to_BB__c);
        Test.startTest();
        BigBrain_CalloutService sch = new BigBrain_CalloutService();
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, sch);
        Test.stopTest();
    }

    static testmethod void testNeedToBeSynced_update(){
        Opportunity opp = [select Id from Opportunity limit 1];
        opp.Need_Sync_to_BB__c = false;
        update opp;
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR_Override__c = 10000;
        update opp;
        opp = [select Need_Sync_to_BB__c from Opportunity limit 1];
        System.assertEquals(true, opp.Need_Sync_to_BB__c);
        Test.startTest();
        BigBrain_CalloutService sch = new BigBrain_CalloutService();
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, sch);
        Test.stopTest();
    }

    static testmethod void testManualSync(){
        List<Opportunity> opp_list = [select Id from Opportunity limit 1];
        opp_list.get(0).Manual_Trigger__c = 'Sync to BB';
        Test.startTest();
        BigBrain_CalloutService.manualSync(opp_list);
        Test.stopTest();
    }
}