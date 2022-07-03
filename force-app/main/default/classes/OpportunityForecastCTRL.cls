public without sharing class OpportunityForecastCTRL {
    @AuraEnabled
    public static List<Product2> getProductsByTier(string tier) {
        try {
        List<Product2> prods = [select id,Short_Product_Name__c, Subscription_main_tier__c,Product_Identifier__c, name from product2 where Subscription_main_tier__c=:tier AND isactive=true];
        return prods;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
   }
   
   @AuraEnabled
   public static Opportunity getOppDetails(string oppId){
    try {
     Opportunity opp = [select id,Expected_Plan_Tier__c,account.plan_tier__c,Prior_ARR__c, USD_exchange_rate__c,SyncedQuoteID, CurrencyIsoCode, Pricing_Version__c, DH_Expected_Plan_Tier__c, name from Opportunity where id =: oppId];
     return opp;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
    }
   }
   
   @AuraEnabled
   public static list<quotelineitem> insertForecastQuote(Id oppId, string productsData,string tier){
    try {
        Opportunity oppty = getOppDetails(oppId);
        Map<String, Map<String,Object>> productsMap = parseProductResponse(productsData);
        List<String> relevantSKUs = new List<String>();

        for (String prod : productsMap.keySet()) {
            relevantSKUs.add((string)productsMap.get(prod).get('sku'));
        }
        relevantSKUs.add('ARR-BALANCE');

        Id standardPriceBookId = [SELECT Id FROM Pricebook2 WHERE Is_Main__c = true][0].Id;
        Quote quote = new Quote(
               
                name='Forecast Quote #' + string.valueof(Math.Random()).right(6),
                OpportunityId = oppty.Id,
                Document_Type__c = 'Forecast',
                Quote_Type__c = 'New Contract',
                DH_Tier__c = tier,
                Duration__c = 12,
                DH_Period__c = 'Yearly',
                USD_Exchange_Rate__c=oppty.USD_exchange_rate__c,
                CurrencyIsoCode = oppty.CurrencyIsoCode,
                Pricebook2Id = standardPriceBookId,
                Pricing_Version__c = oppty.Pricing_Version__c
            );

            Database.insert(quote);

          Map<string, Id> mappedSkuCurrencyToPBE = new Map<string, Id>();
            for (PricebookEntry pbe : [SELECT Id, CurrencyIsoCode, ProductCode, Product2.Product_Identifier__c, Pricebook2Id FROM PricebookEntry WHERE Product2.Product_Identifier__c IN: relevantSKUs AND Pricebook2Id = :standardPriceBookId]) {
                if (!mappedSkuCurrencyToPBE.containsKey(pbe.Product2.Product_Identifier__c+pbe.CurrencyIsoCode)) {
                    mappedSkuCurrencyToPBE.put(pbe.Product2.Product_Identifier__c+pbe.CurrencyIsoCode,pbe.Id);
                }
            }

            List<QuoteLineItem> qlisToCreate = new List<QuoteLineItem>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();


            for (string prod : productsMap.keySet()) {
               qlisToCreate.add(new QuoteLineItem(
                    QuoteId=quote.Id,
                    PricebookEntryId=mappedSkuCurrencyToPBE.get(productsMap.get(prod).get('sku') + (string)productsMap.get(prod).get('crrncy')),
                    UnitPrice=Double.valueof(productsMap.get(prod).get('netUnit')),
                    Net_Per_Unit__c=Double.valueof(productsMap.get(prod).get('netUnit')),
                    ARR__c=oppty.USD_exchange_rate__c * Double.valueof(productsMap.get(prod).get('quantity')) * Double.valueof(productsMap.get(prod).get('netUnit'))*12,
                    Is_Primary__c=true,
                    Tier__c=tier,
                    Plan_Period__c='Yearly',
                    Duration__c=12.0,
                    Discount=Double.valueof(productsMap.get(prod).get('discount')),
                    Product_Type__c='License',
                    List_Price__c=Double.valueof(productsMap.get(prod).get('price')),
                    Seats__c=Double.valueof(productsMap.get(prod).get('quantity')),
                    Subtotal__c=Double.valueof(productsMap.get(prod).get('quantity'))*12*( Double.valueof(productsMap.get(prod).get('netUnit'))),
                    DealHub_Net_Price__c=Double.valueof(productsMap.get(prod).get('quantity'))*12*( Double.valueof(productsMap.get(prod).get('netUnit'))),
                    Quantity=(Double.valueof(productsMap.get(prod).get('quantity')))*12));
            }

            if (oppty.prior_arr__c != null) {
                //add Current Account ARR as QLI with negative ammount - contract arr
                qlisToCreate.add(new QuoteLineItem(
                    QuoteId=quote.Id,
                    Is_Primary__c=true,
                    PricebookEntryId=mappedSkuCurrencyToPBE.get('ARR-BALANCE'+oppty.CurrencyIsoCode),
                    UnitPrice=0,
                    ARR__c=(oppty.prior_arr__c*(-1)),
                    Quantity=1));
            }
            
            if (!qlisToCreate.isempty()) {
                insert qlisToCreate;
            }

            oppsToUpdate.add(new opportunity(id=oppty.Id,
            SyncedQuoteId=quote.Id));

            if (!oppsToUpdate.isempty()) {
                update oppsToUpdate;
            }
            return qlisToCreate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

   }

    @AuraEnabled
    public static Map<String, Map<String,Object>> parseProductResponse(string productsData){//parse and model the products data
    List<Object> prodDataList = new List<Object>();
    prodDataList = (List<Object>)JSON.deserializeUntyped(productsData);
    Map<String, Map<String,Object>> productsMap = new Map<String, Map<String,Object>>();
    Map<String,Object> singleProd = new Map<String,Object>();
    for (Object product : prodDataList) {
        singleProd = (Map<String,Object> ) product;
        productsMap.put((string)singleProd.get('sku'),singleProd);
    }
    return productsMap;
   }

   @AuraEnabled
   public static List<quotelineitem> getCurrentQuoteLineItems(Id quoteId){
   List<quotelineitem> qlis = [select Product_Identifier_SKU__c, Tier__c,Net_Per_Unit__c,Seats__c,Discount,DealHub_Net_Price__c,List_Price__c,CurrencyIsoCode from quotelineitem where quoteid =: quoteId];
    return qlis;
   }

   @AuraEnabled
   public static List<contract_product__c> getCurrentContractProduct(Id contractId){
   List<contract_product__c> contProducts = [select SKU__c,Quantity__c, Net_Per_Unit__c ,List_Per_Unit__c,CurrencyIsoCode,Discount__c from contract_product__c where Recurring_Product_ARR__c>0 and contract__c =: contractId];
   return contProducts;
   }
}