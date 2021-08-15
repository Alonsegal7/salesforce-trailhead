trigger ProjectTrigger on Project__c (before insert, before update, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ProjectHandler.beforeInsert(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isUpdate){
            ProjectHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}