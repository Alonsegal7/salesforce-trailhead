public with sharing class Renewal_Flat_CreateSalesOrder {
    
    //Function that gets a renewal opportunity and created a renewal SO
    @AuraEnabled(Cacheable=false)
    public static List<Quote> createRenewalSalesOrder(List <Id> renewalOppIds) {
    
        //1. Mark the renewal opportunity with Auto Renewal Status = Initiated, used for monitoring
        List<Opportunity>oppsToUpdateInit = new List<Opportunity>();
        for (Id oppId : renewalOppIds) {
            oppsToUpdateInit.add(new Opportunity(Id=oppId, Auto_Renewal_Status__c = 'Initiated'));
        }
        try {
            Database.SaveResult[] oppsToCreateSrList = Database.insert(oppsToUpdateInit, false);
            Utils.validateDmlOperationResults(oppsToCreateSrList, 'Renewal_Flat_CreateSalesOrder', 'createRenewalSalesOrder');
        } 
        catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            Utilities.sendDebugEmail('Error in Renewal SO Creation - Update Init part: ',e,e.getMessage());   
            Utilities.sendSlackMessage('Error in Renewal SO Creation - Update Init part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);      
            throw new AuraHandledException(e.getMessage());
        }
        
        //2. Create a renewal quote based on the opportunity "selected company contract" and related billing entity 
        //List of all opportunities that needs a renewal SO
        List <Opportunity> renewalOpps = [SELECT Name,Selected_Company_Contract__c,Billing_Entity__c,Pricing_Version__c, Payment_Terms__c FROM Opportunity WHERE Id IN :renewalOppIds];
        Id standardPriceBookId = [SELECT Id FROM Pricebook2 WHERE Is_Main__c = true][0].Id;
        System.debug('@@Renewal_Flat_CreateSalesOrder Renewal Pricebook: '+standardPriceBookId);

        //List of IDs for contracts and billing entities, used to create a map later
        List <Id> relevantContractIds = new List<Id>();
        List <Id> relevantBEIds = new List<Id>();
        for (Opportunity opp : renewalOpps) {
            relevantContractIds.add(opp.Selected_Company_Contract__c);
            relevantBEIds.add(opp.Billing_Entity__c);
        }

        //Map of all original contracts with their IDs  
        Map <Id, Contract> relevantContracts = new Map<Id,Contract>([SELECT Id,Tier__c,Contract_ARR__c,CurrencyIsoCode,EndDate FROM Contract WHERE id in: relevantContractIds]);
        //Map of all original contracts with the related opportunity ID  
        Map<Id, Contract> oppsWithContracts = new Map<Id, Contract>();
        for (Opportunity opp : renewalOpps) {
            oppsWithContracts.put(opp.Id,relevantContracts.get(opp.Selected_Company_Contract__c));
        }
        
        //Map of all original Billing Entities with their IDs  
        Map <Id, Billing_Entity__c> relevantBEs = new Map<Id, Billing_Entity__c>([SELECT Id,Name,Priority_Id__c FROM Billing_Entity__c WHERE id in: relevantBEIds]);
        //Map of all original Billing Entities with the related opportunity ID
        Map<Id, Billing_Entity__c> oppsWithBEs = new Map<Id, Billing_Entity__c>();
        for (Opportunity opp : renewalOpps) {
            oppsWithBEs.put(opp.Id,relevantBEs.get(opp.Billing_Entity__c));
        }
        System.debug('@@@Renewal_Flat_CreateSalesOrder Opps with BEs: '+oppsWithBEs);
        System.debug('@@@Renewal_Flat_CreateSalesOrder renewal Opps: '+renewalOpps);
        
        //Quote list to be inserted later
        List<Quote> quotesToCreate = new List<Quote>();
        for (Opportunity opp : renewalOpps) {
            //Define attributs for the new Quote based on the original Contract
            quotesToCreate.add(new Quote(
                OpportunityId = opp.Id,
                Billing_Entity__c = oppsWithBEs.get(opp.Id).Id,
                Status = 'Approved',
                DH_Quote_Status__c = 'Draft',
                Auto_Renewal__c = 'Yes',
                Document_Type__c = 'Sales Order',
                Quote_Type__c = 'New Contract',
                Quote_Source__c	 = 'Auto Renewal - Flat',
                DH_Tier__c = oppsWithContracts.get(opp.Id).Tier__c,
                Duration__c = 12,
                DH_Period__c = 'Yearly',
                Manual_Signature_Reason__c = 'Auto Renewal',
                Name = 'temp - '+ oppsWithBEs.get(opp.Id).Name,
                CurrencyIsoCode = oppsWithContracts.get(opp.Id).CurrencyIsoCode,
                Pricebook2Id = standardPriceBookId,
                Pricing_Version__c = opp.Pricing_Version__c,
                Payment_Terms__c = opp.Payment_Terms__c,
                Priority_Customer_ID_Text__c = oppsWithBEs.get(opp.Id).Priority_Id__c
                //QuoteToName = renewalBE.Name,
                //BillingAddress = renewalBE.Billing_Address__c,
                //BillingName = renewalBE.Name,
            ));
        }
        try {
            Database.SaveResult[] quotesToCreateSrList = Database.insert(quotesToCreate, false);
            Utils.validateDmlOperationResults(quotesToCreateSrList, 'Renewal_Flat_CreateSalesOrder', 'createSalesOrder');
        } 
        catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            Utilities.sendDebugEmail('Error in Renewal SO Creation - Quote Creation part: ',e,e.getMessage());   
            Utilities.sendSlackMessage('Error in Renewal SO Creation - Quote Creation part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);      
            throw new AuraHandledException(e.getMessage());
        }
     
        //3. Create QLIs based on the contract products related to the original contract
                
        Map<Id, Quote> oppsWithQuotes = new Map<Id, Quote>();
        if(!quotesToCreate.isempty()){
            for (Quote q : quotesToCreate) {
                oppsWithQuotes.put(q.OpportunityId,q);
            }
        }

        List<QuoteLineItem> qlisToCreate = new List<QuoteLineItem>();
        List<Contract_Product__c> relevantContractProducts = ([SELECT Id, Net_Per_Unit__c, Recurring_Product_ARR__c, SKU__c, Product__c, Quantity__c, Contract__c, Contract__r.CurrencyIsoCode FROM Contract_Product__c WHERE Contract__c IN: relevantContractIds]);
        System.debug('@@@ Renewal_Flat_CreateSalesOrder relevantContractProducts: '+relevantContractProducts);
        
        //Map of all Contract Products with their Contract ID
        Map<Id,List<Contract_Product__c>> contractsWithContractProducts = new Map<Id,List<Contract_Product__c>>();
        //List of all relevant SKUs related to the Contract Products
        List<String> relevantSKUs = new List<String>();
        for (Contract_Product__c cp : relevantContractProducts) {
            relevantSKUs.add(cp.SKU__c);
            System.debug('@@@ Renewal_Flat_CreateSalesOrder CP SKU: '+ cp.SKU__c);
            if (contractsWithContractProducts.containsKey(cp.Contract__c)) {
                contractsWithContractProducts.get(cp.Contract__c).add(cp);
            }
            else {
                contractsWithContractProducts.put(cp.Contract__c,new List<Contract_Product__c>{cp});
            }
        }
        System.debug('@@ Renewal_Flat_CreateSalesOrder relevant SKUs: ' + relevantSKUs);
        System.debug('@@ Renewal_Flat_CreateSalesOrder query pbe: ' + [SELECT Id, CurrencyIsoCode, ProductCode,Product2.Product_Identifier__c, Pricebook2Id  FROM PricebookEntry WHERE Product2.Product_Identifier__c IN: relevantSKUs AND Pricebook2Id = :standardPriceBookId]);
        Map<string, Id> mappedSkuCurrencyToPBE = new Map<string, Id>();
        for (PricebookEntry pbe : [SELECT Id, CurrencyIsoCode, ProductCode,Product2.Product_Identifier__c, Pricebook2Id FROM PricebookEntry WHERE Product2.Product_Identifier__c IN: relevantSKUs AND Pricebook2Id = :standardPriceBookId]) {
            if (!mappedSkuCurrencyToPBE.containsKey(pbe.Product2.Product_Identifier__c+pbe.CurrencyIsoCode)) {
                mappedSkuCurrencyToPBE.put(pbe.Product2.Product_Identifier__c+pbe.CurrencyIsoCode,pbe.Id);
            }
        }
        System.debug('@@ Renewal_Flat_CreateSalesOrder mappedSkuCurrencyToPBE: ' + mappedSkuCurrencyToPBE);

        
        //Current Account ARR, to be added later as QLI with negative ammount
        System.debug('@@@Renewal_Flat_CreateSalesOrder standardPriceBookId: '+standardPriceBookId);
        System.debug('@@@Renewal_Flat_CreateSalesOrder ArrProductIdQuery1: '+[SELECT Id,Name,CurrencyIsoCode,Pricebook2Id,Product2.Name FROM PricebookEntry WHERE Pricebook2Id = :standardPriceBookId]);
        System.debug('@@@Renewal_Flat_CreateSalesOrder ArrProductIdQuery2: '+[SELECT Id,Name,CurrencyIsoCode,Pricebook2Id,Product2.Name FROM PricebookEntry WHERE Pricebook2Id = :standardPriceBookId]);
        Id ArrProductId = [SELECT Id FROM PricebookEntry WHERE Name = 'Current Account ARR' AND Pricebook2Id = :standardPriceBookId AND CurrencyIsoCode = 'USD' limit 1][0].Id;
        //Assign Quote and Contract IDs
        Quote currentQuote = new Quote();
        Contract currentContract1 = new Contract();
        //For each opportunity, check if it has products and if so, iterate throught the products and create QLIs for each
        for (Opportunity opp : renewalOpps) {
            List<Contract_Product__c> OppListOfProducts = contractsWithContractProducts.get(oppsWithContracts.get(opp.Id).Id);
            System.debug('@@@Renewal_Flat_CreateSalesOrder OppListOfProducts: '+OppListOfProducts);
            if(!OppListOfProducts.isempty()){
                currentQuote = oppsWithQuotes.get(opp.Id);
                currentContract1 = oppsWithContracts.get(opp.Id);     
                System.debug('@@@ Renewal_Flat_CreateSalesOrder Original Contract End Date: '+ oppsWithContracts.get(opp.Id).EndDate);
                for (Contract_Product__c cp : OppListOfProducts) {
                    qlisToCreate.add(new QuoteLineItem(
                        QuoteId=currentQuote.Id,
                        ServiceDate=oppsWithContracts.get(opp.Id).EndDate.addDays(1),
                        End_Date__c=oppsWithContracts.get(opp.Id).EndDate.addDays(366),
                        PricebookEntryId=mappedSkuCurrencyToPBE.get(cp.SKU__c+currentContract1.CurrencyIsoCode),
                        UnitPrice=cp.Net_Per_Unit__c,
                        //ListPrice=cp.Net_Per_Unit__c,
                        Net_Per_Unit__c=cp.Net_Per_Unit__c,
                        Renewal_Unit_Price__c=cp.Net_Per_Unit__c,
                        ARR__c=cp.Recurring_Product_ARR__c,
                        DH_Option_Quote_Type__c='New Contract',
                        Is_Primary__c=true,
                        Tier__c=oppsWithContracts.get(opp.Id).Tier__c,
                        Plan_Period__c='Yearly',
                        Duration__c=12.0,
                        Discount=0,
                        Product_Type__c='License',
                        DealHub_Net_Price__c=cp.Net_Per_Unit__c,
                        Seats__c=cp.Quantity__c,
                        Quantity=cp.Quantity__c));
                }
                //add Current Account ARR as QLI with negative ammount - contract arr
                qlisToCreate.add(new QuoteLineItem(QuoteId=currentQuote.Id,Is_Primary__c=true,PricebookEntryId=ArrProductId,UnitPrice=0,ARR__c=(currentContract1.Contract_ARR__c*(-1)),Quantity=1));
            }
            for (QuoteLineItem qli : qlisToCreate) {
                System.debug('@@@ Renewal_Flat_CreateSalesOrder PB ID: '+ qli.PricebookEntryId);
            }
        }
        try {
            Database.SaveResult[] qlisToCreateSrList = Database.insert(qlisToCreate, false);
            Utils.validateDmlOperationResults(qlisToCreateSrList, 'Renewal_Flat_CreateSalesOrder', 'createSalesOrder');
        } 
        catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            Utilities.sendDebugEmail('Error in Renewal SO Creation - QLIs creation part: ',e,e.getMessage());   
            Utilities.sendSlackMessage('Error in Renewal SO Creation - QLIs creation part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);      
            throw new AuraHandledException(e.getMessage());
        }
        //4. Update the opportunity - sync the new quote and change the Auto Renewal Status to Completed, used for monitoring
        
        //Update Opportunity - set IsSyncing to True
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Id oppId : renewalOppIds) {
            oppsToUpdate.add(new Opportunity (Id = oppId, SyncedQuoteId = oppsWithQuotes.get(oppId).Id, Auto_Renewal_Status__c = 'Completed'));
        }
        try {
            Database.SaveResult[] oppsToUpdateSrList = Database.update(oppsToUpdate, false);
            Utils.validateDmlOperationResults(oppsToUpdateSrList, 'Renewal_Flat_CreateSalesOrder', 'createSalesOrder');
        } 
        catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            Utilities.sendDebugEmail('Error in Renewal SO Creation - Opp sync update part: ',e,e.getMessage());   
            Utilities.sendSlackMessage('Error in Renewal SO Creation - Opp sync update part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);      
            throw new AuraHandledException(e.getMessage());
        }

        //Update Quote - set IsSyncing and Status
        for (Quote q : quotesToCreate) {
            q.DH_Quote_Status__c = 'Won';
            q.DH_Date_of_Signature__c = System.now();
            q.DH_Signer_Name__c = 'na';
            q.DH_Signer_Title__c = 'na';
            q.Is_Manually_Signed__c = true;
        }
        try {
            Database.SaveResult[] updatedQuotesToCreateSrList = Database.update(quotesToCreate, false);
            Utils.validateDmlOperationResults(updatedQuotesToCreateSrList, 'Renewal_Flat_CreateSalesOrder', 'createSalesOrder');
        } 
        catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            Utilities.sendDebugEmail('Error in Renewal SO Creation - Opp sync update part: ',e,e.getMessage());   
            Utilities.sendSlackMessage('Error in Renewal SO Creation - Opp sync update part: ', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);      
            throw new AuraHandledException(e.getMessage());
        }
        return quotesToCreate;
    }

    // @AuraEnabled(Cacheable=false)
    // public static Id checkNewQuotes(Id oppId) {
    //     try {
    //         System.debug('@@ Renewal_Flat_CreateSalesOrder opp id: '+ oppId);
    //         System.debug('@@ Renewal_Flat_CreateSalesOrder Query1 output: '+[SELECT Id FROM Quote WHERE OpportunityId=:oppId AND Quote_Source__c = 'Auto Renewal - Flat' ORDER BY CreatedDate DESC LIMIT 1 ]);
    //         System.debug('@@ Renewal_Flat_CreateSalesOrder Query2 output: '+[SELECT Id FROM Quote WHERE OpportunityId=:oppId AND Quote_Source__c = 'Auto Renewal - Flat' ORDER BY CreatedDate DESC][0].Id);
    //         return [SELECT Id FROM Quote WHERE OpportunityId=:oppId AND Quote_Source__c	 = 'Auto Renewal - Flat' ORDER BY CreatedDate DESC][0].Id;
    //     }
    //     catch (Exception e) {
    //         System.debug('Exception type caught: ' + e.getTypeName());    
    //         System.debug('Message: ' + e.getMessage());    
    //         System.debug('Cause: ' + e.getCause());
    //         System.debug('Line number: ' + e.getLineNumber());    
    //         System.debug('Stack trace: ' + e.getStackTraceString()); 
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    
    @AuraEnabled(Cacheable=false)
    public static Contract getSelectedContractDetails(Id contractId) {
        try {
            return [SELECT Id,Tier__c,Contract_Seats__c,Period__c,Weighted_Average_Net_Per_Unit__c,EndDate FROM Contract WHERE id = :contractId ORDER BY CreatedDate DESC][0];
        }
        catch (Exception e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            throw new AuraHandledException(e.getMessage());
        }
    }
}