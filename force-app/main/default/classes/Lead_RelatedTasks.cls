public without sharing class Lead_RelatedTasks {
    public static void markTasksCompleted(List<Lead> newLeads_list, Map<Id,Lead> oldLeads_map) {
        // Mark all related tasks as Completed when Lead is Unqualified
        Set<Id> leadIdsToCompleteTasks = new Set<Id>();
                
        for(Lead leadRec : newLeads_list){            
            if(oldLeads_map != null && leadRec.Status != oldLeads_map.get(leadRec.Id).Status && leadRec.Status == 'Unqualified'){
                leadIdsToCompleteTasks.add(leadRec.Id);
            }
        }

        if(!leadIdsToCompleteTasks.isEmpty()){
            List<Task> tasks_list = [SELECT Id, Status from Task WHERE WhoId in: leadIdsToCompleteTasks and Status != 'Completed'];
            for (Task t : tasks_list) { 
                t.Status = 'Completed'; 
            }
            update tasks_list;
        }
    }
}