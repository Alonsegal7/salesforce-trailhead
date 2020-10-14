/*************************************************************************
    * Created by: Synebo/ Anastasia Sapihora
    * Created date: 12 March 2020
    * Description: Trigger on custom object StoryLogSetting__c
************************************************************************/

trigger StoryLogSetting on StoryLogSetting__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Test.isRunningTest()) {
        StoryLogSnapshotCreator.run(StoryLogSetting__c.getSObjectType());
    }
    
    new StoryLogSettingTriggerHandler().run();
}