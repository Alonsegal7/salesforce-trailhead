trigger ProjectTrigger on Project__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            ProjectHandler.before_updateProject(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isInsert){
            ProjectHandler.before_insertProject(Trigger.new);
        }
    }
}