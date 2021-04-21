/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 12 March 2020
    * Description: 
    * History:
************************************************************************/

trigger StoryLogItemSetting on StoryLogItemSetting__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /*if (Test.isRunningTest()) {
        StoryLogSnapshotCreator.run(StoryLogItemSetting__c.getSObjectType());
    }
    
    new StoryLogItemSettingTriggerHandler().run();*/
}