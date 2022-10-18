@istest
public with sharing class dealhub_Product_Pricing_Service_test {

    @TestSetup
    static void makeData(){
        Product2 core1 = new product2(
            isactive=true,
            name='Enterprise Plan',
            Product_Character__c='Stand-Alone');

        Product2 core2 = new product2(
            isactive=true,
            name='Pro Plan',
            Product_Character__c='Stand-Alone');

        list<product2> prods = new list<product2>{core1,core2};
        insert prods;
    }
    @istest
    public static void GetPricingSuccessSpecificSkus(){
        string tier = 'Pro';
        string pricingVersion = 'V9';
        string crncy = 'USD';

        list<string> coreProductsToHandle = new list<string>{'CORE-PRO','CORE-ENT'};
        Test.setMock(HttpCalloutMock.class, new mockProductsParametersSuccess());

        Test.startTest();
        list<string> coreProducts = dealhub_Product_Pricing_Service.setSkuList(coreProductsToHandle);
        string getParams = dealhub_Product_Pricing_Service.getProductsParameters(tier,crncy,pricingVersion,coreProducts);
        Test.setMock(HttpCalloutMock.class, new mockProductsPricingSuccess());
        dealhub_parse_pricing_res pricingObject = dealhub_parse_pricing_res.parse(dealhub_Product_Pricing_Service.buildPricingObject(dealhub_Product_Pricing_Service.getProdutsPricing(getParams)));

        for (dealhub_parse_pricing_res.sku sku : pricingObject.skus) {
            system.assertNotEquals(null, sku.id);
            system.assertNotEquals(null, sku.price);
            system.assertNotEquals(null, sku.productCharacter);
            system.assertNotEquals(null, sku.productName);
            system.assertNotEquals(null, sku.productShortName);
            system.assertNotEquals(null, sku.sku);
        }
        Test.stopTest();
    }

    public class mockProductsParametersSuccess implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();

            dealhub_ProductParameters.Skus core = new dealhub_ProductParameters.Skus();
            core.sku='CORE-PRO';
            core.parameters_for = new dealhub_ProductParameters.Parameters_for();
            core.parameters_for.parameters = new list<dealhub_ProductParameters.Product_factors>();
            core.parameters_for.product_factors = new list<dealhub_ProductParameters.Product_factors>();

            dealhub_ProductParameters.Product_factors param_1 = new dealhub_ProductParameters.Product_factors();
            param_1.name='GQ1.Version';
            param_1.type='text';

            dealhub_ProductParameters.Product_factors param_2 = new dealhub_ProductParameters.Product_factors();
            param_2.name='GQ1.Quote_Currency';
            param_2.type='text';

            dealhub_ProductParameters.Product_factors param_3 = new dealhub_ProductParameters.Product_factors();
            param_3.name='product.Option_Contract_Type';
            param_3.type='text';

            dealhub_ProductParameters.Product_factors param_4 = new dealhub_ProductParameters.Product_factors();
            param_4.name='Admin_Section.Quote_Tier';
            param_4.type='text';

            dealhub_ProductParameters.Product_factors param_5 = new dealhub_ProductParameters.Product_factors();
            param_5.name='Admin_Section.Assign_Pricing_Factor';
            param_5.type='text';

            dealhub_ProductParameters.Product_factors factor_1 = new dealhub_ProductParameters.Product_factors();
            factor_1.name='Seats';
            factor_1.type='number';

            dealhub_ProductParameters.Product_factors factor_2 = new dealhub_ProductParameters.Product_factors();
            factor_2.name='Duration';
            factor_2.type='number';

            dealhub_ProductParameters.Product_factors factor_3 = new dealhub_ProductParameters.Product_factors();
            factor_3.name='Seats';
            factor_3.type='number';

            core.parameters_for.parameters.add(param_1);
            core.parameters_for.parameters.add(param_2);
            core.parameters_for.parameters.add(param_3);
            core.parameters_for.parameters.add(param_4);
            core.parameters_for.parameters.add(param_5);
            core.parameters_for.product_factors.add(factor_1);
            core.parameters_for.product_factors.add(factor_2);
            core.parameters_for.product_factors.add(factor_3);


            dealhub_ProductParameters.Skus core2 = new dealhub_ProductParameters.Skus();
            core2.sku='CORE-ENT';
            core2.parameters_for = new dealhub_ProductParameters.Parameters_for();
            core2.parameters_for.parameters = new list<dealhub_ProductParameters.Product_factors>();
            core2.parameters_for.product_factors = new list<dealhub_ProductParameters.Product_factors>();

            dealhub_ProductParameters.Product_factors param_1a = new dealhub_ProductParameters.Product_factors();
            param_1a.name='GQ1.Version';
            param_1a.type='text';

            dealhub_ProductParameters.Product_factors param_2a = new dealhub_ProductParameters.Product_factors();
            param_2a.name='GQ1.Quote_Currency';
            param_2a.type='text';

            dealhub_ProductParameters.Product_factors param_3a = new dealhub_ProductParameters.Product_factors();
            param_3a.name='product.Option_Contract_Type';
            param_3a.type='text';

            dealhub_ProductParameters.Product_factors param_4a = new dealhub_ProductParameters.Product_factors();
            param_4a.name='Admin_Section.Quote_Tier';
            param_4a.type='text';
            
            dealhub_ProductParameters.Product_factors param_5a = new dealhub_ProductParameters.Product_factors();
            param_5a.name='Admin_Section.Assign_Pricing_Factor';
            param_5a.type='text';

            dealhub_ProductParameters.Product_factors factor_1a = new dealhub_ProductParameters.Product_factors();
            factor_1a.name='Seats';
            factor_1a.type='number';

            dealhub_ProductParameters.Product_factors factor_2a = new dealhub_ProductParameters.Product_factors();
            factor_2a.name='Duration';
            factor_2a.type='number';

            dealhub_ProductParameters.Product_factors factor_3a = new dealhub_ProductParameters.Product_factors();
            factor_3a.name='Seats';
            factor_3a.type='number';

            core2.parameters_for.parameters.add(param_1a);
            core2.parameters_for.parameters.add(param_2a);
            core2.parameters_for.parameters.add(param_3a);
            core2.parameters_for.parameters.add(param_4a);
            core2.parameters_for.parameters.add(param_5a);
            core2.parameters_for.product_factors.add(factor_1a);
            core2.parameters_for.product_factors.add(factor_2a);
            core2.parameters_for.product_factors.add(factor_3a);

            dealhub_ProductParameters coreParams = new dealhub_ProductParameters();
            coreParams.skus = new list<dealhub_ProductParameters.Skus>{core,core2};

            String str = JSON.serialize(coreParams);
            res.setBody(str);
            res.setStatusCode(200);
            return res;
        }
    }

    public class mockProductsPricingSuccess implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();

            dealhub_parse_pricing_res.sku core1 = new dealhub_parse_pricing_res.sku();
            core1.sku='CORE-PRO';
            core1.id=1;
            core1.price=16;
            core1.productName='Core Pro';

            dealhub_parse_pricing_res.sku core2 = new dealhub_parse_pricing_res.sku();
            core2.sku='CORE-ENT';
            core2.id=2;
            core2.price=38;
            core2.productName='Core Enterprise';

            dealhub_parse_pricing_res priceRes = new dealhub_parse_pricing_res();
            priceRes.skus.add(core1);
            priceRes.skus.add(core2);

            String str = JSON.serialize(priceRes);
            res.setBody(str);
            res.setStatusCode(200);
            return res;

        }
    }
}