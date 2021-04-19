/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 11 March 2020
    * Description: 
    * History:
************************************************************************/

public with sharing class ContentVersionTriggerHandler extends TriggerHandler {

    protected override void afterUpdate() {
        this.handleFilesForStoryLog((List<ContentVersion>)Trigger.new, (Map<Id, ContentVersion>)Trigger.oldMap);
    }

    private void handleFilesForStoryLog(List<ContentVersion> newList, Map<Id, ContentVersion> oldMap) {
        List<ContentVersion> contentVersionToProcessList = Utils.getChangedObjects(
                new List<Schema.SObjectField>{Schema.ContentVersion.Title,Schema.ContentVersion.VersionData},
                newList,
                oldMap
        );
        if (contentVersionToProcessList.isEmpty()) {
            return;
        }

        Map<Id, ContentNote> noteMap = new Map<Id, ContentNote>([
                SELECT Id, LatestPublishedVersionId
                FROM ContentNote
                WHERE LatestPublishedVersionId IN:Trigger.newMap.keySet()
        ]);

        if (!noteMap.isEmpty()) {
            Map<String, String> cvToNoteMap = new Map<String, String>();
            for (Id noteId_i : noteMap.keySet()) {
                cvToNoteMap.put(noteMap.get(noteId_i).LatestPublishedVersionId, noteId_i);
            }

            List<StoryLogSnapshot__c> snapshotList = [
                    SELECT Id, DateTime__c, RecordId__c, ParentRecordId__c
                    FROM StoryLogSnapshot__c
                    WHERE RecordId__c IN:noteMap.keySet()
                    ORDER BY DateTime__c DESC
            ];
            if (!snapshotList.isEmpty()) {
                Map<String, List<StoryLogSnapshot__c>> noteIdToSnaphotsMap = new Map<String, List<StoryLogSnapshot__c>>();
                for (StoryLogSnapshot__c snapshot_i : snapshotList) {
                    if (!noteIdToSnaphotsMap.containsKey(snapshot_i.RecordId__c)) {
                        noteIdToSnaphotsMap.put(snapshot_i.RecordId__c, new List<StoryLogSnapshot__c>());
                    }
                    noteIdToSnaphotsMap.get(snapshot_i.RecordId__c).add(snapshot_i);
                }

                List<StoryLogSnapshot__c> toUpdate = new List<StoryLogSnapshot__c>();
                List<StoryLogEvent__e> storyLogEventsList = new List<StoryLogEvent__e>();
                for (ContentVersion contentVersion_i : newList) {
                    if (cvToNoteMap.containsKey(contentVersion_i.Id) && noteIdToSnaphotsMap.containsKey(cvToNoteMap.get(contentVersion_i.Id))) {
                        if (noteIdToSnaphotsMap.get(cvToNoteMap.get(contentVersion_i.Id))[0].DateTime__c >= DateTime.now().addMinutes(-10)) {
                            noteIdToSnaphotsMap.get(cvToNoteMap.get(contentVersion_i.Id))[0].RecordName__c = contentVersion_i.Title;
                            noteIdToSnaphotsMap.get(cvToNoteMap.get(contentVersion_i.Id))[0].ShortDescription__c = contentVersion_i.VersionData.toString();
                            toUpdate.add(noteIdToSnaphotsMap.get(cvToNoteMap.get(contentVersion_i.Id))[0]);

                            storyLogEventsList.add(
                                    StoryLogUtils.generateStoryLogEvent(noteIdToSnaphotsMap.get(cvToNoteMap.get(contentVersion_i.Id))[0].ParentRecordId__c)
                            );

                        } else {
                            // no action
                        }
                    }
                }
                update toUpdate;
                List<Database.SaveResult> saveResultList = EventBus.publish(storyLogEventsList);
            }
        }
    }
}