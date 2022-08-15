public without sharing class Batch_CalculateHandoverThresholds implements Schedulable, Database.Batchable<SObject>, Database.Stateful{

    Integer oppsUpdated=0;
        
    public void execute(SchedulableContext sc) {
        Batch_CalculateHandoverThresholds calcHandoverBatch = new Batch_CalculateHandoverThresholds();
        Utilities.cleanFlexQueue();
        Database.executeBatch(calcHandoverBatch,20);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id' + Handover_ThresholdMapping.relevantOppFields + ' FROM Opportunity WHERE RecordType.Name = \'Internal Opportunity\' AND IsClosed = False AND (LastStageChangeDate >= Yesterday OR CreatedDate >= Yesterday)'; //can be changed to CreatedDate = This_year) limit 5; for testing porpuses;
        system.debug('Batch_CalculateHandoverThresholds query: '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Handover_ThresholdMapping.linkOppsToThresholds(scope, true);
        oppsUpdated += scope.size();
    }

    public void finish(Database.BatchableContext BC){
        system.debug('Batch_CalculateHandoverThresholds Finished. # of Opps Updated: '+oppsUpdated);
    }
}