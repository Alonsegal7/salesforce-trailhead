/**
 * Created by Olga_Budiakova on 11.03.2020.
 */

@IsTest
private class ContentVersionTriggerHandlerTest {
    /*@IsTest
    static void handleFilesForStoryLogTest() {
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
            SourceAPIName__c = 'Test_Source_Lable',
            RelatedObjectName__c = 'ContentDocumentLink',
            IconName__c = 'action:follow',
            IsActive__c = true,
            RecordTypeId = Schema.SObjectType.StoryLogItemSetting__c.getRecordTypeInfosByDeveloperName().get('RelatedFile').getRecordTypeId(),
            GroupLogs__c = true
        );
        insert testItemSetting;
        
        ContentNote contentNote = new ContentNote(
                Title = 'Test'
        );
        insert contentNote;

        contentNote = [
                SELECT Id, LatestPublishedVersionId
                FROM ContentNote
                WHERE Id =:contentNote.Id
        ];

        StoryLogSnapshot__c storyLogSnapshot = new StoryLogSnapshot__c(
                StoryLogItemSetting__c = testItemSetting.Id,
                RecordId__c = contentNote.Id,
                DateTime__c = Datetime.now().addHours(2)
        );
        insert storyLogSnapshot;

        ContentVersion contentVersion = [
                SELECT Title
                FROM ContentVersion
                WHERE Id =: contentNote.LatestPublishedVersionId
        ];

        contentVersion.Title = 'New Test';
        System.debug(storyLogSnapshot.Id);
        update contentVersion;
        contentVersion = [
                SELECT Title
                FROM ContentVersion
                WHERE Id =: contentVersion.Id
        ];

        storyLogSnapshot = [
                SELECT Id, StoryLogItemSetting__c, RecordName__c FROM StoryLogSnapshot__c
                WHERE StoryLogItemSetting__c =: testItemSetting.Id
        ];
        System.assertEquals(contentVersion.Title, storyLogSnapshot.RecordName__c);
    }*/
}