public with sharing class Batch_UpdateHiddenCollections implements Database.Batchable<sObject>{
    List<Commission_Report__c> reportsList;
    
    public Batch_UpdateHiddenCollections(List<Commission_Report__c> reportsList){
        this.reportsList = reportsList;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> reportIds = (new Map<Id,Commission_Report__c>(reportsList)).keySet();
        String query = 'select Id, Big_Brain_Id__c from Commission_Report__c where Id in: reportIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, list<Commission_Report__c> scope){
        Map<String,Id> reportNumberToReportIdMap = new Map<String,Id>();
        for(Commission_Report__c report: scope){
            reportNumberToReportIdMap.put(report.Big_Brain_Id__c, report.Id);
        }
        List<Commission_Collection__c> collections = [select Id, External_Source_ID__c, Commission_Report__r.Id, Monday_Account__c, Report_Id__c, Collection_Happened_At__c, Collection_Amount_USD__c, is_Fix__c from Commission_Collection__c where report_id__c IN: reportNumberToReportIdMap.keySet()];
        if(collections.isEmpty()) return;

        Set<Id> collectionsToSetHidden = new Set<Id>();
        Map<Id,Commission_Collection__c> collectionsMap = new Map<Id,Commission_Collection__c>(collections);
        Map<String,Commission_Collection__c> fixCollectionsMap = new Map<String,Commission_Collection__c>();
        for(Commission_Collection__c collection: collectionsMap.values()){
            String key = getCollectionUniqueKey(collection);
            if(fixCollectionsMap.containsKey(key)){
                Commission_Collection__c existingCollection = fixCollectionsMap.get(key);
                if(existingCollection.Collection_Amount_USD__c + collection.Collection_Amount_USD__c == 0 && existingCollection.is_Fix__c != collection.is_Fix__c){
                    collection.Is_Hidden__c = true;
                    fixCollectionsMap.get(key).Is_Hidden__c = true;
                }
            } else {
                fixCollectionsMap.put(key, collection);
            } 
        }
        Database.update(collectionsMap.values());
    }
    
    public void finish(Database.BatchableContext BC){
    }

    private static String getCollectionUniqueKey(Commission_Collection__c collection){
        Decimal absoluteAmount = collection.Collection_Amount_USD__c; //Total_Commission_USD__c
        if(absoluteAmount < 0) absoluteAmount = -absoluteAmount;
        return collection.Commission_Report__r.Id + String.valueOf(collection.Monday_Account__c) + String.valueOf(collection.Collection_Happened_At__c) + String.valueOf(absoluteAmount) + collection.External_Source_ID__c;
    }
}