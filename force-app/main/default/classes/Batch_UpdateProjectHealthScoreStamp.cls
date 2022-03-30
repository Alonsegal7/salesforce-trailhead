public without sharing class Batch_UpdateProjectHealthScoreStamp implements Schedulable, Database.Batchable<SObject>, Database.Stateful{
    public Integer projectsUpdatedCount=0;
    public List<Project__c> projectsUpdated = new List<Project__c>();
    public Batch_UpdateProjectHealthScoreStamp() {}

    public void execute(SchedulableContext sc) {
        Batch_UpdateProjectHealthScoreStamp projectHealthScoreBatch = new Batch_UpdateProjectHealthScoreStamp();
        Utilities.cleanFlexQueue();
        Database.executeBatch(projectHealthScoreBatch,20);
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,monday_Account__c FROM Project__c WHERE Project_Status__c = \'Closed\' AND Project_Closed_Date__c  = N_DAYS_AGO:30';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Project__c> scope){
        projectsUpdated = Project_ProjectStamps.Project_HealthscoreStamp(scope);
        projectsUpdatedCount += projectsUpdated.size();
    }
    public void finish(Database.BatchableContext BC){
        system.debug('Batch_UpdateProjectHealthScoreStamp Finished. # of Projects Updated: '+projectsUpdatedCount+' out of total of project: ');
        Utilities.sendEmail('Finished Batch_UpdateProjectHealthScoreStamp Run', '# of Projects Updated: '+projectsUpdatedCount ,new list<String>{'noamle@monday.com'});  
    }
}
