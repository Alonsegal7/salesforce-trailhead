public without sharing class Batch_UpdateProjectHealthScoreStamp implements Schedulable, Database.Batchable<SObject>{
    public void execute(SchedulableContext sc) {
        Utilities.cleanFlexQueue();
        Database.executeBatch(this,20);
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,monday_Account__c FROM Project__c WHERE Project_Status__c = \'Closed\' AND Project_Closed_Date__c  = N_DAYS_AGO:30';
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