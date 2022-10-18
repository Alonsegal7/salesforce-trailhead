trigger onTaskUpdateTrigger on Task (before insert, before update, after insert, after update, after delete) {
    Task[] tasks = Trigger.new;    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            TaskFieldsMapper.run(tasks);
        }
        for(Task t : tasks){
        	TaskTimeHelper.run(t);        
        }
    }
    
    // if(!Trigger.isDelete && Trigger.isAfter ){
    //     NextActivityHelper.handleChange(tasks);
    // }
    
    //StoryLogSnapshotCreator.run(Task.getSObjectType());
}