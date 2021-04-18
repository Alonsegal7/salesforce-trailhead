/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 12 March 2020
    * Description: 
    * History:
************************************************************************/
@IsTest
public with sharing class StoryLogItemSettingTriggerHandlerTest {
    /*@IsTest
    public static void generateAPIName(){
        StoryLogSetting__c storyLogSetting = new StoryLogSetting__c(
                Name = 'Test',
                TargetObjectName__c = 'Opportunity',
                IsActive__c = true,
                RemoveSnapshotsOnParentDelete__c = true
        );
        insert storyLogSetting;

        StoryLogItemSetting__c testItemSetting = new StoryLogItemSetting__c(
                StoryLogSetting__c = storyLogSetting.Id,
                SourceLabel__c = 'Test Source Lable',
                FieldSetName__c = 'Test_Source_Lable',
                IconName__c = 'action:follow',
                IsActive__c = true,
                RecordTypeId = Schema.SObjectType.StoryLogItemSetting__c.getRecordTypeInfosByDeveloperName().get('FieldUpdate').getRecordTypeId(),
                GroupLogs__c = true
        );
        insert testItemSetting;

        StoryLogItemSetting__c testItemSetting2 = new StoryLogItemSetting__c(
                StoryLogSetting__c = storyLogSetting.Id,
                SourceLabel__c = 'Test Source Lable',
                RelatedObjectName__c = 'ContentDocumentLink',
                IconName__c = 'action:follow',
                IsActive__c = true,
                RecordTypeId = Schema.SObjectType.StoryLogItemSetting__c.getRecordTypeInfosByDeveloperName().get('RelatedFile').getRecordTypeId(),
                GroupLogs__c = true
        );
        insert testItemSetting2;

        testItemSetting = [
                SELECT FieldSetName__c, SourceAPIName__c
                FROM StoryLogItemSetting__c
                WHERE Id =: testItemSetting.Id
        ];

        testItemSetting2 = [
                SELECT SourceAPIName__c, RelatedObjectName__c
                FROM StoryLogItemSetting__c
                WHERE Id =: testItemSetting2.Id
        ];
        System.assertEquals(testItemSetting.FieldSetName__c, testItemSetting.SourceAPIName__c);
        System.assertEquals(testItemSetting2.RelatedObjectName__c, testItemSetting2.SourceAPIName__c);
    }*/
}