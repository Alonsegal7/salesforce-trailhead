public class ExchangeRateCache implements Cache.CacheBuilder {
    public Object doLoad(String identifier) {
        String[] split = identifier.split('[|]');
		String requestedCurrency = split[0];
        String year = split[1];
        String month = split[2];
        String day = split[3];
        
        Object rate = ExchangeRateCache.get(requestedCurrency, year, month, day);
        // doLoad must never return null
        if (rate == null) return -1.0;
        
        return rate;
    }
    
    public static Object get(String requestedCurrency, String year, String month, String day) {
        if (requestedCurrency == 'USD') return 1;
        
        Date requestedDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
        
        List<aggregateResult> aggResults = [select max(Date__c) lastDate from ExchangeRate__c WHERE Currency__c = :requestedCurrency AND Date__c <= :requestedDate];
        
        if (aggResults[0].get('lastDate') == null) return null;
        Date latestAvailableDate = Date.Valueof(aggResults[0].get('lastDate'));
        
        ExchangeRate__c rate = [SELECT Id, Rate__c FROM ExchangeRate__c WHERE Currency__c = :requestedCurrency AND Date__c = :latestAvailableDate LIMIT 1];
        
        return rate.Rate__c;
    }
}