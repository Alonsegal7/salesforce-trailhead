public with sharing class Batch_UpdateCommitmentsReport implements Database.Batchable<sObject>{
    List<Commission_Report__c> reportsList;
    Map<String,Id> reportNumberToReportIdMap = new Map<String,Id>();
    
    public Batch_UpdateCommitmentsReport(List<Commission_Report__c> reportsList){
        this.reportsList = reportsList;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            for(Commission_Report__c report: reportsList){
                reportNumberToReportIdMap.put(report.Big_Brain_Id__c, report.Id);
            }   
            Set<String> bigBrainIds = reportNumberToReportIdMap.keySet();  
            String query = 'select Id, Report_Id__c from Commission_Commitment__c where report_id__c IN: bigBrainIds';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Batch_UpdateCommitmentsReport start:',e.getMessage()+ ' ' + e.getStackTraceString(),new list<string>{'kseniasm@monday.com'});   
            return null;
        }
    }

    public void execute(Database.BatchableContext BC, list<Commission_Commitment__c> scope){
        try{
            Map<Id,Commission_Commitment__c> commitmentsMap = new Map<Id,Commission_Commitment__c>(scope);
            for(Commission_Commitment__c commitment: commitmentsMap.values()){
                commitment.Commission_Report__c = reportNumberToReportIdMap.get(commitment.report_id__c);
            }
            Database.update(commitmentsMap.values());
        }catch(Exception e){
            Utilities.sendEmail('Error in Batch_UpdateCommitmentsReport execute:',e.getMessage()+ ' ' + e.getStackTraceString(),new list<string>{'kseniasm@monday.com'});   
        }
    }
    
    public void finish(Database.BatchableContext BC){
        Batch_UpdateHiddenCommitments updateHiddenCommitmentsBatch = new Batch_UpdateHiddenCommitments(reportsList);
        Utilities.cleanFlexQueue();
        Database.executeBatch(updateHiddenCommitmentsBatch, 100);
    }
}