public without sharing class Exchange_Rate_Daily_Update implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public map<string,exchangerate__c> erByName= new map<string,exchangerate__c>();
    public Integer num=0;
    public String missingERs='';
    public map<id,Opportunity> allOppsToUpdate= new map<id,Opportunity>();

    public Exchange_Rate_Daily_Update() {
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this,20);
    }
    public Database.querylocator start(Database.BatchableContext BC){
        for (exchangeRate__c er: [select id,Currency__c,CurrencyIsoCode,Rate__c,Date__c 
                                    from ExchangeRate__c where Date__c=yesterday]){
            if(!erByName.containsKey(er.Currency__c))
                erByName.put(er.Currency__c,er);                        
        }
        system.debug('Raz Ben Ron CERDU erByName: '+erByName);  
        String query='select Id,USD_exchange_rate__c,CurrencyIsoCode ';
        query+='from Opportunity WHERE isClosed=false and CurrencyIsoCode!=\'USD\' ';      
        return Database.getQueryLocator(query);  
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        list<Opportunity> oppsToUpdate= new list<Opportunity>();
        for(Opportunity opp: scope){
            system.debug('Raz Ben Ron CERDU opp.CurrencyIsoCode: '+opp.CurrencyIsoCode);  
            if(erByName.containsKey(opp.CurrencyIsoCode)){
                if((opp.USD_exchange_rate__c==null)||
                    (opp.USD_exchange_rate__c!=null&&opp.USD_exchange_rate__c!=erByName.get(opp.CurrencyIsoCode).Rate__c)){
                    opp.USD_exchange_rate__c=erByName.get(opp.CurrencyIsoCode).Rate__c;
                    allOppsToUpdate.put(opp.Id,opp);
                    oppsToUpdate.add(opp);
                }
            }else if(!missingERs.contains(opp.CurrencyIsoCode)){
                missingERs+=opp.CurrencyIsoCode+'; ';
            }
        }
        num+=1;
        update oppsToUpdate;
    }
    public void finish(Database.BatchableContext bc) {
        if(missingERs!='')
            Utilities.sendEmail('Exchange Rate is Missing in Exchange_Rate_Daily_Update','Missing ERs: '+missingERs,new list<String>{label.SystemNotificationsDL});   
        system.debug('Raz Ben Ron ERDU # of batchs: '+num);
        system.debug('Raz Ben Ron ERDU # of opportunities updated: '+allOppsToUpdate.values().size());
        Utilities.sendEmail('Finished Exchange_Rate_Daily_Update Batch','# of opportunities updated: '+allOppsToUpdate.values().size()+' : '+allOppsToUpdate.keySet(),new list<String>{label.SystemNotificationsDL});   
    }
}