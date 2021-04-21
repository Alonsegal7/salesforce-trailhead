public class ExchangeRateService {
// map<String, Double> rates = loadExchangeRates();
// 
    public static void apply(Opportunity opportunity) {
        String currencyCode = opportunity.CurrencyIsoCode;
        DateTime d = opportunity.CreatedDate;
        if (d== null) d = Datetime.now();
        if (currencyCode == null) return;
        
        String key = currencyCode + '|' + d.year() + '|' + d.month() + '|' + d.day();
       
        Double rate = (Double) Cache.Org.get(ExchangeRateCache.class, key);
        
        if (rate == -1.0) rate = null;
        
        opportunity.USD_exchange_rate__c = rate;
    }
    
    /* public static void setExchangeRate(Opportunity opp, map<String, Double> rates){
        if(opp.Currency__c == null || opp.Currency__c == 'USD'){
            opp.USD_exchange_rate__c = 1;
        }
        else if(opp.Currency__c != null){
            opp.USD_exchange_rate__c = rates.get(opp.Currency__c);
        }
    }
    
    private static map<String, Double> loadExchangeRates(){
        list<aggregateResult> aggResults = [select max(Date__c) lastDate from ExchangeRate__c];
        Date d = Date.Valueof(aggResults[0].get('lastDate'));
        
        map<String, Double> ratesMap = new map<String, Double>();
        for(ExchangeRate__c r : [SELECT Currency__c, Rate__c FROM ExchangeRate__c WHERE Date__c = :d]){
            ratesMap.put(r.Currency__c, r.Rate__c);
        }
        return ratesMap;
    } */
}