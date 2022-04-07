public without sharing class Batch_UpdateProjectHealthScoreStamp implements Database.Batchable<SObject>, Schedulable{
    public void execute(SchedulableContext sc) { 
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this, 20); 
        }catch(Exception e){
            system.debug('Batch_UpdateProjectHealthScoreStamp error scheduler: '+ e.getMessage());
            Utilities.sendDebugEmail('Error in Batch_UpdateProjectHealthScoreStamp ', e, e.getMessage());   
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC) { //job2
        String query = 'SELECT Id,monday_Account__c FROM Project__c WHERE Project_Status__c = \'Closed\' AND Project_Closed_Date__c = N_DAYS_AGO:30';
        system.debug('query result-Batch_UpdateProjectHealthScoreStamp: '+ query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Project__c> scope){
        Project_ProjectStamps.Project_HealthscoreStamp(scope);
    }
    public void finish(Database.BatchableContext BC){
        system.debug('Batch_UpdateProjectHealthScoreStamp Finished');
        Utilities.sendEmail('Finished Batch_UpdateProjectHealthScoreStamp Run', 'Finished Batch_UpdateProjectHealthScoreStamp Run' ,new list<String>{'noamle@monday.com'});  
    }
}