/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 17 February 2020
    * Description: 
    * History:
************************************************************************/

trigger Event on Event (before insert, before update, after insert, after update, after delete, after undelete) {
    //StoryLogSnapshotCreator.run(Event.getSObjectType());
}