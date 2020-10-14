public with sharing class companyWorkspaceController {
    @AuraEnabled(cacheable=true)
    public static List<Location> getAccount(string accId) {
        List< Account> accs =  [Select Id, Name,Type, Industry, BillingAddress,BillingStreet,
                                    BillingCity, BillingCountry, BillingPostalCode,
                                    BillingState,Phone 
                                from Account where BillingCountry!=NULL and Company__c=:accId] ;
        System.debug('Account location, accounts list from controller: '+accs);
        List<Location> loc = new List<Location>();
        for(Account acc :accs){
            GeoLocation geoInfo = new GeoLocation();
            geoInfo.Street = acc.BillingStreet;
            geoInfo.PostalCode = acc.BillingPostalCode;
            geoInfo.City = acc.BillingCity;
            geoInfo.State = acc.BillingState;
            geoInfo.Country = acc.BillingCountry;
            Location locDetail = new Location();
            locDetail.icon = 'action:map'; 
            locDetail.title = acc.Name;
            locDetail.description = acc.Name;
            locDetail.location = geoInfo;
            
            loc.add(locDetail);
        }
        return loc ;
    }
    public class Location{
        @AuraEnabled 
        public String icon{get;set;} 
        @AuraEnabled 
        public String title{get;set;} 
        @AuraEnabled
        public String description{get;set;} 
        @AuraEnabled 
        public GeoLocation location{get;set;} 
    }
    public class GeoLocation{
        @AuraEnabled 
        public String Street{get;set;}
        @AuraEnabled 
        public String PostalCode{get;set;}
        @AuraEnabled 
        public String City{get;set;}
        @AuraEnabled 
        public String State{get;set;}
        @AuraEnabled 
        public String Country{get;set;}
    }
}