@isTest
public with sharing class Target_ScheduledAlertOppsWoTargetTest {
    @TestSetup
    static void makeData(){
        Target__c myTarget = new Target__c();
        myTarget.User__c = UserInfo.getUserId();
        myTarget.Amount__c = 70000;
        myTarget.Target_Date__c = Date.today().toStartOfMonth();
        insert myTarget;
        Account comp = TestObjectCreator.CreateCompany();
        insert comp;
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        insert ma;
        Opportunity opp = TestObjectCreator.CreateOpp(ma);
        insert opp;
    }
    static testmethod void testRunScriptSanity(){
        Test.setMock(HttpCalloutMock.class, new Slack_MessageServiceTest.mockCallout());
        Test.startTest();
        Target_ScheduledAlertOppsWoTarget myClass = new Target_ScheduledAlertOppsWoTarget();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }

    static testmethod void testOppsWoTarget(){
        Opportunity opp = [select Id, Target__c from Opportunity limit 1];
        Target__c target = new Target__c(
            Id = opp.Target__c
        );
        delete target;
        Test.setMock(HttpCalloutMock.class, new Slack_MessageServiceTest.mockCallout());
        Test.startTest();
        Target_ScheduledAlertOppsWoTarget myClass = new Target_ScheduledAlertOppsWoTarget();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }
}