public with sharing class dealhub_ProductParameters {
    public List<Skus> skus {get;set;}

    public class Skus {
        public String sku {get;set;}
        public Parameters_for parameters_for {get;set;}
    }
    public class Parameters_for {
        public List<Product_factors> product_factors {get;set;}
        public List<Product_factors> parameters {get;set;}
    }
    public class Product_factors {
        public String name {get;set;}
        public String type {get;set;}
    }

    public class JsonHeader{
        public string currencyIsoCode {get;set;}
        public string geo {get;set;}
        public list<string> skus {get;set;}
    }
    
    public static dealhub_ProductParameters parse(String json) {
        return (dealhub_ProductParameters) System.JSON.deserialize(json, dealhub_ProductParameters.class);
    }
}