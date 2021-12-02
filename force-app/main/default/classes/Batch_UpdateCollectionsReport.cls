public with sharing class Batch_UpdateCollectionsReport implements Database.Batchable<sObject>{
    List<Commission_Report__c> reportsList;
    Map<String,Id> reportNumberToReportIdMap = new Map<String,Id>();
    
    public Batch_UpdateCollectionsReport(List<Commission_Report__c> reportsList){
        this.reportsList = reportsList;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            for(Commission_Report__c report: reportsList){
                reportNumberToReportIdMap.put(report.Big_Brain_Id__c, report.Id);
            }   
            Set<String> bigBrainIds = reportNumberToReportIdMap.keySet();  
            String query = 'select Id, Commission_Report__r.Id, Monday_Account__c, Report_Id__c, Collection_Happened_At__c, Collection_Amount_USD__c, is_Fix__c from Commission_Collection__c where report_id__c IN: bigBrainIds';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Batch_UpdateCollectionsReport start:',e.getMessage()+ ' ' + e.getStackTraceString(),new list<string>{'kseniasm@monday.com'});   
            return null;
        }
    }

    public void execute(Database.BatchableContext BC, list<Commission_Collection__c> scope){
        try{
            Map<Id,Commission_Collection__c> collectionsMap = new Map<Id,Commission_Collection__c>(scope);
            for(Commission_Collection__c collection: collectionsMap.values()){
                collection.Commission_Report__c = reportNumberToReportIdMap.get(collection.report_id__c);
            }
            Database.update(collectionsMap.values());
        }catch(Exception e){
            Utilities.sendEmail('Error in Batch_UpdateCollectionsReport execute:',e.getMessage()+ ' ' + e.getStackTraceString(),new list<string>{'kseniasm@monday.com'});   
        }
    }
    
    public void finish(Database.BatchableContext BC){
        Batch_UpdateHiddenCollections updateHiddenCollectionsBatch = new Batch_UpdateHiddenCollections(reportsList);
        Utilities.cleanFlexQueue();
        Database.executeBatch(updateHiddenCollectionsBatch, 100);
    }
}