/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 17 February 2020
    * Description: 
    * History:
************************************************************************/

trigger ContentVersion on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ContentVersionTriggerHandler().run();
}