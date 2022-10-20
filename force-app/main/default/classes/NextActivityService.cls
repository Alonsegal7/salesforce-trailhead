public with sharing class NextActivityService implements Database.Batchable<Task>, Database.Stateful,Schedulable {
    Map<Id, Boolean> isRecordUpdated = new Map<Id, Boolean>();//it means that we capture the first task as it is the most future task (order by ActivityDate on the context)
    public Iterable<Task> start(Database.BatchableContext BC){
        DateTime dtPast4_Hours = System.Now().addHours(-4);
        return [SELECT Id,WhatId,Status, WhoId,ActivityDate,Who.Type, What.Type, Subject FROM Task WHERE (What.Type = 'Opportunity' OR Who.Type='Lead') AND LastModifiedDate >=:dtPast4_Hours ORDER BY ActivityDate DESC];
    } 
    public void execute(SchedulableContext sc) {
        try{
        Utilities.cleanFlexQueue();
        Database.executeBatch(this,20);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in NextActivityService ', e, e.getMessage());
            Utilities.sendSlackMessage('Error in NextActivityService', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);                        
        }
    }
    public void execute(Database.BatchableContext bc, List<Task> scopeTasks) {
        Set<Id> oppIds = new Set<Id>();
        Set<Id> leadIds = new Set<Id>();
        List<Task> leadTasks = new List<Task>();
        List<Task> oppTasks = new List<Task>();
        for (Task tsk : scopeTasks) {
            if (tsk.WhatId!=null) {//is opp task - update opp only (lead is now contact)
                oppIds.add(tsk.WhatId);
                oppTasks.add(tsk);
            }
            else if (tsk.WhoId!=null && tsk.Who.Type=='Lead')  {//else, handle as lead 
                leadIds.add(tsk.WhoId);
                leadTasks.add(tsk);
            }
        }
        if (!leadIds.isEmpty()) {
            Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id,Next_activity_date__c, Next_activity__c FROM Lead WHERE Id IN: leadIds]);
            List<Lead> leadsToUpdate = new List<Lead>(); 
            for (Task tsk : leadTasks) {
                if (!isRecordUpdated.containsKey(tsk.WhoId)) {//the last task already been handled
                    isRecordUpdated.put(tsk.WhoId,true);//to handle only the last one (orderd on query)
                    if (isOpenFutureTask(tsk)) {
                        if(leadMap.get(tsk.WhoId).Next_activity_date__c!=tsk.ActivityDate || leadMap.get(tsk.WhoId).Next_activity__c!=tsk.Subject){
                        leadsToUpdate.add(new Lead(Id=leadMap.get(tsk.WhoId).Id,Next_activity_date__c=tsk.ActivityDate,Next_activity__c=tsk.Subject));}
                    }
                    else if(leadMap.get(tsk.WhoId).Next_activity_date__c!=null || leadMap.get(tsk.WhoId).Next_activity__c!=null){//the last task is old date task
                        leadsToUpdate.add(new Lead(Id=leadMap.get(tsk.WhoId).Id,Next_activity_date__c=null,Next_activity__c=null));
                    }
                }
            } 
            update leadsToUpdate;
        }
        if (!oppIds.isEmpty()) {
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id,Next_activity_date__c, Next_activity__c FROM Opportunity WHERE Id IN: oppIds]);
            List<Opportunity> oppsToUpdate = new List<Opportunity>(); 
            for (Task tsk : oppTasks) {
                if (!isRecordUpdated.containsKey(tsk.WhatId)) {//the last task already been handled
                    isRecordUpdated.put(tsk.WhatId,true);//to handle only the last one (orderd on query)
                    if (isOpenFutureTask(tsk)) {
                        if(oppMap.get(tsk.WhatId).Next_activity_date__c!=tsk.ActivityDate || oppMap.get(tsk.WhatId).Next_activity__c!=tsk.Subject){
                        oppsToUpdate.add(new Opportunity(Id=oppMap.get(tsk.WhatId).Id,Next_activity_date__c=tsk.ActivityDate,Next_activity__c=tsk.Subject));}
                    }
                    else if(oppMap.get(tsk.WhatId).Next_activity_date__c!=null || oppMap.get(tsk.WhatId).Next_activity__c!=null){//the last task is old date task
                        oppsToUpdate.add(new Opportunity(Id=oppMap.get(tsk.WhatId).Id,Next_activity_date__c=null,Next_activity__c=null));
                    }
                }
            }       
            update oppsToUpdate;  
        }
    }
    private static Boolean isOpenFutureTask(Task tsk){
        return tsk.ActivityDate >= System.today() && tsk.Status!= 'Completed';
    }
    public void finish(Database.BatchableContext bc) {}
}