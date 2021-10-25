@isTest
public class Renewal_Global_Test {
    public static Profile profileId;
    public static User userRecord;
    
    public static testmethod void createOpportunityWithQLI() {
        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;
        
        TestObjectCreator.persistImmediate=true;
        Account comp = TestObjectCreator.CreateCompany();
        
        Contract con = TestObjectCreator.CreateContract(comp);
        con.Primary_Renewal_Owner__c = userRecord.Id;
        con.EndDate = System.today();
        update con;
        
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        ma.Active_Contract__c = con.Id;
        ma.ARR__c = 100;
        update ma;
        
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem qli = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        
        Contract_Product__c conProd = new Contract_Product__C (Contract__c = con.Id);
        insert conProd;
        Contract_Event__c conEvent = new Contract_Event__c(isrecurring__c = true, Contract__c = con.Id, Contract_Product__c = conProd.Id, Start_Date__c = System.today(), Quote_Line_Item__c = qli.Id);
        insert conEvent;
        
        System.runAs(userRecord){
            opportunity_RenewalCreation.checkOpenRenewalOpps(con.Id);
            opportunity_RenewalCreation.insertOpportunity(con.Id); 

        }

    }
    
    public static testmethod void createOpportunityWithSubs() {
        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;
        
        TestObjectCreator.persistImmediate=true;
        Account comp = TestObjectCreator.CreateCompany();
        
        Contract con = TestObjectCreator.CreateContract(comp);
        con.Primary_Renewal_Owner__c = userRecord.Id;
        con.EndDate = System.today();
        update con;
        
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        ma.Active_Contract__c = con.Id;
        ma.ARR__c = 100;
        update ma;
        
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        Subscription__c sub = TestObjectCreator.CreateSubscription();
        
        Contract_Product__c conProd = new Contract_Product__C (Contract__c = con.Id);
        insert conProd;
        Contract_Event__c conEvent = new Contract_Event__c(isrecurring__c = true, Contract__c = con.Id, Contract_Product__c = conProd.Id, Start_Date__c = System.today(), Subscription__c = sub.Id);
        insert conEvent;
        
        System.runAs(userRecord){
            opportunity_RenewalCreation.checkOpenRenewalOpps(con.Id);
            opportunity_RenewalCreation.insertOpportunity(con.Id); 
        }
    }
    
    //Michael Scenario Test Method   
    @isTest
    public static void createRenewalSalesOrder() {
        
        Test.startTest();
        
        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;
        
        TestObjectCreator.persistImmediate=true;
        Account comp = TestObjectCreator.CreateCompany();
        Contract con = TestObjectCreator.CreateContract(comp);
        con.Primary_Renewal_Owner__c = userRecord.Id;
        con.EndDate = System.today();
        update con;
        
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        ma.Active_Contract__c = con.Id;
        ma.ARR__c = 100;
        update ma;
        
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        Subscription__c sub = TestObjectCreator.CreateSubscription();
        
        Contract_Product__c conProd = new Contract_Product__C (Contract__c = con.Id);
        insert conProd;
        Contract_Event__c conEvent = new Contract_Event__c(isrecurring__c = true, Contract__c = con.Id, Contract_Product__c = conProd.Id, Start_Date__c = System.today(), Subscription__c = sub.Id);
        insert conEvent;

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

        Product2 arrProduct = new Product2(Name = 'Current Account ARR', IsActive = true, IsRecurring__c=true,Contract_Creation_Product__c=true,Contract_Event_Product__c=true);
        insert arrProduct;

        PricebookEntry arrProductPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = arrProduct.Id,
            UnitPrice = 1000,
            UseStandardPrice = false,
            IsActive = true
        );
        insert arrProductPBE;


        // This should return true now
        system.assertEquals(true, standardPricebook.IsStandard, 'The Standard Pricebook should now return IsStandard = true');
        
        Opportunity renewalOpp = opportunity_RenewalCreation.insertOpportunity(con.Id); 
        Billing_Entity__c be = TestObjectCreator.CreateBE();
        renewalOpp.Billing_Entity__c = be.Id;
        update renewalOpp;

        System.debug('@@@ renewalOpp: '+renewalOpp);
        System.debug('@@@ renewaContract: '+con);
        
        System.runAs(userRecord){
            List<Id>renewalOppIds = new List<Id>();
            renewalOppIds.add(renewalOpp.Id);
            // renewalOppIds.add([SELECT Id FROM Opportunity WHERE Selected_Company_Contract__c = :con.Id][0].Id);
            Renewal_Flat_CreateSalesOrder.createRenewalSalesOrder(renewalOppIds);
            // List<Quote>oppQuotes = ([SELECT Id,OpportunityId,Quote_Source__c FROM Quote WHERE OpportunityId IN:renewalOppIds]);
            // System.assertEquals(1, oppQuotes.size());
            // for (Quote q : oppQuotes) {
            //     System.assertEquals('Auto Renewal - Flat', q.Quote_Source__c);
            // }
        }
        
        
        
        //1. Create a contract to be renewed
        
        /*
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Contract contract = TestObjectCreator.CreateContract(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
        quoteNewCont.DH_Quote_Status__c='Won';
        quoteNewCont.Document_Type__c='Sales Order';
        quoteNewCont.Manual_Trigger__c = 'Create Active Contract';
        update quoteNewCont;
        
        TestObjectCreator.persistImmediate = false;
        
        //2. Create a renewal opportunity, linked to the contract above
        
        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;

        Contract renewalContract = [SELECT Id FROM Contract WHERE AccountId = :ma.Id][0];
        System.assertEquals(false, renewalContract.Id == null);

        renewalContract.EndDate = System.today();
        renewalContract.Primary_Renewal_Owner__c = userRecord.Id;
        update renewalContract;
        
        ma.Active_Contract__c = renewalContract.Id;
        ma.ARR__c = 100;
        update ma;

        
        System.runAs(userRecord){
            opportunity_RenewalCreation.checkOpenRenewalOpps(renewalContract.Id);
            Opportunity renewalOpp = opportunity_RenewalCreation.insertOpportunity(renewalContract.Id); 
            //System.assertEquals(false, renewalOpp == null);
        
        


            //3. Create renewal so from the renewal opp

            // List<Id>renewalOppIds = new List<Id>();
            // renewalOppIds.add([SELECT Id FROM Opportunity WHERE Selected_Company_Contract__c = :primaryContract.Id][0].Id);
            // System.runAs(userRecord){
            //     Renewal_Flat_CreateSalesOrder.createRenewalSalesOrder(renewalOppIds);
            // }
            // List<Quote>oppQuotes = ([SELECT Id,OpportunityId,Quote_Source__c FROM Quote WHERE OpportunityId IN:renewalOppIds]);
            // System.assertEquals(1, oppQuotes.size());
            // for (Quote q : oppQuotes) {
            //     System.assertEquals('Auto Renewal - Flat', q.Quote_Source__c);
            // }
        }

        Test.stopTest();



        //Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        /*
        Contract_Product__c conProd = new Contract_Product__C (Contract__c = con.Id);
        insert conProd;
        Contract_Event__c conEvent = new Contract_Event__c(isrecurring__c = true, Contract__c = con.Id, Contract_Product__c = conProd.Id, Start_Date__c = System.today());
        insert conEvent;
    
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );

        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;

        // Re-Query for the Pricebook2 record, for debugging
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

        // This should return true now
        system.assertEquals(true, standardPricebook.IsStandard, 'The Standard Pricebook should now return IsStandard = true');

        // Create the Product
        Product2 testProduct = new Product2(
            Name = 'Test Product', 
            IsActive = true
        );
        insert testProduct;

        // Create the PricebookEntry
        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );

        insert testPbe;

        // Re-Query the PBE
        testPbe = [SELECT Id, Pricebook2.IsStandard FROM PricebookEntry];
        */
        
        // System.runAs(userRecord){
        //     opportunity_RenewalCreation.checkOpenRenewalOpps(primaryContract.Id);
        //     opportunity_RenewalCreation.insertOpportunity(primaryContract.Id);
        // }
        
        /*
        List<Id>renewalOppIds = new List<Id>();
        renewalOppIds.add([SELECT Id FROM Opportunity WHERE Selected_Company_Contract__c = :primaryContract.Id][0].Id);
        System.runAs(userRecord){
            Renewal_Flat_CreateSalesOrder.createRenewalSalesOrder(renewalOppIds);
        }
        List<Quote>oppQuotes = ([SELECT Id,OpportunityId,Quote_Source__c FROM Quote WHERE OpportunityId IN:renewalOppIds]);
        System.assertEquals(1, oppQuotes.size());
        for (Quote q : oppQuotes) {
            System.assertEquals('Auto Renewal - Flat', q.Quote_Source__c);
        }
        */

    }
    
}