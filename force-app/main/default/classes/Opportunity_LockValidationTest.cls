@isTest
public without sharing class Opportunity_LockValidationTest {
    @TestSetup
    static void makeData(){
        Account comp = TestObjectCreator.CreateCompany();
        insert comp;
        Account mondayAcc = TestObjectCreator.CreateMondayAccount(comp);
        insert mondayAcc;

        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR__c = 10000;
        opp.Unlock_Opportunity__c = true;
        update opp;

        opp.CloseDate = Date.today().addDays(-90);
        update opp;
    }

    static testmethod void testValidation(){
        Opportunity opp = [select Is_Locked__c, Unlock_Opportunity__c, CloseDate from Opportunity limit 1];
        System.assertEquals(true, opp.Is_Locked__c);
        System.assertEquals(false, opp.Unlock_Opportunity__c);
        opp.CloseDate = opp.CloseDate.addMonths(-1);
        try {
            update opp;
        } catch (Exception ex) {
            system.assertEquals('This opp is closed and locked for editing.', ex.getMessage());
        }
    }

    static testmethod void testUnlock(){
        Opportunity opp = [select Is_Locked__c, Unlock_Opportunity__c, CloseDate from Opportunity limit 1];
        System.assertEquals(true, opp.Is_Locked__c);
        System.assertEquals(false, opp.Unlock_Opportunity__c);
        opp.CloseDate = opp.CloseDate.addMonths(-1);
        opp.Unlock_Opportunity__c = true;
        update opp;
    }
}
