trigger MilestoneTrigger on Milestone__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //MilestoneHandler.beforeInsert(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isUpdate){
            //MilestoneHandler.beforeInsert(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            MilestoneHandler.afterInsert(Trigger.newMap, Trigger.oldMap);
        }

        if(Trigger.isUpdate){
            MilestoneHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}