public without sharing class Batch_UpdateSuccessKPIsStamps implements Database.Batchable<SObject>, Schedulable{
    public Integer TargetsCreated=0;
    public Integer TotalTargetsCreated=0;
    public void execute(SchedulableContext sc) { 
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this, 20); 
        }catch(Exception e){
            system.debug('Batch_UpdateSuccesKPIsStamps error scheduler: '+ e.getMessage());
            Utilities.sendDebugEmail('Error in Batch_UpdateSuccesKPIsStamps ', e, e.getMessage());   
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC) { //job2
        String query = 'SELECT Id,monday_Account__c FROM Success_KPI__c WHERE Target_End_Date__c = YESTERDAY AND Department__c = \'CS\' AND monday_Account__c != null ';
        system.debug('query result-Batch_UpdateSuccesKPIsStamps: '+ query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Success_KPI__c> scope){
        SuccessKPI_MappHealthScoreStamp.SuccessKPI_MappHealthScoreStamp(scope);
        TargetsCreated = SuccessKPI_MappHealthScoreStamp.SuccessKPI_MappHealthScoreStamp(scope).size();
        TotalTargetsCreated += TargetsCreated;  
    }
    public void finish(Database.BatchableContext BC){
        system.debug('Batch_UpdateSuccesKPIsStamps Finished');
        Utilities.sendEmail('Finished Batch_UpdateSuccesKPIsStamps Run', 'Finished Batch_UpdateSuccesKPIsStamps Run'+ TotalTargetsCreated ,new list<String>{'noamle@monday.com'});  
    }
}