/*************************************************************************
    * Created by: Synebo/ Anastasia Sapihora
    * Created date: 28 January 2020
    * Description: Apex class for Util methods
************************************************************************/

public inherited sharing class StoryLogUtils {/*

    public static final String SL_RECORD_TYPE_FIELD_UPDATE = 'FieldUpdate';
    public static final String SL_RECORD_TYPE_RELATED_FILE = 'RelatedFile';
    public static final String SL_RECORD_TYPE_RELATED_OBJECT = 'RelatedObject';

    public static Map<String, String> obtainSourceTypes(SObjectType sObjType) {
        Map<String, String> toReturn = new Map<String, String>();
        List<StoryLogItemSetting__c> storyLogItemSettingList = [
                SELECT Id, SourceLabel__c, SourceAPIName__c
                FROM StoryLogItemSetting__c
                WHERE IsActive__c = true AND StoryLogSetting__r.IsActive__c = true
                AND StoryLogSetting__r.TargetObjectName__c =: String.valueOf(sObjType.getDescribe().getSObjectType())
        ];
        for (StoryLogItemSetting__c storyLogItemSetting_i : storyLogItemSettingList) {
            toReturn.put(storyLogItemSetting_i.SourceAPIName__c, storyLogItemSetting_i.SourceLabel__c);
        }
        return toReturn;
    }

    public static StoryLogSetting obtainStoryLogSettings(SObjectType objType) {
        if (objType == null || objType.getDescribe() == null || !objType.getDescribe().isAccessible()) {
            return null;
        }

        Map<Id, StoryLogItemSetting__c> storyLogItemSettingList = new Map<Id, StoryLogItemSetting__c>([
                SELECT RecordType.DeveloperName, Id, StoryLogSetting__c, StoryLogSetting__r.TargetObjectName__c, StoryLogSetting__r.RemoveSnapshotsOnParentDelete__c, GroupLogs__c
                     , FieldSetName__c, RelatedObjectName__c, ForeignKey__c, TrackInsert__c, TrackDelete__c, TrackUndelete__c, FileTypesToTrack__c
                FROM StoryLogItemSetting__c
                WHERE RecordTypeId != null AND IsActive__c = true AND StoryLogSetting__r.IsActive__c = true
                AND (
                        StoryLogSetting__r.TargetObjectName__c =: String.valueOf(objType.getDescribe().getSObjectType())
                        OR RelatedObjectName__c =: String.valueOf(objType.getDescribe().getSObjectType())
                     )
                ORDER BY StoryLogSetting__c
        ]);
        if (storyLogItemSettingList.isEmpty()) {
            return null;
        }

        StoryLogSetting slSettings = new StoryLogSetting();
        for (StoryLogItemSetting__c slItem_i : storyLogItemSettingList.values()) {

            if (slItem_i.RecordType.DeveloperName == Constants.STORY_LOG_TYPE_FIELD_UPDATE &&
                    String.isNotBlank(slItem_i.FieldSetName__c) && !slSettings.fieldsToCheck.containsKey(slItem_i.Id)) {
                slSettings.fieldsToCheck.put(slItem_i.Id, Utils.fetchFieldsFromFieldSet(objType.getDescribe().fieldSets.getMap().get(slItem_i.FieldSetName__c)));
            }

            else if (slItem_i.RecordType.DeveloperName == Constants.STORY_LOG_TYPE_RELATED_OBJECT) {
                if (String.isNotBlank(slItem_i.ForeignKey__c) && slItem_i.TrackInsert__c
                        && !slSettings.trackCreate.containsKey(slItem_i.Id)) {
                    slSettings.trackCreate.put(slItem_i.Id, slItem_i.ForeignKey__c);
                }
                if (String.isNotBlank(slItem_i.ForeignKey__c) && slItem_i.TrackDelete__c
                        && !slSettings.trackDelete.containsKey(slItem_i.Id)) {
                    slSettings.trackDelete.put(slItem_i.Id, slItem_i.ForeignKey__c);
                }
                if (String.isNotBlank(slItem_i.ForeignKey__c) && slItem_i.TrackUndelete__c
                        && !slSettings.trackUndelete.containsKey(slItem_i.Id)) {
                    slSettings.trackUndelete.put(slItem_i.Id, slItem_i.ForeignKey__c);
                }
            }

            else if (slItem_i.RecordType.DeveloperName == Constants.STORY_LOG_TYPE_RELATED_FILE) {
                if (String.isNotBlank(slItem_i.FileTypesToTrack__c) && slItem_i.TrackInsert__c) {
                    slSettings.trackFileCreate.put(slItem_i.Id, new Set<String>{'SNOTE'});
                }
                if (String.isNotBlank(slItem_i.FileTypesToTrack__c) && slItem_i.TrackDelete__c) {
                    slSettings.trackFileCreate.put(slItem_i.Id, new Set<String>{'SNOTE'});
                }
            }
        }
        slSettings.storyLogItemSettingMap = storyLogItemSettingList;
        slSettings.removeSnapshotsOnParentDelete = storyLogItemSettingList.values()[0].StoryLogSetting__r.RemoveSnapshotsOnParentDelete__c;
        slSettings.targetSObjectType = storyLogItemSettingList.values()[0].StoryLogSetting__r.TargetObjectName__c;
        return slSettings;
    }

    public static Map<Id, List<StoryLogSnapshot__c>> obtainStoryLogSnapshots(
            Map<Id, StoryLogItemSetting__c> storyLogItemSettingMap,
            Map<Id, List<Schema.SObjectField>> fieldsToCheckMap,
            List<SObject> newObjects, Map<Id, SObject> oldObjects) {

        Map<Id, List<StoryLogSnapshot__c>> storyLogSnapshots = new Map<Id, List<StoryLogSnapshot__c>>();

        if (oldObjects == null || oldObjects.isEmpty()) {
            return storyLogSnapshots;
        }

        List<SObject> changedObjects = new List<SObject>();
        for (SObject obj : newObjects) {
            Boolean isChanged = false;

            SObject oldObject = Trigger.isExecuting && Trigger.isBefore &&
                    Utils.recursiveOldMap.containsKey(obj.Id) ? Utils.recursiveOldMap.get(obj.Id) : (oldObjects.containsKey(obj.Id) ? oldObjects.get(obj.Id) : null);

            if (oldObject != null && obj.Id != null) {

                if (!storyLogSnapshots.containsKey(obj.Id)) {
                    storyLogSnapshots.put(obj.Id, new List<StoryLogSnapshot__c>());
                }

                for (Id storyLogItemId_i : fieldsToCheckMap.keySet()) {

                    String groupKey;

                    for (Schema.SObjectField fieldName : fieldsToCheckMap.get(storyLogItemId_i)) {
                        if (obj.get(fieldName) != oldObject.get(fieldName)) {
                            if (!storyLogItemSettingMap.get(storyLogItemId_i).GroupLogs__c) {
                                storyLogSnapshots.get(obj.Id).add(
                                        generateFieldUpdateSnapshot(
                                            fieldName, obj.Id, storyLogItemId_i,
                                            String.valueOf(oldObject.get(fieldName)), String.valueOf(obj.get(fieldName))
                                        )
                                );
                            } else {
                                if (groupKey == null) {
                                    groupKey = Utils.generateRandomString(20);
                                    StoryLogSnapshot__c snapshot = new StoryLogSnapshot__c(
                                            GroupKey__c = groupKey,
                                            IsGrouped__c = true,
                                            StoryLogItemSetting__c = storyLogItemId_i,
                                            ParentRecordId__c = obj.Id,
                                            User__c = UserInfo.getUserId(),
                                            DateTime__c = Datetime.now(),
                                            Type__c = Constants.STORY_LOG_TYPE_FIELD_UPDATE
                                    );
                                    storyLogSnapshots.get(obj.Id).add(snapshot);
                                }
                                StoryLogSnapshot__c snapshot = generateFieldUpdateSnapshot(
                                        fieldName, obj.Id, storyLogItemId_i,
                                        String.valueOf(oldObject.get(fieldName)), String.valueOf(obj.get(fieldName))
                                );
                                snapshot.GroupKey__c = groupKey;
                                storyLogSnapshots.get(obj.Id).add(snapshot);
                            }
                        }
                    }
                }
            }

            if (isChanged) {
                changedObjects.add(obj);
            }
        }
        return storyLogSnapshots;
    }
    
    public static StoryLogSnapshot__c generateFieldUpdateSnapshot(Schema.SObjectField field, Id parentRecordId, Id logSettingsId, String oldValue, String newValue) {
        oldValue = (String.isNotBlank(oldValue)) ? oldValue : Label.Blank;
        newValue = (String.isNotBlank(newValue)) ? newValue : Label.Blank;
        String shortDescription = ('<i>' + field.getDescribe().getLabel() + '</i> changed from <b>' + oldValue + '</b> to <b>' + newValue + '</b>');
        
        StoryLogSnapshot__c toReturn = new StoryLogSnapshot__c(
                FieldLabel__c = field.getDescribe().getLabel(),
                FieldName__c = field.getDescribe().getName(),
                StoryLogItemSetting__c = logSettingsId,
                ParentRecordId__c = parentRecordId,
                OldValue__c = oldValue,
                NewValue__c = newValue,
                User__c = UserInfo.getUserId(),
                Type__c = Constants.STORY_LOG_TYPE_FIELD_UPDATE,
                ShortDescription__c = shortDescription,
                DateTime__c = Datetime.now()
        );
        return toReturn;
    }

    public static StoryLogSnapshot__c generateRelatedObjectSnapshot(Id parentRecordId, Id trackedRecordId, Id logSettingsId, String recordName, String descr) {
        StoryLogSnapshot__c toReturn = new StoryLogSnapshot__c(
                RecordName__c = recordName,
                ParentRecordId__c = parentRecordId,
                StoryLogItemSetting__c = logSettingsId,
                RecordId__c = trackedRecordId,
                User__c = UserInfo.getUserId(),
                Type__c = Constants.STORY_LOG_TYPE_RELATED_OBJECT,
                ShortDescription__c = descr,
                DateTime__c = Datetime.now()
        );
        return toReturn;
    }

    public static StoryLogEvent__e generateStoryLogEvent(Id parentRecordId) {
        return new StoryLogEvent__e(
                ParentRecordId__c = parentRecordId
        );
    }

    public static List<StoryLogSnapshot__c> obtainLogSnapshotsByParentId(Set<Id> parentIdSet) {
        return [
                SELECT Id
                FROM StoryLogSnapshot__c
                WHERE ParentRecordId__c IN: parentIdSet
        ];
    }

    public class StoryLogSetting {
        public String targetSObjectType;
        public Map<Id, List<Schema.SObjectField>> fieldsToCheck;
        public Boolean removeSnapshotsOnParentDelete;
        public Map<Id, String> trackCreate;
        public Map<Id, String> trackDelete;
        public Map<Id, String> trackUndelete;

        public Map<Id, Set<String>> trackFileCreate;
        public Map<Id, Set<String>> trackFileDelete;

        public Map<Id, StoryLogItemSetting__c> storyLogItemSettingMap;
        public StoryLogSetting() {
            this.fieldsToCheck = new Map<Id, List<Schema.SObjectField>>();
            this.trackCreate = new Map<Id, String>();
            this.trackDelete = new Map<Id, String>();
            this.trackUndelete = new Map<Id, String>();
            this.trackFileCreate = new Map<Id, Set<String>>();
            this.trackFileDelete = new Map<Id, Set<String>>();
            this.storyLogItemSettingMap = new Map<Id, StoryLogItemSetting__c>();
        }
    }*/
}