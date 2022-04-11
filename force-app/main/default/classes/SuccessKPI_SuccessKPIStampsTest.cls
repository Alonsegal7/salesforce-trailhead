@isTest
public with sharing class SuccessKPI_SuccessKPIStampsTest {
    @TestSetup
    static void makeData(){
        Account accountRecord = TestObjectCreator.CreateAccount();
        insert accountRecord;
        accountRecord.Health_Score__c = 10;
        accountRecord.MAPP__c=5;
        update accountRecord; 
        Success_KPI__c SK1 = new Success_KPI__c(
            Name='Test 1 -Success KPI',
            Department__c='CS',
            monday_Account__c= accountRecord.Id
        );
        insert SK1;
        Success_KPI__c SK2 = new Success_KPI__c(
            Name='Test 2 -Success KPI',
            Department__c='Partners',
            monday_Account__c= accountRecord.Id
        );
        insert SK2;
    } 
    static testMethod void TestHealthScoreMappStamps() {
        Account acc= [select Id,Health_Score__c,MAPP__c from Account where Health_Score__c = 10 limit 1];
        Success_KPI__c SK =[select Id,name,Health_Score_End__c,monday_Account__c,MAPP_End__c from Success_KPI__c where name='Test 1 -Success KPI'];
        SK.Target_End_Date__c=Date.today().addDays(-1);
        update SK;
        Test.startTest();
        Batch_UpdateSuccessKPIsStamps batch = new Batch_UpdateSuccessKPIsStamps();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        SK=[select Health_Score_End__c,MAPP_End__c from Success_KPI__c limit 1];
        system.assertEquals(acc.Health_Score__c, SK.Health_Score_End__c);
        system.assertEquals(acc.MAPP__c, SK.MAPP_End__c);
    }
    static testMethod void TestNotToStampHealthScoreMapp() {
        Account acc= [select Id,Health_Score__c,MAPP__c from Account where Health_Score__c = 10 limit 1];
        Success_KPI__c SK =[select Id,name,Health_Score_End__c,monday_Account__c,MAPP_End__c from Success_KPI__c where name='Test 2 -Success KPI'];
        SK.Target_End_Date__c=Date.today().addDays(-1);
        update SK;
        Test.startTest();
        Batch_UpdateSuccessKPIsStamps batch = new Batch_UpdateSuccessKPIsStamps();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        SK=[select Health_Score_End__c,MAPP_End__c from Success_KPI__c where name='Test 2 -Success KPI'];
        system.assertEquals(null, SK.Health_Score_End__c);
        system.assertEquals(null, SK.MAPP_End__c);
    }

    static testMethod void testSchedule() {
        Test.startTest();
        Batch_UpdateSuccessKPIsStamps p = new Batch_UpdateSuccessKPIsStamps();
        String sch = '0 35 11 * * ?';
        System.schedule('TestHealthScoreMappStamps', sch, p);
        Test.stopTest();
    }
}