public without sharing class Account_MapRegions {
    
    public static map<string,Country_Region_Mapping__c> regionsMapping {
        get {
            if (regionsMapping == null) {
                regionsMapping = Utilities.getRegionMapping();
            }
            return regionsMapping;
        }
        set;
    }

    public static void Account_MapRegions(List<Account> newAccounts, map<Id,Account> oldAccounts) {
        try{
            for(Account acc: newAccounts){
                string region='';
                string subRegion='';
                if(acc.BillingCountryCode != null && //prerequisites
                    (oldAccounts == null ||//new account
                    (acc.Manual_Trigger__c=='Match Regions')||//manual
                    (oldAccounts != null && acc.BillingCountryCode != oldAccounts.get(acc.Id).BillingCountryCode))) {//country change
                        region = subRegion = '';
                        if(regionsMapping.containskey(acc.BillingCountryCode)){
                            region = regionsMapping.get(acc.BillingCountryCode).Region__c;
                            subRegion = regionsMapping.get(acc.BillingCountryCode).Sub_Region__c;
                        }
                        if (acc.Region__c == null || (oldAccounts != null && acc.BillingCountryCode != oldAccounts.get(acc.Id).BillingCountryCode)) { //allows manual region setting, e.g. regional company created with region but w/o country, in this case the region shouldn't be deleted
                            acc.Region__c = region; 
                        }
                        acc.Sub_Region__c = subRegion;
                        if (acc.Manual_Trigger__c == 'Match Regions') acc.Manual_Trigger__c = '';
                  }
                }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_MapRegions ',e,e.getMessage());   
        }

    }
}