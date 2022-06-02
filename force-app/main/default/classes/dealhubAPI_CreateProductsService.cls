public with sharing class dealhubAPI_CreateProductsService {

    @AuraEnabled
    public static void createProductsForSOR(Id sor, string productsData){
        try{
        List<Partner_SO_Request_Product__c> productsSorToCreate = new List<Partner_SO_Request_Product__c>();
        for (Object product : parseProductResponce(productsData)) {
            Map<String,Object> singleProd = (Map<String,Object> )product;
            productsSorToCreate.add(new Partner_SO_Request_Product__c(
                name=(string)singleProd.get('productName'),
                Partner_SO_Request__c=sor,
                Product_Code__c=(string)singleProd.get('sku'),
                Quantity__c=Double.valueof(singleProd.get('quantity')),
                Discount__c=Double.valueof(singleProd.get('discount')),
                List_Price__c=Double.valueof(singleProd.get('price')),
                Net_Per_Unit__c=Double.valueof(singleProd.get('netUnit')),
                Net_Total__c= Double.valueof(singleProd.get('total')),
                Original_List_Price__c=Double.valueof(singleProd.get('originalListPrice')),
                CurrencyIsoCode = String.valueof(singleProd.get('crrncy'))
            ));
        }
        if (!productsSorToCreate.isempty()) {
            insert productsSorToCreate;
        }
    }catch(Exception e){
        Utilities.sendDebugEmail('Error in createProductsForSOR ', e, e.getMessage());   
    }
}
    public static List<Object> parseProductResponce(string productsData){
        List<Object> prodDataList = new List<Object>();
        prodDataList = (List<Object>)JSON.deserializeUntyped(productsData);

        return prodDataList;
    }
}
