trigger KickoffTrigger on Kickoff__c (before insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            MilestoneHandler.afterInsert(Trigger.newMap, Trigger.oldMap);
        }

        if(Trigger.isUpdate){
            MilestoneHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}
{"mode":"full","isActive":false}