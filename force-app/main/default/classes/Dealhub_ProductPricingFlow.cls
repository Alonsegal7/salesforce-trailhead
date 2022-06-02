public with sharing class Dealhub_ProductPricingFlow {
    public class FlowInputs {
        @InvocableVariable(label='SKUs List' description='The list of the SKUs which you want to get pricing for' required=true)        
        public List<string> skus;

        @InvocableVariable(label='Pricing Version' description='Pricing Version' required=true)        
        public string pricingVersion;

        @InvocableVariable(label='currencyIsoCode' description='currencyIsoCode' required=true)        
        public string currencyIsoCode;


        @InvocableVariable(label='tier' description='the main tier of the order' required=true)        
        public string tier;

    }
    public class FlowOutput{
        @InvocableVariable public String skusPricing;
        public FlowOutput(String returnSkuPricing) {this.skusPricing = returnSkuPricing;}
      }
      
    @InvocableMethod
    public static FlowOutput[] getPricesFromDealhub(list<FlowInputs> flowInputs){
        FlowOutput[] results = new List<FlowOutput>();

        list<string> skus = flowInputs[0].skus;
        string pv = flowInputs[0].pricingVersion;
        string crrncy = flowInputs[0].currencyIsoCode;
        string tier = flowInputs[0].tier;

        string productsParams = dealhub_Product_Pricing_Service.getProductsParameters(tier, crrncy,  pv, skus);
        string getPrices = dealhub_Product_Pricing_Service.getProdutsPricing(productsParams);
        System.debug('getPrices'+getPrices );

        results.add(new FlowOutput(getPrices));
        return results;
    }


}
