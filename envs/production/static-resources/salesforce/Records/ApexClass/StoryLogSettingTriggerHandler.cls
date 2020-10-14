/*************************************************************************
    * Created by: Synebo/ Anastasia Sapihora
    * Created date: 17 February 2020
    * Description: 
    * History:
************************************************************************/

public with sharing class StoryLogSettingTriggerHandler extends TriggerHandler {

    protected override void afterInsert() {
        this.preventDuplicate((Map<Id, StoryLogSetting__c>)Trigger.newMap, (Map<Id, StoryLogSetting__c>)Trigger.oldMap);
    }

    protected override void afterUpdate() {
        this.preventDuplicate((Map<Id, StoryLogSetting__c>)Trigger.newMap, (Map<Id, StoryLogSetting__c>)Trigger.oldMap);
    }

    private void preventDuplicate(Map<Id, StoryLogSetting__c> newMap, Map<Id, StoryLogSetting__c> oldMap) {

        Set<String> targetObjectSet = new Set<String>();
        for (StoryLogSetting__c storyLogSetting_i : newMap.values()) {
            if (Trigger.isInsert && storyLogSetting_i.IsActive__c ||
                Trigger.isUpdate && storyLogSetting_i.IsActive__c && !oldMap.get(storyLogSetting_i.Id).IsActive__c)  {
                targetObjectSet.add(storyLogSetting_i.TargetObjectName__c);
            }
        }

        Map<String, Boolean> storyLogSettingsMap = new Map<String, Boolean>();
        List<StoryLogSetting__c> storyLogSettings = [
            SELECT Id, TargetObjectName__c
            FROM StoryLogSetting__c
            WHERE Id NOT IN: newMap.keySet() AND IsActive__c = true AND TargetObjectName__c IN: targetObjectSet
        ];
        if (!storyLogSettings.isEmpty()) {
            for (StoryLogSetting__c storyLogSetting_i : storyLogSettings) {
                if (!storyLogSettingsMap.containsKey(storyLogSetting_i.TargetObjectName__c)) {
                    storyLogSettingsMap.put(storyLogSetting_i.TargetObjectName__c, true);
                }
            }
        }

        for (StoryLogSetting__c storyLogSetting_i : newMap.values()) {
            if (storyLogSettingsMap.containsKey(storyLogSetting_i.TargetObjectName__c) &&
                    (Trigger.isInsert && storyLogSetting_i.IsActive__c ||
                     Trigger.isUpdate && storyLogSetting_i.IsActive__c && !oldMap.get(storyLogSetting_i.Id).IsActive__c)) {
                storyLogSetting_i.addError(Label.DuplicatedStoryLogSetting);
            } else if (storyLogSetting_i.IsActive__c) {
                storyLogSettingsMap.put(storyLogSetting_i.TargetObjectName__c, true);
            }
        }
    }
}