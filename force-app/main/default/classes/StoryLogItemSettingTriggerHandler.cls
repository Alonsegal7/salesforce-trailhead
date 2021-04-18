/*************************************************************************
    * Created by: Synebo/ Anastasia Sapihora
    * Created date: 12 March 2020
    * Description: Trigger handler on StoryLogSetting__c object
    * History:
    *       generateAPIName - automatically specify API name of the source
************************************************************************/

public with sharing class StoryLogItemSettingTriggerHandler extends TriggerHandler {/*

    public static Map<String, Schema.RecordTypeInfo> storyLogItemRecordTypeMap {
        get {
            if (storyLogItemRecordTypeMap == null) {
                storyLogItemRecordTypeMap = Schema.SObjectType.StoryLogItemSetting__c.getRecordTypeInfosByDeveloperName();
            }
            return storyLogItemRecordTypeMap;
        }
        set;
    }

    protected override void beforeInsert() {
        this.generateAPIName((List<StoryLogItemSetting__c>)Trigger.new);
    }

    private void generateAPIName(List<StoryLogItemSetting__c> newList) {

        for (StoryLogItemSetting__c storyLogItemSetting_i : newList) {
            if (storyLogItemSetting_i.RecordTypeId == storyLogItemRecordTypeMap.get(StoryLogUtils.SL_RECORD_TYPE_FIELD_UPDATE).getRecordTypeId()) {
                storyLogItemSetting_i.SourceAPIName__c = storyLogItemSetting_i.FieldSetName__c;
            }
            if (storyLogItemSetting_i.RecordTypeId == storyLogItemRecordTypeMap.get(StoryLogUtils.SL_RECORD_TYPE_RELATED_FILE).getRecordTypeId() ||
                    storyLogItemSetting_i.RecordTypeId == storyLogItemRecordTypeMap.get(StoryLogUtils.SL_RECORD_TYPE_RELATED_OBJECT).getRecordTypeId()) {
                storyLogItemSetting_i.SourceAPIName__c = storyLogItemSetting_i.RelatedObjectName__c;
            }
        }
    }*/
}