public class Batch_UpdateSalesTargets implements Database.Batchable<sObject> {
    
    public static Boolean firstRun = true;
    private Set<Id> salesIds;
    private Map<String,Id> targetsMap;
    
    public Batch_UpdateSalesTargets(Set<Id> salesIds, Map<String,Id> targetsMap) {
        this.salesIds = salesIds;
        this.targetsMap = targetsMap;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select Id, Owner__c, RecordTypeId, Owner_s_Manager__c, Close_Date__c from Sale__c where Id IN: salesIds';
        return Database.getQueryLocator(query);
     }

    public void execute(Database.BatchableContext BC, list<Sale__c> scope){
        TargetsService helper = new TargetsService();
        Id partnerSaleRtId = Schema.SObjectType.Sale__c.getRecordTypeInfosByDeveloperName().get('Partner_Sale').getRecordTypeId();
        List<Sale__c> salesToUpdate = new List<Sale__c>();
        String key = '';
        for(Sale__c sale: scope){
            //target
            if(sale.RecordTypeId == partnerSaleRtId && sale.Owner_s_Manager__c != null){
                key = helper.getUniqueueKey(sale.Owner_s_Manager__c, sale.Close_Date__c);
            } else {
                key = helper.getUniqueueKey(sale.Owner__c, sale.Close_Date__c);
            }
            if(targetsMap.containsKey(key)){
                salesToUpdate.add(new Sale__c(Id = sale.Id, Target__c = targetsMap.get(key)));
            }
        }
        if(!salesToUpdate.isEmpty()){
            Database.update(salesToUpdate);    
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}

