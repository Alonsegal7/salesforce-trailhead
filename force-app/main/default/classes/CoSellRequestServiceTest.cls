@isTest
public with sharing class CoSellRequestServiceTest {
    @TestSetup
    static void makeData(){
        List<Co_sell_Request_to_Main_Opp_Mapping__mdt> testMap = CoSellRequestService.requestToMainOppMapping_cmt;
        Id partnerOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        Id internalOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        user u = [select id from user where isActive = true and group__c = 'Sales' and Profile.Name = 'monday Sales - AE' limit 1];
        Account a = TestObjectCreator.CreateAccount();
        a.Co_Sell_Leader__c = 'Sales';
        insert a;

        List<Opportunity> oppsList = new List<Opportunity>();
        Opportunity opp1 = TestObjectCreator.CreateOpp(a);
        Opportunity opp2 = TestObjectCreator.CreateOpp(a);
        Opportunity opp3 = TestObjectCreator.CreateOpp(a);
        insert new List<Opportunity>{opp1,opp2,opp3};

        opp1.Expected_Plan_Seats__c = 40;
        opp1.Expected_Plan_Tier__c = 'Enterprise';
        opp1.Expected_Plan_Period__c = 'Yearly';
        opp1.RecordTypeId = partnerOppRT;
        opp1.StageName = 'Closed Won';
        opp1.Transition_to_GB__c = true;
        opp1.Claimed_ARR__c = 10000;
        opp2.Expected_Plan_Seats__c = 40;
        opp2.Expected_Plan_Tier__c = 'Enterprise';
        opp2.Expected_Plan_Period__c = 'Yearly';
        opp2.RecordTypeId = internalOppRT;
        opp2.OwnerId = u.id;
        opp2.StageName = 'Closed Won';
        opp2.Transition_to_GB__c = true;
        opp2.Claimed_ARR__c = 10000;
        opp3.Expected_Plan_Seats__c = 40;
        opp3.Expected_Plan_Tier__c = 'Enterprise';
        opp3.Expected_Plan_Period__c = 'Yearly';
        opp3.RecordTypeId = internalOppRT;
        opp3.StageName = 'Closed Won';
        opp3.Transition_to_GB__c = true;
        opp3.Claimed_ARR__c = 10000;
        opp3.OwnerId = u.id;
        update new List<Opportunity>{opp1,opp2,opp3};

        Co_Sell_Request__c csr = new Co_Sell_Request__c(
            Main_Opportunity__c = opp1.Id,
            Secondary_Opportunity__c = opp2.Id,
            Type__c = 'Associate',
            Monday_Account__c = a.Id
        );
        Co_Sell_Request__c csr2 = new Co_Sell_Request__c(
            Main_Opportunity__c = opp3.Id,
            Secondary_Opportunity_Owner__c = u.Id,
            Type__c = 'Create',
            Monday_Account__c = a.Id
        );
        CoSellRequestService.createNewCoSellRequest(csr);
        CoSellRequestService.createNewCoSellRequest(csr2);
    }

    static testmethod void test_manualCreateError(){
        User cp = [select Id from User where Profile.Name = 'Channel Managers' and IsActive = true limit 1];
        Opportunity opp = [select Id, AccountId from Opportunity limit 1];
        Co_Sell_Request__c csr = new Co_Sell_Request__c(
            Main_Opportunity__c = opp.Id,
            Secondary_Opportunity_Owner__c = UserInfo.getUserId(),
            Type__c = 'Create',
            Monday_Account__c = opp.AccountId
        );
        system.runAs(cp){
            try{
                insert csr;
            } catch (Exception e){

            }
        }
    }

    static testmethod void test1(){
        list<Co_Sell_Request__c> csrList = [select Id, Main_Opportunity__c, Type__c from Co_Sell_Request__c];
        Id oppToUpdate;
        for(Co_Sell_Request__c csr: csrList){
            csr.Status__c = 'Approved';
            if(csr.Type__c == 'Associate') oppToUpdate = csr.Main_Opportunity__c;
        }
        update csrList;
        Opportunity opp1 = new Opportunity(
            Id = oppToUpdate,
            Expected_Plan_Seats__c = 30
        );
        update opp1;
        test.startTest();
        Opportunity_CoSellSyncService b = new Opportunity_CoSellSyncService();
        Database.executeBatch(b);
        test.stopTest();
    }

    static testmethod void test_Opportunity_CoSellSyncService(){
        test.startTest();
        Opportunity_CoSellSyncService b = new Opportunity_CoSellSyncService();
        String sch = '0 0 8 13 2 ?';
        system.schedule('One Time Pro', sch, b);
        test.stopTest();
    }

    static testmethod void test3(){
        Id accId = [select Id from Account limit 1].Id;
        CoSellRequestService.getAssociatePotentialOpps(accId, 'Internal_Opportunity');
    }

    static testmethod void test_CoSellRequest_SurveyReminderSch(){
        Co_Sell_Request__c csr = [select Id, Main_Opportunity__c from Co_Sell_Request__c limit 1];
        csr.Status__c = 'Approved';
        update csr;
        test.startTest();
        CoSellRequest_SurveyReminderSch b = new CoSellRequest_SurveyReminderSch();
        String sch = '0 0 8 13 2 ?';
        system.schedule('One Time Pro', sch, b);
        test.stopTest();
    }
}