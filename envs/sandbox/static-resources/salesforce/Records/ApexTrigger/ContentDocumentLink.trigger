/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 20 February 2020
    * Description: 
    * History:
************************************************************************/

trigger ContentDocumentLink on ContentDocumentLink (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    StoryLogSnapshotCreator.run(ContentDocumentLink.getSObjectType());
}