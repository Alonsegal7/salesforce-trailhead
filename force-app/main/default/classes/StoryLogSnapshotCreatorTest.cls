@isTest
public class StoryLogSnapshotCreatorTest {

    /*@testSetup
    static void setup() {
        StoryLogSetting__c logSetting = new StoryLogSetting__c(TargetObjectName__c = 'Opportunity', IsActive__c = true, RemoveSnapshotsOnParentDelete__c = true);
        insert logSetting;
        
        StoryLogItemSetting__c logItemSetting = new StoryLogItemSetting__c(StoryLogSetting__c = logSetting.Id, IsActive__c = true,
                                                                           FieldSetName__c = 'Next_Strategy', GroupLogs__c = true,
                                                                           RecordTypeId = Schema.SObjectType.StoryLogItemSetting__c.getRecordTypeInfosByDeveloperName().get('FieldUpdate').getRecordTypeId()),
            				   logItemSetting2 = new StoryLogItemSetting__c(StoryLogSetting__c = logSetting.Id, IsActive__c = true,
                                                                            ForeignKey__c = 'WhatId', RelatedObjectName__c = 'Task',
                                                                            TrackInsert__c = true, TrackDelete__c = true, TrackUndelete__c = true,
                                                                            RecordTypeId = Schema.SObjectType.StoryLogItemSetting__c.getRecordTypeInfosByDeveloperName().get('RelatedObject').getRecordTypeId());
        insert new StoryLogItemSetting__c[]{logItemSetting, logItemSetting2};
        
        Account testAcc = new Account(Name = 'Test Acc');
        insert testAcc;
        
        List<Opportunity> oppList = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            Opportunity testOpp = new Opportunity(Name = 'Test Opp ' + i, StageName = 'Open', CloseDate = Date.today().addDays(5), AccountId = testAcc.Id,
                                                  NextStep = 'Test Step ' + i);
            oppList.add(testOpp);
        }
        insert oppList;
    }
    
    @isTest
    static void relatedObjectInsertTest() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        System.debug('HERE');
        Task testTask = new Task(WhatId = oppList[0].Id);
        insert testTask;
    }
    
    @isTest
    static void afterUpdateTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.NextStep = 'Next step';
        update testOpp;
        
        //System.assertEquals(true, [SELECT Id FROM StoryLogSnapshot__c WHERE ParentRecordId__c = :testOpp.Id].size() > 0);
    }
    
    @isTest
    static void deleteTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Task testTask = new Task(WhatId = testOpp.Id);
        insert testTask;        
        delete testTask;
        
        List<StoryLogSnapshot__c> snapsToCheck = [SELECT Id, ShortDescription__c, RecordId__c, ParentRecordId__c FROM StoryLogSnapshot__c WHERE RecordId__c = :testTask.Id];
        System.debug(snapsToCheck);
        /*System.assertEquals(1, snapsToCheck.size());
        System.assertEquals(testTask.Id, snapsToCheck[0].RecordId__c);
        System.assertEquals(Label.RecordIsCreated, snapsToCheck[0].ShortDescription__c);
        System.assertEquals(testOpp.Id, snapsToCheck[0].ParentRecordId__c);*/
    /*}
    
    @isTest
    static void undeleteTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Task testTask = new Task(WhatId = testOpp.Id);
        insert testTask;        
        delete testTask;        
        undelete testTask;
        
        List<StoryLogSnapshot__c> snapsToCheck = [SELECT Id, ShortDescription__c, RecordId__c, ParentRecordId__c
                                                  FROM StoryLogSnapshot__c 
                                                  WHERE Type__c = :Constants.STORY_LOG_TYPE_RELATED_OBJECT];
        System.debug(snapsToCheck);
        /*System.assertEquals(testTask.Id, snapsToCheck[0].RecordId__c);*/
    //}
}