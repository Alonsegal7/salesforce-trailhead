public with sharing class dealhub_Product_Pricing_Service {
   
    public static Map<string, Object> globalVars = new Map<string, Object>();
    public static Map<string, product2> skusProductsMap = new Map<string, product2>();
    @AuraEnabled
    public static string getPricesFromDealhub(string tier, string crrncyCode, string pricingVersion, list<string> skusList){
        List<string> sku_list = setSkuList(skusList);//handle sku list and map product object 
        string productsParamsReq = getProductsParameters(tier, crrncyCode,  pricingVersion, sku_list);//send 1st req to dealhub
        System.debug('Parameters 1st req '+productsParamsReq );
        string getRawPrices = getProdutsPricing(productsParamsReq);//send 2nd req to dealhub - get prices
        string pricingObject = buildPricingObject(getRawPrices);//set and build response object
        System.debug('final object '+pricingObject );
        return pricingObject;
    }
    
    public static string getProductsParameters(string tier, string crrncyCode, string pricingVersion, list<string> skusList) {
        string body;
        string bodyBeforeReplace;
        globalVars.put('currency',crrncyCode);
        globalVars.put('pricing_version',pricingVersion);
        globalVars.put('tier',tier);
        globalVars.put('ENT','Enterprise');
        globalVars.put('PRO','Pro');
        globalVars.put('STD','Standard');
        dealhub_ProductParameters.JsonHeader paramHeaderReq = new dealhub_ProductParameters.JsonHeader();
        paramHeaderReq.currencyIsoCode = crrncyCode;
        paramHeaderReq.geo = 'US';
        paramHeaderReq.skus=skusList;
        bodyBeforeReplace = JSON.serialize(paramHeaderReq);
        body = bodyBeforeReplace.replace('"currencyIsoCode":', '"currency":');
        return sendRequest('https://api-us1.dealhub.io/api/v1/products/parameters','POST',body);
    }

    public static string getProdutsPricing(string parameterReqJson){
        dealhub_PricingParameters.JsonHeader pricingHeaderReq = new dealhub_PricingParameters.JsonHeader();
        string body;
        string bodyBeforeReplace;
        Integer counter = 1;
        pricingHeaderReq.currencyIsoCode = (string)globalVars.get('currency');
        pricingHeaderReq.geo = 'US';
        dealhub_ProductParameters productParamsResponse = dealhub_ProductParameters.parse(parameterReqJson);
        for (dealhub_ProductParameters.Skus currentSku : productParamsResponse.Skus) {
            dealhub_PricingParameters.Skus productSku = new dealhub_PricingParameters.Skus();
            productSku.id=string.valueof(counter);
            productSku.sku=currentSku.sku;
            counter++;
            //define params
            for (dealhub_ProductParameters.Product_factors parameter : currentSku.parameters_for.parameters) {
                if (parameter.name == 'GQ1.Version') {
                    dealhub_PricingParameters.PricingParameter pricingParam = new dealhub_PricingParameters.PricingParameter();
                    
                    pricingParam.name='GQ1.Version';
                    pricingParam.value=globalVars.get('pricing_version');
                    productSku.parameters.add(pricingParam);
                }
                if (parameter.name == 'GQ1.Quote_Currency') {
                    dealhub_PricingParameters.PricingParameter pricingParam = new dealhub_PricingParameters.PricingParameter();
                    pricingParam.name='GQ1.Quote_Currency';
                    pricingParam.value=globalVars.get('currency');
                    productSku.parameters.add(pricingParam);
                    
                }
                if (parameter.name == 'product.Option_Contract_Type') {
                    dealhub_PricingParameters.PricingParameter pricingParam = new dealhub_PricingParameters.PricingParameter();
                    pricingParam.name='product.Option_Contract_Type';
                    pricingParam.value='New Contract';
                    productSku.parameters.add(pricingParam);
                    
                }
                if (parameter.name == 'Admin_Section.Quote_Tier') {
                    dealhub_PricingParameters.PricingParameter pricingParam = new dealhub_PricingParameters.PricingParameter();
                    pricingParam.name='Admin_Section.Quote_Tier';
                    pricingParam.value=globalVars.get(productSku.sku.right(3));
                    productSku.parameters.add(pricingParam);
                }
                if (parameter.name == 'Admin_Section.Assign_Pricing_Factor') {
                    dealhub_PricingParameters.PricingParameter pricingParam = new dealhub_PricingParameters.PricingParameter();
                    pricingParam.name='Admin_Section.Assign_Pricing_Factor';
                    pricingParam.value='true';
                    productSku.parameters.add(pricingParam);
                    
                }   
            }
            //define factors
            for (dealhub_ProductParameters.Product_factors factor : currentSku.parameters_for.product_factors) {
                if (factor.name=='Seats') {
                    dealhub_PricingParameters.PricingParameter pricingParam = new dealhub_PricingParameters.PricingParameter();
                    pricingParam.name='Seats';
                    pricingParam.value=1;
                    productSku.parameters.add(pricingParam);     
                }
                if (factor.name=='Duration') {
                    dealhub_PricingParameters.PricingParameter pricingParam = new dealhub_PricingParameters.PricingParameter();
                    pricingParam.name='Duration';
                    pricingParam.value=1;
                    productSku.parameters.add(pricingParam);
                }
            }
            pricingHeaderReq.skus.add(productSku);
        }
        bodyBeforeReplace = JSON.serialize(pricingHeaderReq);
        body = bodyBeforeReplace.replace('"currencyIsoCode":', '"currency":');
        return sendRequest('https://api-us1.dealhub.io/api/v1/products/pricing','POST',body);
    }

    public static string sendRequest(String url, String method, String body){
        string webhook_Key = [select id, Key__c from Webhook_Key__mdt where DeveloperName = 'dealhub_service_key' limit 1].Key__c;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setBody(body);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + webhook_Key);
        HttpResponse res = http.send(req);
        System.debug('Alonse dealhub pricing queueable res.getbody():'+res.getbody());
        return res.getbody();
    }

    public static list<string> setSkuList(list<string> skus){
        if (skus!=null && skus.size()>0) {//it means the request specified the sku list, just map product2
            for (product2 prod : [select id,Short_Product_Name__c, Subscription_main_tier__c,Product_Identifier__c,Product_Character__c, name from product2 where Product_Identifier__c in:skus AND isactive=true]) {
                skusProductsMap.put(prod.Product_Identifier__c,prod);
            }
        }
        else{//it means that this is a full sku request per currency
            List<Product2> productsQry =  [select id,Short_Product_Name__c, Subscription_main_tier__c,Product_Identifier__c,Product_Character__c, name from product2 where Subscription_main_tier__c!=null AND isactive=true];
            List<string> skusList = new List<string>();
            for (Product2 product : productsQry) {
                skusList.add(product.Product_Identifier__c);
                skusProductsMap.put(product.Product_Identifier__c,product);
            }
            return skusList;
        }
        return skus;
    }
    public static string buildPricingObject(string dealhubRes){//create a response object
        dealhub_parse_pricing_res pricingResponse = dealhub_parse_pricing_res.parse(dealhubRes);
        dealhub_parse_pricing_res wrrapedPricingResponse = new dealhub_parse_pricing_res();
        for (dealhub_parse_pricing_res.sku singleSku : pricingResponse.skus) {
            dealhub_parse_pricing_res.sku sku= new dealhub_parse_pricing_res.sku();
            sku.sku = singleSku.sku;
            sku.error = singleSku.error;
            sku.id = singleSku.id;
            sku.price = singleSku.price;
            sku.productName = skusProductsMap.get(singleSku.sku).Name; 
            sku.productShortName = skusProductsMap.get(singleSku.sku).Short_Product_Name__c;
            sku.tier=skusProductsMap.get(singleSku.sku).Subscription_main_tier__c;
            sku.productCharacter=skusProductsMap.get(singleSku.sku).Product_Character__c;
            wrrapedPricingResponse.skus.add(sku);
        }
        return JSON.serialize(wrrapedPricingResponse);
    }

}