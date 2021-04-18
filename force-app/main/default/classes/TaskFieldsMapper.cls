public class TaskFieldsMapper {
    
    // this should called only on before insert of new Tasks
    public static void run(Task[] tasks){
        updateSubType(tasks);
        handleLead(tasks);
        handleOpportunity(tasks);
    }
    
    private static void updateSubType(Task[] tasks){
        for(Task t : tasks){
            if(t.Description != '' && t.Description != null && t.Description.contains('by Yesware')){
                t.Type = 'Email';
                t.TaskSubtype = 'Email';
            }
            
            if(t.Type == 'Call' && t.Status == 'Completed'){
                t.TaskSubtype = 'Call';
            }
        }
    }
    
    private static void handleOpportunity(Task[] tasks){
        Set<String> ids = new Set<String>();
        Map<String, Task> tasksMap = new Map<String, Task>();
        for (Task t : tasks) {
            tasksMap.put(t.WhatId, t);            
            if(t.WhatId != null){
                ids.add(t.WhatId);     
            }
        }
        if(ids.size() == 0){
            return;
        }
        
        List<Opportunity> opps = [SELECT Id, AccountId, time_zone_offset__c FROM Opportunity WHERE Id=:ids];
        for (Opportunity o : opps) {
            Task t = tasksMap.get(o.Id);
            t.Company__c = o.AccountId;
            if(t.Opportunity__c == null){
            	t.Opportunity__c = o.Id;
            }
            updateOpportunityTimeZone(t, o);
        }
    }
    
    private static void handleLead(Task[] tasks){
        Set<String> ids = new Set<String>();
        Map<String, Task> tasksMap = new Map<String, Task>();
        for (Task t : tasks) {
            tasksMap.put(t.WhoId, t);            
            if(t.WhoId != null && t.Status != 'Completed'){
                ids.add(t.WhoID);     
            }
        }
        if(ids.size() == 0){
            return;
        }
        
        List<Lead> leads = [SELECT Id, time_zone_offset__c, Related_Company__c FROM Lead WHERE Id=:ids];
        for (Lead l : leads) {
            Task t = tasksMap.get(l.Id);
            t.Company__c = l.Related_Company__c;
			updateLeadTimeZone(t, l);
        }
    }
    
    private static void updateLeadTimeZone(Task task, Lead lead){
        if(task.time_zone_offset__c == null && lead.time_zone_offset__c != null){
            task.time_zone_offset__c = lead.time_zone_offset__c;
        }
    }
    

    private static void updateOpportunityTimeZone(Task task, Opportunity opp){
        if(task.time_zone_offset__c == null && opp.time_zone_offset__c != null){
            task.time_zone_offset__c = opp.time_zone_offset__c;
        }
    }
}