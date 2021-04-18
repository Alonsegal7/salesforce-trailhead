global class Batch_SyncQuote implements Database.Batchable<sObject>, Schedulable  {
  
  String query;
  List<Id> quotes;
  
  global Batch_SyncQuote(List<Id> pQuotes) {
    System.debug('$$$ quotes:' + pQuotes);
    query = 'SELECT Id FROM Quote WHERE Id IN: quotes AND IsSyncing = TRUE';
    quotes = pQuotes;
    System.debug(Database.getQueryLocator(query));

  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug('$$$ query: ' + query);
    return Database.getQueryLocator(query);
  }

     global void execute(Database.BatchableContext BC, List<sObject> scope) {
    List<Quote> quotes = (List<Quote>) scope;
    Set<Id> syncedQuotes = new Set<Id>();
    for (Quote q : quotes){
      syncedQuotes.add(q.Id);
    } 

    System.debug('$$$ syncedQuote: ' + syncedQuotes);

    List<LineItem_Sync__c> QLISync =   [SELECT Name, Opportunity_Line_Item_field__c 
                        FROM LineItem_Sync__c];
    if (QLISync == null || QLISync.size() == 0){
      return;
    }
    System.debug('$$$ QLISync: ' + QLISync);
    Map<String, String> fieldMapping = new Map<String, String>();

    for (LineItem_Sync__c s : QLISync){
      fieldMapping.put(s.Name, s.Opportunity_Line_Item_field__c);
    }

    String qliQuery = 'SELECT ';
    for (String f : fieldMapping.keySet()){
      qliQuery += f + ', ';
    }

    qliQuery += 'Product2Id, Quote.OpportunityId FROM QuoteLineItem WHERE QuoteId IN: syncedQuotes';

    System.debug('$$$ qliQuery: ' + qliQuery);
    List<QuoteLineItem> QLIs = Database.Query(qliQuery);

    if (QLIs == null || QLIs.size() == 0){
      return;
    }

    System.debug('$$$ QLIs: ' + QLIs);

    Set<Id> relatedProducts = new Set<Id>();
    Set<Id> opps = new Set<Id>();
    
    for (QuoteLineItem qli : QLIs){
      relatedProducts.add(qli.Product2Id);
      opps.add(qli.Quote.OpportunityId);
    }
    
    String oliQuery = 'SELECT ';

    for (String f : fieldMapping.values()){
      oliQuery += f + ', ';
    } 

    oliQuery += 'Product2Id, OpportunityId FROM OpportunityLineItem WHERE Product2Id IN: relatedProducts AND OpportunityId IN: opps';
    System.debug('$$$ oliQuery: ' + oliQuery);
    List<OpportunityLineItem> OLIs = Database.Query(oliQuery);
    //Map<Id,OpportunityLineItem> OLIsMap = new Map<Id, OpportunityLineItem>(OLIs);

    if (OLIs == null || OLIs.size() == 0){
      return;
    }
    System.debug('$$$ OLIs: ' + OLIs);

    Map<Id, OpportunityLineItem> QLIAndOLIMap = new Map<Id, OpportunityLineItem>();

    for (QuoteLineItem qli : QLIs){
      for (OpportunityLineItem oli : OLIs){
        if (qli.Quote.OpportunityId == oli.OpportunityId && qli.Product2Id == oli.Product2Id){
          QLIAndOLIMap.put(qli.Id, oli);
        }
      }
    }

    Map<Id, OpportunityLineItem> OLIsToUpdate = new Map<Id, OpportunityLineItem>();
    for (QuoteLineItem qli : QLIs){
      for (String s : fieldMapping.keySet() ){
        if (qli.get(s) != QLIAndOLIMap.get(qli.Id).get(fieldMapping.get(s))){
          QLIAndOLIMap.get(qli.Id).put(fieldMapping.get(s), qli.get(s));
          OLIsToUpdate.put(QLIAndOLIMap.get(qli.Id).Id, QLIAndOLIMap.get(qli.Id));
        }
      }
    }

    System.debug('$$$ OLIsToUpdate: ' + OLIsToUpdate);

    if (OLIsToUpdate.size() > 0){
      update OLIsToUpdate.values();
    }
  }
  
  global void finish(Database.BatchableContext BC) {
    List<CronTrigger> ct = [SELECT Id FROM CronTrigger
                            WHERE CronJobDetail.Name ='Batch_QuoteSync' AND State != 'DELETED'];
    if (!ct.isEmpty()){
      System.abortJob(ct[0].Id);
    }
  }
  
  global void execute(SchedulableContext SC) {
        Batch_SyncQuote b = new Batch_SyncQuote(quotes);
        database.executebatch(b);
    }
  
}