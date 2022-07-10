public with sharing class dealhub_Product_Pricing_Service {
   
    public static boolean firstPostFired=false;
    public static Map<string, Object> globalVars = new Map<string, Object>();

    @AuraEnabled
    public static string getPricesFromDealhub(string tier, string crrncyCode, string pricingVersion, list<string> skusList){
        string productsParams = getProductsParameters(tier, crrncyCode,  pricingVersion, skusList);
        string getPrices = getProdutsPricing(productsParams);
        System.debug('getPrices'+getPrices );
        return getPrices;
    }
    
    public static string getProductsParameters(string tier, string crrncyCode, string pricingVersion, list<string> skusList) {
        string body;
        string bodyBeforeReplace;
        globalVars.put('currency',crrncyCode);
        globalVars.put('pricing_version',pricingVersion);
        globalVars.put('tier',tier);
        globalVars.put('firstPostFired',false);
        dealhub_ProductParameters.JsonHeader paramHeaderReq = new dealhub_ProductParameters.JsonHeader();
        paramHeaderReq.currencyIsoCode = crrncyCode;
        paramHeaderReq.geo = 'US';
        paramHeaderReq.skus=skusList;
        bodyBeforeReplace = JSON.serialize(paramHeaderReq);
        body = bodyBeforeReplace.replace('"currencyIsoCode":', '"currency":');
        return sendRequest('https://dealhub.valooto.com/api/v1/products/parameters','POST',body);
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
                if (parameter.name == 'product.plan') {
                    dealhub_PricingParameters.PricingParameter pricingParam = new dealhub_PricingParameters.PricingParameter();
                    pricingParam.name='product.plan';
                    pricingParam.value=globalVars.get('tier');
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
        return sendRequest('https://dealhub.valooto.com/api/v1/products/pricing','POST',body);
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
        if (!Test.isRunningTest()){
            HttpResponse res = http.send(req);
            System.debug('Alonse dealhub pricing queueable res.getbody():'+res.getbody());
            return res.getbody();
        }
        else {
            string res = '{"skus":[{"sku":"CRM-PRO","parameters_for":{"product_factors":[{"name":"Added Seats","type":"number"},{"name":"Seats","type":"number"},{"name":"Duration","type":"number"},{"name":"Hours","type":"number"}],"parameters":[{"name":"Contract.New_Tier","type":"text"},{"name":"product.plan","type":"text"},{"name":"Admin_Section.Contract_Quote_Currency_Diff","type":"text"},{"name":"product.Option_Contract_Type","type":"text"},{"name":"Contract.Get_Contract_Tier","type":"text"},{"name":"GQ1.Version","type":"text"},{"name":"Partner_SO_Details.Partner_Tier","type":"text"},{"name":"GQ1.Quote_Currency","type":"text"},{"name":"product.Plan_Period","type":"text"},{"name":"Partner_SO_Details.Partner_SO_Request__cPeriod__c","type":"text"}]}},{"sku":"CORE-PRO","parameters_for":{"product_factors":[{"name":"Added Seats","type":"number"},{"name":"Seats","type":"number"},{"name":"Duration","type":"number"},{"name":"Hours","type":"number"}],"parameters":[{"name":"Contract.New_Tier","type":"text"},{"name":"Admin_Section.Renewal_List_Price","type":"number"},{"name":"Admin_Section.Opp_Owner_is_Partner","type":"text"},{"name":"product.Option_Contract_Type","type":"text"},{"name":"Admin_Section.Owner_Business_Role_Initial","type":"text"},{"name":"product.Renewed_Contract_Base_Price","type":"text"},{"name":"Select_Rollout_Plan.Rollout_Plan__cNet_Price__c","type":"number"},{"name":"product.Plan_Period","type":"text"},{"name":"Admin_Section.Active_Contract_CORE_Tier","type":"text"},{"name":"product.plan","type":"text"},{"name":"Contract.Get_Contract_Tier","type":"text"},{"name":"Admin_Section.Contract_Quote_Currency_Diff","type":"text"},{"name":"Contract.Enterprise_Pricing_Trial_Change_Tiers","type":"text"},{"name":"GQ1.Version","type":"text"},{"name":"Partner_SO_Details.Partner_Tier","type":"text"},{"name":"Partner_SO_Details.Partner_SO_Request__cPeriod__c","type":"text"}]}}]}';
            return res;
        }
    }
}