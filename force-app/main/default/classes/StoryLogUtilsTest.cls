@isTest
public class StoryLogUtilsTest {/*
    @testSetup
    static void setup(){
        StoryLogSetting__c logSetting = new StoryLogSetting__c(TargetObjectName__c = 'Opportunity', IsActive__c = true);
        insert logSetting;
        
        StoryLogItemSetting__c logItemSetting = new StoryLogItemSetting__c(StoryLogSetting__c = logSetting.Id, IsActive__c = true, FieldSetName__c = 'Next_Strategy', 
                                                                           RecordTypeId = Schema.SObjectType.StoryLogItemSetting__c.getRecordTypeInfosByDeveloperName().get('FieldUpdate').getRecordTypeId()),
            				   logItemSetting2 = new StoryLogItemSetting__c(StoryLogSetting__c = logSetting.Id, IsActive__c = true, RelatedObjectName__c = 'Task',
                                                                            ForeignKey__c = 'WhatId', TrackInsert__c = true, TrackDelete__c = true, TrackUndelete__c = true,
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
    static void obtainSourceTypesTest() {
        System.assertEquals(false, StoryLogUtils.obtainSourceTypes(Opportunity.sObjectType).isEmpty());
    }
    
    @isTest
    static void obtainStoryLogSettingsTest() {
        List<StoryLogItemSetting__c> logItemSettingList = [SELECT Id FROM StoryLogItemSetting__c];
        
        StoryLogUtils.StoryLogSetting slSetting = StoryLogUtils.obtainStoryLogSettings(Opportunity.sObjectType);
        
        System.debug(slSetting.fieldsToCheck);
        System.assertEquals(2, slSetting.storyLogItemSettingMap.values().size());
        for (StoryLogItemSetting__c logItemSetting_i : logItemSettingList) {
            System.assertEquals(true, slSetting.storyLogItemSettingMap.containsKey(logItemSetting_i.Id));
        }
        System.assertEquals(Opportunity.NextStep.getDescribe().getName(), slSetting.fieldsToCheck.values()[0][0].getDescribe().getName());
    }
    
    @isTest
    static void obtainStoryLogSnapshotsTest() {
        List<Opportunity> oppList = [SELECT NextStep FROM Opportunity],
            			  oldOppList = oppList.deepClone(true);
        StoryLogUtils.StoryLogSetting storyLogSetting = StoryLogUtils.obtainStoryLogSettings(Opportunity.SObjectType);
        
        oppList[1].NextStep = 'Closed Won';
        oppList[2].NextStep = 'Closed Lost';            
        
        Map<Id, List<StoryLogSnapshot__c>> newSnapshotsList = StoryLogUtils.obtainStoryLogSnapshots(storyLogSetting.storyLogItemSettingMap,
                                                                                            storyLogSetting.fieldsToCheck,
                                                                                            oppList,
                                                                                            new Map<Id, Opportunity>(oldOppList));
        for (Opportunity opp_i : oppList) {
            System.assertEquals(opp_i.Id == oppList[0].Id ? 0 : 1, newSnapshotsList.get(opp_i.Id).size());
        }
	
    }
    
    @isTest
    static void generateFieldUpdateSnapshotTest() {
        StoryLogItemSetting__c logItemSetting = [SELECT Id FROM StoryLogItemSetting__c WHERE FieldSetName__c = 'Next_Strategy'];
        StoryLogSnapshot__c snapToCheck = StoryLogUtils.generateFieldUpdateSnapshot(Opportunity.fields.Name, null, logItemSetting.Id, 'Old Name', 'New Name');
        System.assertEquals('<i>Name</i> changed from <b>Old Name</b> to <b>New Name</b>', snapToCheck.ShortDescription__c);
        System.assertEquals('Old Name', snapToCheck.OldValue__c);
        System.assertEquals('New Name', snapToCheck.NewValue__c);
        System.assertEquals('Name', snapToCheck.FieldLabel__c);
    }
    
    @isTest
    static void generateRelatedObjectSnapshotTest() {        
        StoryLogUtils.generateRelatedObjectSnapshot(null, null, null, '', '');
    }
    
    @isTest
    static void generateStoryLogEventTest() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        StoryLogEvent__e event = StoryLogUtils.generateStoryLogEvent(testAcc.Id);
        System.assertEquals(testAcc.Id, event.ParentRecordId__c);
    }

    @isTest
    static void obtainLogSnapshotsByParentIdTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        testOpp.NextStep = 'Following Step';
        update testOpp;
                
        System.assertEquals(true, StoryLogUtils.obtainLogSnapshotsByParentId(new Set<Id>{testOpp.Id}).size() > 0);
    }*/
}