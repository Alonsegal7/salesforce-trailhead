public with sharing class dealhub_PricingParameters {
    public class Skus {
        public string id{get;set;}
        public String sku {get;set;}
        public List<PricingParameter> parameters = new list<PricingParameter>();
    }
    public class PricingParameter {
        public String name {get;set;}
        public object value {get;set;}
    }
    public class JsonHeader{
        public string currencyIsoCode {get;set;}
        public string geo {get;set;}
        public list<skus> skus = new list<skus>();
    }
}