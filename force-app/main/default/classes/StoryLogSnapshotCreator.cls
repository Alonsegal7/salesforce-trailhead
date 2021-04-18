/*************************************************************************
    * Created by: Synebo/ Anastasia Sapihora
    * Created date: 12 February 2020
    * Description:
************************************************************************/

public inherited sharing class StoryLogSnapshotCreator extends StoryLogHandler {/*
    public static void run(Schema.SObjectType sObjectType) {
        StoryLogSnapshotCreator logCreator = new StoryLogSnapshotCreator();
        logCreator.setSObjectType(sObjectType);
        logCreator.setStorySettings();
        logCreator.run();
    }
    
    protected override void afterInsert() {
        this.relatedObjectsDMLHandle(Trigger.new);
        if (this.getSObjectType() == ContentDocumentLink.getSObjectType()) {
            this.handleRelatedFiles((List<ContentDocumentLink>) Trigger.new);
        }
    }

    protected override void afterDelete() {
        this.relatedObjectsDMLHandle(Trigger.old);
        this.parentObjectDeleteHandle(Trigger.oldMap);

        if (this.getSObjectType() == ContentDocumentLink.getSObjectType()) {
            this.handleRelatedFiles((List<ContentDocumentLink>) Trigger.new);
        }
    }

    protected override void afterUndelete() {
        this.relatedObjectsDMLHandle(Trigger.new);
    }

    protected override void afterUpdate() {
        this.targetObjectsDMLHandle(Trigger.new, Trigger.oldMap);
    }

    private void relatedObjectsDMLHandle(List<SObject> sObjectList) {
        if (this.storyLogSetting.targetSObjectType == this.getSObjectType().getDescribe().getName()) {
            return;
        }

        String nameField = Utils.obtainNameField(this.getSObjectType());
        String contextDescription = '';

        Map<Id, String> trackMap = new Map<Id, String>();
        if (Trigger.isInsert) {
            trackMap = storyLogSetting.trackCreate;
            contextDescription = Label.RecordIsCreated;
        }
        if (Trigger.isDelete) {
            trackMap = storyLogSetting.trackDelete;
            contextDescription = Label.RecordIsDeleted;
        }
        if (Trigger.isUndelete) {
            trackMap = storyLogSetting.trackUndelete;
            contextDescription = Label.RecordIsRestored;
        }

        for (SObject sobj_i : sObjectList) {
            if (trackMap.isEmpty()) {
                continue;
            }

            for (Id logId_i : trackMap.keySet()) {
                StoryLogSnapshot__c snapshot = StoryLogUtils.generateRelatedObjectSnapshot(
                        (Id)sobj_i.get(trackMap.get(logId_i)),
                        !Trigger.isDelete ? sobj_i.Id : null,
                        logId_i,
                        (String)sobj_i.get(nameField),
                        contextDescription
                );
                if (this.getSObjectType().getDescribe().getName() == 'Task') {
                    snapshot.SubType__c = (String)sobj_i.get('Type');
                }

                this.addSnapshot2(
                        snapshot
                );
                this.addStoryLogEvent((Id)sobj_i.get(trackMap.get(logId_i)));
            }
        }
    }

    private void targetObjectsDMLHandle(List<SObject> newList, Map<Id, SObject> oldMap) {
        Map<Id, List<StoryLogSnapshot__c>> storyLogSnapshots = StoryLogUtils.obtainStoryLogSnapshots(
                this.storyLogItemSettingMap, this.storyLogSetting.fieldsToCheck, newList, oldMap
        );

        for (Id recordId_i : storyLogSnapshots.keySet()) {
            if (storyLogSnapshots.containsKey(recordId_i) && !storyLogSnapshots.get(recordId_i).isEmpty()) {
                this.addSnapshots(storyLogSnapshots.get(recordId_i));
                this.addStoryLogEvent(recordId_i);
            }
        }
    }

    private void parentObjectDeleteHandle(Map<Id, SObject> oldMap) {
        if (this.storyLogSetting.removeSnapshotsOnParentDelete) {
            delete StoryLogUtils.obtainLogSnapshotsByParentId(oldMap.keySet());
        }
    }

    private void handleRelatedFiles(List<ContentDocumentLink> contentDocLinkList) {
        if (this.getSObjectType() != ContentDocumentLink.getSObjectType()) {
            return;
        }
        String contextDescription = '';
        Map<Id, Set<String>> cvTrackMap = new Map<Id,  Set<String>>();
        if (Trigger.isInsert) {
            cvTrackMap = this.storyLogSetting.trackFileCreate;
            contextDescription = Label.RecordIsCreated;
        }
        if (Trigger.isDelete) {
            cvTrackMap = this.storyLogSetting.trackFileCreate;
            contextDescription = Label.RecordIsDeleted;
        }

        Map<Id, Id> contentDocIdMap = new Map<Id, Id>();
        for (ContentDocumentLink contentDocumentLink_i : contentDocLinkList) {
            if (contentDocumentLink_i.LinkedEntityId.getSobjectType().getDescribe().getName() == this.storyLogSetting.targetSObjectType) {
                contentDocIdMap.put(contentDocumentLink_i.ContentDocumentId, contentDocumentLink_i.LinkedEntityId);
            }
        }

        List<ContentDocument> contentDocumentList = [
                SELECT Id, Title, LatestPublishedVersionId, LatestPublishedVersion.FileType, LatestPublishedVersion.VersionData
                FROM ContentDocument
                WHERE Id IN: contentDocIdMap.keySet()
        ];
        for (ContentDocument contentDocument_i : contentDocumentList) {
            for (Id logId_i : cvTrackMap.keySet()) {
                if (!cvTrackMap.get(logId_i).contains(contentDocument_i.LatestPublishedVersion.FileType)) {
                    continue;
                }

                contextDescription = contentDocument_i.LatestPublishedVersion.VersionData.toString();//  'CONTENT DATAT'; //contentDocument_i.LatestPublishedVersion.VersionData;
                contextDescription = (contextDescription.length() < 255) ? contextDescription : contextDescription.substring(0, 255);

                this.addSnapshot2(
                        StoryLogUtils.generateRelatedObjectSnapshot(
                                contentDocIdMap.get(contentDocument_i.Id),
                                !Trigger.isDelete ? contentDocument_i.Id : null,
                                logId_i,
                                contentDocument_i.Title,
                                contextDescription
                        )
                );
            }
            this.addStoryLogEvent(contentDocIdMap.get(contentDocument_i.Id));
        }
    }*/
}