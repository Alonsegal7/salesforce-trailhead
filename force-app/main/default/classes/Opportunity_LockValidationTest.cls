@isTest
public without sharing class Opportunity_LockValidationTest {
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
        opp1.RecordTypeId = internalOppRT;
        opp1.StageName = 'Closed Won';
        opp1.Transition_to_GB__c = true;
        opp1.Claimed_ARR__c = 10000;
        update opp1;

        Opportunity opp2 = TestObjectCreator.CreateOpp(a);
        insert opp2;
        opp2.Expected_Plan_Seats__c = 40;
        opp2.Expected_Plan_Tier__c = 'Enterprise';
        opp2.Expected_Plan_Period__c = 'Yearly';
        opp2.RecordTypeId = partnerOppRT;
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

        opp1.Co_Sell_Request__c = csr.Id;
        opp1.Main_Co_Sell_Opportunity__c = true;
        opp1.Co_Sell_Opportunity__c = opp2.Id;
        opp2.Co_Sell_Request__c = csr.Id;
        opp1.CloseDate = Date.today().addDays(-90);
        opp2.CloseDate = Date.today().addDays(-90);
        opp2.Co_Sell_Opportunity__c = opp1.Id;
        List<Opportunity> opps = new List<Opportunity>{opp1,opp2};
        Opportunity_CoSellSyncService.updateOppSecCosellAllowed(opps);
    }

    static testmethod void testCoSellValidation(){
        Opportunity opp = [select Is_Locked__c, Unlock_Opportunity__c, CloseDate from Opportunity where Main_Co_Sell_Opportunity__c = false limit 1];
        System.assertEquals(true, opp.Is_Locked__c);
        System.assertEquals(false, opp.Unlock_Opportunity__c);
        opp.CloseDate = opp.CloseDate.addMonths(-1);
        try {
            update opp;
        } catch (Exception ex) {
            Boolean res = ex.getMessage().contains('Secondary Co Sell Opportunities can not be updated');
            system.assertEquals(true, res);
        }
    }
    static testmethod void testValidation(){
        Opportunity opp = [select Is_Locked__c, Unlock_Opportunity__c, CloseDate from Opportunity where Main_Co_Sell_Opportunity__c = true limit 1];
        System.assertEquals(true, opp.Is_Locked__c);
        System.assertEquals(false, opp.Unlock_Opportunity__c);
        opp.CloseDate = opp.CloseDate.addMonths(-1);
        try {
            update opp;
        } catch (Exception ex) {
            Boolean res = ex.getMessage().contains('This opp is closed and locked for editing');
            system.assertEquals(true, res);
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