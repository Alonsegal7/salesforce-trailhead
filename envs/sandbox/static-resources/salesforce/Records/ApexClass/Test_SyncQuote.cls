@isTest
private class Test_SyncQuote {
    
    static testMethod void testSyncQuote(){
        LineItem_Sync__c cs = new LineItem_Sync__c(Name = 'Quantity', Opportunity_Line_Item_field__c = 'Quantity');
        insert cs;

        Account acc = new Account() ; 
        acc.Name = 'Test' ;
        insert acc ; 

        PriceBook2 pb = New PriceBook2(Id = test.getStandardPricebookId(), isActive = true);
        update pb;

        Opportunity opp = new Opportunity() ; 
        opp.Name = 'Test' ;
        opp.StageName = 'Test' ;
        opp.CloseDate = system.today() ; 
        opp.Pricebook2Id = pb.Id;
        insert opp;

        Quote q = new Quote();
        q.Name = 'Test';
        q.OpportunityId = opp.Id;
        q.Pricebook2Id = pb.Id;
        insert q;

        Product2 p = new Product2(Name='BXCD', isActive=true);
        insert p;

        PriceBookEntry stdPBE = new PriceBookEntry(Product2Id = p.Id, Pricebook2Id = pb.Id, UnitPrice = 2, isActive = true);
        insert stdPBE;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PriceBookEntryId = stdPBE.Id, totalPrice = 1, Quantity = 1);
        insert oli;

        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.id, PriceBookentryId = stdPBE.Id, Quantity = 2, UnitPrice = 1);
        insert qli;

        SubScription__c sub = TestObjectCreator.CreateSubscription();
        insert sub;

        Test.startTest();
        opp.SyncedQuoteId = q.Id;
        update opp;
        Contract con= new Contract(AccountId=acc.id,StartDate=date.today(),ContractTerm=12);
        ContractValidationCopmController.getBBContract(opp.id);
        ContractValidationCopmController.sendContractToBB(con);
        ContractValidationCopmController.findExisingContracts(opp.id);
        ContractValidationCopmController.createContract(con);
        //SubscriptionPickerController.getSubscriptions(opp.id);
        //SubscriptionPickerController.getClaimed(opp.id);
        //SubscriptionPickerController.claimSubs(new list<String>{sub.id},opp.id);
        Test.stopTest();

    }
    
}