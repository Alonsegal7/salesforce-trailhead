public without sharing class Batch_UpdatePartnerCollectionsHidden implements Database.Batchable<sObject>,Schedulable{
    
    public Set<Id> collectionsToSetHidden;
    
    public Batch_UpdatePartnerCollectionsHidden(Set<Id> collectionsToSetHidden){
        this.collectionsToSetHidden = collectionsToSetHidden;
    }
    
    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this,30);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_UpdatePartnerCollectionsHidden ', e, e.getMessage());   
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select Id from Commission_Collection__c where Id in: collectionsToSetHidden';
        return Database.getQueryLocator(query);
     }

    public void execute(Database.BatchableContext BC, list<Commission_Collection__c> scope){
        list<Commission_Collection__c> collectionsToUpdate = new list<Commission_Collection__c>();
        for(Commission_Collection__c collection: scope){
            collectionsToUpdate.add(new Commission_Collection__c(Id = collection.Id, Is_Hidden__c = true));
        }
        Database.update(collectionsToUpdate);
    }
    
    public void finish(Database.BatchableContext BC){
    }
}