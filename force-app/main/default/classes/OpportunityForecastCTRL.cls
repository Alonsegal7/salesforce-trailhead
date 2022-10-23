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
     Opportunity opp = [select id,account.active_contract__c,Expected_Quote_Type__c,Expected_Plan_Tier__c,account.plan_tier__c,Prior_ARR__c, USD_exchange_rate__c,SyncedQuoteID, CurrencyIsoCode, Pricing_Version__c, DH_Expected_Plan_Tier__c, name from Opportunity where id =: oppId];
     return opp;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
    }
   }

   
   @AuraEnabled
   public static list<quotelineitem> insertForecastQuote(Id oppId, string productsData,string tier, string contractType){
    try {
        string conType = contractType=='Pro-rated'? 'Pro-rated- Additional Seats':contractType;
        Opportunity oppty = getOppDetails(oppId);
        Id currAccCon = oppty.account.active_contract__c;
        Map<String, Map<String,Object>> productsMap = parseProductResponse(productsData);
        List<String> relevantSKUs = new List<String>();
        Map<string, Contract_Product__c> conProdMap = new Map<string, Contract_Product__c>();

        for (String prod : productsMap.keySet()) {
            relevantSKUs.add((string)productsMap.get(prod).get('sku'));
        }
        relevantSKUs.add('ARR-BALANCE');

        if (conType=='Pro-rated- Additional Seats') {//is pro-rated, get curret contract to calculate added and total seats to qli
            for (contract_product__c conProd : getCurrentContractProduct(currAccCon)) {
                 conProdMap.put(conProd.SKU__c,conProd);
            }
        }

        Id standardPriceBookId = [SELECT Id FROM Pricebook2 WHERE Is_Main__c = true and isactive = true][0].Id;
        Quote quote = new Quote(
               
                name='Forecast Quote #' + string.valueof(Math.Random()).right(6),
                OpportunityId = oppty.Id,
                Document_Type__c = 'Forecast',
                Quote_Type__c = conType,
                DH_Tier__c = tier,
                Duration__c = 12,
                DH_Period__c = 'Yearly',
                USD_Exchange_Rate__c=oppty.USD_exchange_rate__c,
                CurrencyIsoCode = oppty.CurrencyIsoCode,
                Pricebook2Id = standardPriceBookId,
                Pricing_Version__c = oppty.Pricing_Version__c
            );

            try {
                Database.insert(quote);
            } catch (Exception ex) {
                Utilities.sendEmail('Forecast ARR update error!','Please go back to the opportunity  (Link: '+'https://monday.lightning.force.com/'+oppId+') and re-update the forecast. if you still having issues, please open a ticket at the business support board here -->  https://wkf.ms/3uWxgNX and show add this to the ticket:'+ex.getMessage() + '\n' + ex.getStackTraceString(),new list<String>{userinfo.getUserEmail(),'biztech@monday.com','alonse@monday.com'});   
            }


          Map<string, Id> mappedSkuCurrencyToPBE = new Map<string, Id>();
            for (PricebookEntry pbe : [SELECT Id, CurrencyIsoCode, ProductCode, Product2.Product_Identifier__c, Pricebook2Id FROM PricebookEntry WHERE Product2.Product_Identifier__c IN: relevantSKUs AND Pricebook2Id = :standardPriceBookId]) {
                if (!mappedSkuCurrencyToPBE.containsKey(pbe.Product2.Product_Identifier__c+pbe.CurrencyIsoCode)) {
                    mappedSkuCurrencyToPBE.put(pbe.Product2.Product_Identifier__c+pbe.CurrencyIsoCode,pbe.Id);
                }
            }

            List<QuoteLineItem> qlisToCreate = new List<QuoteLineItem>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();


            for (string prod : productsMap.keySet()) {
                Boolean conProdExist = isContractProductExist(string.valueof(productsMap.get(prod).get('sku')),conProdMap);
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
                    Added_Seats__c =Double.valueof(productsMap.get(prod).get('quantity')),
                    Seats__c = conProdExist==true ? Double.valueof(productsMap.get(prod).get('quantity')) + conProdMap.get(string.valueof(productsMap.get(prod).get('sku'))).quantity__c : Double.valueof(productsMap.get(prod).get('quantity')),
                    Subtotal__c=Double.valueof(productsMap.get(prod).get('quantity'))*12*( Double.valueof(productsMap.get(prod).get('netUnit'))),
                    DealHub_Net_Price__c=Double.valueof(productsMap.get(prod).get('quantity'))*12*( Double.valueof(productsMap.get(prod).get('netUnit'))),
                    SKU__c=string.valueof(productsMap.get(prod).get('sku')),
                    Quantity=(Double.valueof(productsMap.get(prod).get('quantity')))*12));
            }

            if (oppty.prior_arr__c != null && conType!='Pro-rated- Additional Seats') {
                //add Current Account ARR as QLI with negative ammount - contract arr
                qlisToCreate.add(new QuoteLineItem(
                    QuoteId=quote.Id,
                    Is_Primary__c=true,
                    Tier__c=tier,
                    PricebookEntryId=mappedSkuCurrencyToPBE.get('ARR-BALANCE'+oppty.CurrencyIsoCode),
                    UnitPrice=0,
                    ARR__c=(oppty.prior_arr__c*(-1)),
                    Quantity=1));
            }
            
            if (!qlisToCreate.isempty()) {
                try {
                    insert qlisToCreate;
                } catch (Exception ex) {
                    Utilities.sendEmail('Forecast ARR update error!','Please go back to the opportunity  (Link: '+'https://monday.lightning.force.com/'+oppId+') and re-update the forecast. if you still having issues, please open a ticket at the business support board here -->  https://wkf.ms/3uWxgNX and show add this to the ticket:'+ex.getMessage() + '\n' + ex.getStackTraceString(),new list<String>{userinfo.getUserEmail(),'biztech@monday.com','alonse@monday.com'});   

                }
            }

            oppsToUpdate.add(new opportunity(id=oppty.Id,SyncedQuoteId=quote.Id,Expected_Quote_Type__c=contractType));

            if (!oppsToUpdate.isempty()) {
                System.enqueueJob(new updateOppQueueable(oppsToUpdate)); 
            }

            return qlisToCreate;
        } catch (Exception e) {
            Utilities.sendSlackMessage('Forecast was not created!! check, update, and fix (Opp Id:'+oppId+'', 'biz-tech-monitoring', null , null, null, 'exception: ' + e.getMessage() + '\n' + e.getStackTraceString() + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), null);
            Utilities.sendEmail('Forecast ARR update error!','Please go back to the opportunity  (Link: '+'https://monday.lightning.force.com/'+oppId+') and re-update the forecast. if you still having issues, please open a ticket at the business support board here -->  https://wkf.ms/3uWxgNX and show add this to the ticket:'+e.getMessage() + '\n' + e.getStackTraceString(),new list<String>{userinfo.getUserEmail(),'biztech@monday.com','alonse@monday.com'}); 
            return null;
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
   List<quotelineitem> qlis = [select Product_Identifier_SKU__c,quote.DH_Tier__c, Added_Seats__c,Tier__c,Net_Per_Unit__c,Seats__c,Discount,DealHub_Net_Price__c,List_Price__c,CurrencyIsoCode from quotelineitem where quoteid =: quoteId];
    return qlis;
   }

   @AuraEnabled
   public static List<contract_product__c> getCurrentContractProduct(Id contractId){
   List<contract_product__c> contProducts = [select SKU__c,Quantity__c, Net_Per_Unit__c ,List_Per_Unit__c,CurrencyIsoCode,Discount__c from contract_product__c where Recurring_Product_ARR__c>0 and contract__c =: contractId];
   return contProducts;
   }

   public static Boolean isContractProductExist(string sku, Map<string, Contract_Product__c> cprodMap){
       if (cprodMap.get(sku)!=null) {
           return true;
       }
       return false;
   }

   @AuraEnabled
   public static void removeLineItemsAndQuotes(Id oppty, Id syncedQuote){//first step for currency change

        List<OpportunityLineItem> olis = [select id , quote_line_item__c, quote_line_item__r.QuoteId from OpportunityLineItem where opportunityId =: oppty];
        List<Quote> quoteToDel = [select id ,Document_Type__c from quote where OpportunityId =: oppty and Document_Type__c='Forecast'];
        
        
        try {
        if (!quoteToDel.isempty()) {//only if found forecast type quotes, run delition
            delete quoteToDel;
            if (!olis.isempty()) {
                delete olis;
            }
        }


        } catch (Exception ex) {
            if(ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW')){
                try {
                    delete quoteToDel;
                    delete olis;
                }
                catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                }
            }
            else {
                System.debug('Message: ' + ex.getMessage());
            }
        }
    }

    private class updateOppQueueable implements System.Queueable {
        private List<Opportunity> oppsToUpdateList; 
        public updateOppQueueable(List<Opportunity> oppsToUpdateList) {
            this.oppsToUpdateList = oppsToUpdateList;
        }
        public void execute(System.QueueableContext ctx) {
            Utilities.updateAndRetry(oppsToUpdateList);
        }
    }
}