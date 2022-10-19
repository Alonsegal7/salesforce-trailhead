@isTest
public class Renewal_Flat_CreateSalesOrder_Test {
    public static Profile profileId;
    public static User userRecord;
    
    @TestSetup
    static void makeData(){

        // Globals.CodeOff = true;
        Id CSRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CS_Opportunity').getRecordTypeId();
        
        Profile profileAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userAdmRecord = TestUtils.getUserWithoutRole(profileAdminId);
        insert userAdmRecord;

        profileId = [SELECT Id FROM Profile WHERE Name = 'Renewals'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        userRecord.ManagerId = userAdmRecord.Id;
        insert userRecord;
        
        TestObjectCreator.persistImmediate=true;
        Account comp = TestObjectCreator.CreateCompany();
        
        Contract con = TestObjectCreator.CreateContract(comp);
        con.Primary_Renewal_Owner__c = userRecord.Id;
        con.EndDate = System.today();
        con.Tier__c='Pro';
        update con;

        System.debug('@@@ Renewal_Global_Test Contract Created: '+con);
        
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        ma.Active_Contract__c = con.Id;
        ma.ARR__c = 100;
        update ma;
        
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        //Subscription__c sub = TestObjectCreator.CreateSubscription();
        
        Pricebook2 standardPricebook = TestObjectCreator.CreatePricebook();
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        Product2 arrProduct = new Product2(Name = 'Current Account ARR', IsActive = true, IsRecurring__c=true,Contract_Creation_Product__c=true,Contract_Event_Product__c=true);
        insert arrProduct;
        
        Product2 subProduct = new Product2(Name = 'Enterprise Plan', IsActive = true, ProductCode = 'abc', IsRecurring__c=true,Contract_Creation_Product__c=true,Contract_Event_Product__c=true);
        insert subProduct;
        
        System.debug('@@@Renewal_Global_Test arrProduct: '+arrProduct);
        
        Contract_Product__c conProd = new Contract_Product__C (Contract__c = con.Id, Product__c = subProduct.Id ,CurrencyIsoCode = 'USD');
        insert conProd;
        Contract_Event__c conEvent = new Contract_Event__c(
            isrecurring__c = true, 
            Contract__c = con.Id, 
            Contract_Product__c = conProd.Id, 
            Start_Date__c = System.today(), 
            // Subscription__c = sub.Id, 
            Net_Unit_Price__c = 1000, 
            Quantity__c = 1, 
            ARR__c=1000, 
            Calculate_ARR__c=true);
        insert conEvent;

        System.debug('@@@Renewal_Global_Test conProd: '+ [SELECT Id, Contract__c, CurrencyIsoCode, Net_Per_Unit__c ,Recurring_Product_ARR__c , SKU__c, Product__c, Quantity__c, Contract__r.CurrencyIsoCode FROM Contract_Product__c WHERE Id =:conProd.Id]);

        PricebookEntry arrProductStandardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = arrProduct.Id,
            UnitPrice = 1000,
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert arrProductStandardPBE;

        PricebookEntry arrProductPBE = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = arrProduct.Id,
            UnitPrice = 1000,
            UseStandardPrice = false,
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert arrProductPBE;

        PricebookEntry subProductStandardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = subProduct.Id,
            UnitPrice = 1000,
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert subProductStandardPBE;

        PricebookEntry subProductPBE = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = subProduct.Id,
            UnitPrice = 1000,
            UseStandardPrice = false,
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert subProductPBE;

        System.debug('@@Renewal_Global_Test arrProductPBE1: '+arrProductPBE);
        System.debug('@@Renewal_Global_Test arrProductPBE2: '+[SELECT Id,CurrencyIsoCode,Product2.Name,Pricebook2Id FROM PricebookEntry WHERE Id=:arrProductPBE.Id]);
        System.debug('@@Renewal_Global_Test arrProductPBE3: '+[SELECT Id,CurrencyIsoCode,Name,Pricebook2Id FROM PricebookEntry WHERE Id=:arrProductPBE.Id]);
        
        System.runAs(userRecord){
            System.debug('@@@Renewal_Global_Test Renewal Opp Contract Id: '+con.Id);
            System.debug('@@@Renewal_Global_Test contractQuery: ' + [SELECT Id FROM Contract WHERE Id =: con.Id LIMIT 1]);
            opportunity_RenewalCreation.checkOpenRenewalOpps(con.Id);
            List<Id> contractIdList = new List<Id>{con.Id};
            Opportunity renewalOpp = opportunity_RenewalCreation.createRenewalOpportunities(contractIdList,'Automatic Renewal Creation')[0]; 
            Billing_Entity__c be = TestObjectCreator.CreateBE();
            renewalOpp.Billing_Entity__c = be.Id;
            update renewalOpp;
            System.debug('@@@Renewal Opp Id: '+renewalOpp);
            System.debug('@@@Renewal Opp Id: '+[SELECT Id,Selected_Company_Contract__c FROM Opportunity WHERE Type = 'Flat Renewal' LIMIT 1]);
        }
    }
    
    @isTest
    public static void Renewal_Flat_CreateSalesOrder_Test() {
        
        // Globals.CodeOff = true;
        
        Test.startTest();

        //Id CSRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CS_Opportunity').getRecordTypeId();
        Opportunity renewalOpp = [SELECT Id,Selected_Company_Contract__c FROM Opportunity WHERE Type = 'Flat Renewal' LIMIT 1];

        System.debug('@@@Renewal_Global_Test renewalOpp: '+renewalOpp.Id);
        System.debug('@@@Renewal_Global_Test renewaContract: '+renewalOpp.Selected_Company_Contract__c);

        User userRecord = [SELECT Id FROM User LIMIT 1][0];
        
        System.runAs(userRecord){
            List<Id>renewalOppIds = new List<Id>();
            renewalOppIds.add(renewalOpp.Id);
            Renewal_Flat_CreateSalesOrder.createRenewalSalesOrder(renewalOppIds);
            
            test.stopTest();
            
            Quote oppQuote = [SELECT Id,OpportunityId,Quote_Source__c,ContractId,Is_Finalized__c,AccountId FROM Quote WHERE OpportunityId IN:renewalOppIds][0];
            List<QuoteLineItem> qlisCreated = new List<QuoteLineItem>([SELECT Id,ServiceDate,End_Date__c,DealHub_Net_Price__c FROM QuoteLineItem WHERE QuoteId=:oppQuote.Id]);
            System.debug('@@@Renewal_Global_Test qlisCreated: '+qlisCreated);    
            System.debug('@@@Renewal_Global_Test oppQuote: '+oppQuote);    
            System.assertEquals('Auto Renewal - Flat', oppQuote.Quote_Source__c);
            System.assertEquals(false, oppQuote.ContractId == null);
        }
    }
}