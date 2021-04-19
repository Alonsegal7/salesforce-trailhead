public class OpportunityHelper {
	public static void beforeUpdate(List<Opportunity> opportunities, map <Id, Opportunity> oldMap){
        for(Opportunity opp : opportunities){
            Opportunity oldOpp = oldMap.get(opp.Id);
            
            if (oldOpp != null && oldOpp.AccountId != opp.AccountId) { handleAccountIdChange(opp); }
            if (oldOpp != null && (oldOpp.CurrencyIsoCode != opp.CurrencyIsoCode || opp.USD_exchange_rate__c == null)) { ExchangeRateService.apply(opp); }
            
            if(isManagedByDealhub(opp)){
                opp.Expected_ARR__c = opp.Quote_ARR__c;
                if(opp.Is_Syncing_SO__c) { opp.Claimed_ARR__c = opp.Product_ARR__c; }
            }
        }
    }
    
    public static boolean isManagedByDealhub(Opportunity opp){
        return (opp.Quote_Count__c != null && opp.Quote_Count__c != 0) || (opp.Product_Count__c != null && opp.Product_Count__c != 0);
    }
    
    public static void afterUpdate(List<Opportunity> opps){
        Set<Id> SignedQuotes = new Set<Id>();
        for(Opportunity opp : opps){ if (opp.Is_SO_Signed__c) { SignedQuotes.add(opp.SyncedQuoteId); } }
        MarkQuotesSigned(SignedQuotes);
    }
    
    public static void MarkQuotesSigned(Set<Id> quoteIds){
        if(quoteIds.size() > 0){
            List<Quote> quotesList = [SELECT Id, Is_Manually_Signed__c FROM Quote WHERE Id = :quoteIds AND Is_Manually_Signed__c = false for update];
            for(Quote q :quotesList) { q.Is_Manually_Signed__c = true; }
            if ( !quotesList.isEmpty() ) { update quotesList; }
        }
    }
    
    public static void beforeInsert(List<Opportunity> opportunities) {
        for(Opportunity opp : opportunities) { ExchangeRateService.apply(opp); }
    }

    public static void handleAccountIdChange(Opportunity opportunity){
		if (opportunity.AccountId == null) { return; } 
                
        Account account = [SELECT Id, RecordTypeId, Company__c FROM Account WHERE Id=:opportunity.AccountId LIMIT 1];
        String recordTypeDevName = RecordTypeHelper.devName(account.recordTypeID);
        
        if (recordTypeDevName == 'Company') {
			opportunity.Company__c = account.Id;
			opportunity.Monday_Account__c = null;
        } else if (recordTypeDevName == 'Monday_Account') {
        	opportunity.Company__c = account.Company__c;
            opportunity.Monday_Account__c = account.Id;
        }
    }
}