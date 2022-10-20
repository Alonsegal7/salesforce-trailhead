@istest
public with sharing class OpportunityForecastCTRL_Test {
    @TestSetup
    static void makeData(){

        Pricebook2 pb2 = TestObjectCreator.CreatePricebook();
        pb2.name='testpricebook';
        pb2.isactive=true;
        pb2.Is_Main__c=true;
        insert pb2;

        Product2 prod = TestObjectCreator.CreateProduct();
        insert prod;

        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 20,
            UseStandardPrice = false,
            IsActive = true
        );

        insert standardPBE;

        PricebookEntry cstmPBE2 = new PricebookEntry(
            Pricebook2Id = pb2.id,
            Product2Id = prod.Id,
            UnitPrice = 20,
            UseStandardPrice = false,
            IsActive = true
        );

        insert cstmPBE2;

        Account comp = TestObjectCreator.CreateCompany();
        insert comp;

        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        insert ma;

        Opportunity opp = TestObjectCreator.CreateOpp(ma);
        opp.USD_exchange_rate__c=1;
        insert opp;
    }

    @istest
    public static void testGetOpp(){
        Opportunity getOppData = [select id,USD_exchange_rate__c,CurrencyIsoCode,Pricing_Version__c,SyncedQuoteID from opportunity limit 1];
        Opportunity opp = OpportunityForecastCTRL.getOppDetails(getOppData.id);

        System.assertEquals(getOppData.Id, getOppData.Id);
        System.assertEquals(getOppData.CurrencyIsoCode,'USD');
        System.assertEquals(getOppData.SyncedQuoteID, null);
        System.assertEquals(getOppData.Pricing_Version__c, '8');

    }
    @istest
    public static void testGetProd(){
        list<product2> prodsPro = OpportunityForecastCTRL.getProductsByTier('Pro');
        list<product2> prodsEnt = OpportunityForecastCTRL.getProductsByTier('Enterprise');

        System.assertEquals(prodsPro.size(), 1);
        System.assertEquals(prodsEnt.size(), 0);
    }
    @istest

    public static void testCreateProds(){
        Opportunity opp = [select id,name,USD_exchange_rate__c,CurrencyIsoCode,Pricing_Version__c,SyncedQuoteID from opportunity limit 1];
        string data = '[{"sku":"CORE-PRO","id":1,"price":16,"error":"","productName":"Pro Plan","quantity":"20","discount":0,"total":3840,"crrncy":"USD","originalListPrice":16,"netUnit":16}]';

        list<quotelineitem> qlis = OpportunityForecastCTRL.insertForecastQuote(opp.id,data,'Pro','New Contract');
        System.assertEquals(qlis.size(), 1);
    }
    @istest

    public static void testRemoveOppliQuote(){
        Opportunity opp = [select id,name,USD_exchange_rate__c,CurrencyIsoCode,Pricing_Version__c,SyncedQuoteID from opportunity limit 1];
        string data = '[{"sku":"CORE-PRO","id":1,"price":16,"error":"","productName":"Pro Plan","quantity":"20","discount":0,"total":3840,"crrncy":"USD","originalListPrice":16,"netUnit":16}]';

        list<quotelineitem> qlis = OpportunityForecastCTRL.insertForecastQuote(opp.id,data,'Pro','New Contract');

        Opportunity syncedQuoteOpp = [select id,SyncedQuoteID from opportunity limit 1];

        System.assertEquals(qlis.size(), 1);
        OpportunityForecastCTRL.removeLineItemsAndQuotes(opp.id,syncedQuoteOpp.SyncedQuoteID);
        list<quotelineitem> deleteQlis = [select id from quotelineitem limit 1];
        System.assertEquals(deleteQlis.size(), 0);
    }
}