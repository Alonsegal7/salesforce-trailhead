public with sharing class dealhub_parse_pricing_res {
        public List<sku> skus = new list<sku> ();
        
        public class sku {
        public string sku {get;set;}
        public Decimal id {get;set;}
        public Decimal price {get;set;}
        public string error  {get;set;}
        public string productName {get;set;}
        public string productShortName {get; set;}
        public string tier  {get;set;}
        public string productCharacter {get;set;}
    }
    public static dealhub_parse_pricing_res parse(String json) {
        return (dealhub_parse_pricing_res) System.JSON.deserialize(json, dealhub_parse_pricing_res.class);
    }
}