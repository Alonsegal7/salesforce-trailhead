@istest
public with sharing class dealhub_Product_Pricing_Service_test {
    @istest

    public static void runTest(){
        string tier = 'Pro';
        string pricingVersion = 'V9';
        string crncy = 'USD';
        list<string> skusList = new list<string>{'CRM-PRO','CORE-PRO'};

        test.startTest();
        string res = dealhub_Product_Pricing_Service.getPricesFromDealhub(tier, crncy,pricingVersion,skusList);
        test.stopTest();


    }
}
