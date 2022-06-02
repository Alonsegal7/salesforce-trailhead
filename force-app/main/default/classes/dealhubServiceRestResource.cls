@RestResource(urlMapping='/dealhubPricingServiceRestResource') 
global with sharing class dealhubServiceRestResource {
    @HttpPost
    global static string GetDealhubPricing(string tier,string crrncyCode, string pricingVersion, string sku){//todo handle list of skus
        List<string> mySkusList = new List<string>();
        mySkusList.add(sku);
        return dealhub_Product_Pricing_Service.getPricesFromDealhub(tier,crrncyCode,pricingVersion,mySkusList);
    }
}

