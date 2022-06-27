public class NextActivityHelper {
    
    public static void handleChange(List<Task> tasks){
        handleLead(tasks);
        handleOpportunity(tasks);
    }
    
    private static void handleLead(Task[] tasks){
        Set<String> ids = new Set<String>();
        for (Task t : tasks) {     
            if(t.WhoId != null){
                ids.add(t.WhoID);     
            }
        }
        if(ids.size() == 0){
            return;
        }
        
        boolean shouldUpdate = false;
        List<Lead> recordsToUpdate = new List<Lead>();

        for (Lead lead : [SELECT Id, time_zone_offset__c, Next_activity_date__c, Next_activity__c,
        (SELECT Id, ActivityDate, Subject FROM Tasks WHERE ActivityDate >= :System.TODAY() AND Status != 'Completed' ORDER BY ActivityDate ASC LIMIT 1)
        FROM Lead WHERE Id =: ids]) {
           shouldUpdate = false;
            Task[] nextTasks = lead.Tasks;
            if(nextTasks.size() > 0){
                if(lead.Next_activity_date__c != nextTasks[0].ActivityDate || lead.Next_activity__c != nextTasks[0].Subject){
                    shouldUpdate = true;
                	lead.Next_activity_date__c = nextTasks[0].ActivityDate;
	                lead.Next_activity__c = nextTasks[0].Subject;    
                }
            }else{
                if(lead.Next_activity_date__c != null || lead.Next_activity__c != null){
                    shouldUpdate = true;
                	lead.Next_activity_date__c = null;
	                lead.Next_activity__c  = null;    
                }
            }
            if(shouldUpdate){
                recordsToUpdate.add(lead);
            }
        }
        if(recordsToUpdate.size() > 0){
            update recordsToUpdate;
        }
    }
    
    private static void handleOpportunity(Task[] tasks){
        Set<String> ids = new Set<String>();
        for (Task t : tasks) {
            if(t.WhatID != null){
                ids.add(t.WhatID);     
            }
        }
        if(ids.size() == 0){
            return;
        }
        
        boolean shouldUpdate = false;
        List<Opportunity> recordsToUpdate = new List<Opportunity>();

        for (Opportunity opp : [SELECT Id, Next_activity_date__c, Next_activity__c,
        (SELECT Id, ActivityDate, Subject FROM Tasks WHERE ActivityDate >= :System.TODAY() AND Status != 'Completed' ORDER BY ActivityDate ASC LIMIT 1)
        FROM Opportunity WHERE Id =: ids]) {
            shouldUpdate = false;
            Task[] nextTasks = opp.Tasks;
            if(nextTasks.size() > 0){
                if(opp.Next_activity_date__c != nextTasks[0].ActivityDate || opp.Next_activity__c != nextTasks[0].Subject){
                    shouldUpdate = true;
                    opp.Next_activity_date__c = nextTasks[0].ActivityDate;
                    opp.Next_activity__c  = nextTasks[0].Subject;
                }
            }else{
                if(opp.Next_activity_date__c != null || opp.Next_activity__c != null){
                    shouldUpdate = true;
                    opp.Next_activity_date__c = null;
                    opp.Next_activity__c  = null;
				}
            }
            if(shouldUpdate){
                recordsToUpdate.add(opp);
            }
        }
        if(recordsToUpdate.size() > 0){
            try {
                update recordsToUpdate;
            } catch (Exception ex) {
                if(ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW')) {
                    try {
                        update recordsToUpdate;
                    } catch (Exception e) {
                        Utilities.sendDebugEmail('Error in NextActivityHelper ', e, e.getMessage());
                    }
                }
                else {
                    Utilities.sendDebugEmail('Error in NextActivityHelper ', ex, ex.getMessage());
                }
            }
        }
    }
}