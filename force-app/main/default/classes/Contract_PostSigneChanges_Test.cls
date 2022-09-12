@istest
public with sharing class Contract_PostSigneChanges_Test {
    @TestSetup
    static void makeData(){
        TestObjectCreator.persistImmediate = true;
        DateTime dT = System.now();
        Date startDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDate = date.newinstance(dT.year()+1, dT.month(), dT.day());
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Contract currentAccountCon = new contract(
            accountId=company.Id,
            Name='currentAccountCon',
            Status__c='Active'
        );
        insert currentAccountCon;
        TestObjectCreator.persistImmediate = false;
        ma.primary_pulse_account_id__c='12211';
        ma.active_contract__c=currentAccountCon.Id;
        update ma;

        TestObjectCreator.persistImmediate = true;
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        TestObjectCreator.persistImmediate = false;
        opportunity.syncedquoteid=quoteNewCont.id;
        update opportunity;
        quoteNewCont.name='NewContractQuote';
        update quoteNewCont;
        TestObjectCreator.persistImmediate = true;

        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        quoteLicenseLine.Duration__c=12;
        quoteLicenseLine.ServiceDate=startDate;
        quoteLicenseLine.End_Date__c=endDate;
        quoteLicenseLine.Duration__c=12;
        quoteLicenseLine.Tier__c='Pro';
        quoteLicenseLine.List_Price__c=38;
        quoteLicenseLine.Net_Per_Unit__c=263;
        quoteLicenseLine.arr__c=123;
        TestObjectCreator.persistImmediate = false;
        update quoteLicenseLine;

        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
        quoteNewCont.DH_Quote_Status__c='Won';
        quoteNewCont.Document_Type__c='Sales Order';
        update quoteNewCont;
    }
    @istest
    public static void setOppLost_NewContractDeal(){

        Contract con = [select id,status__c,prior_contract__c, prior_contract__r.Name,prior_contract__r.status__c from contract where name !='currentAccountCon' limit 1];
        Opportunity oppty = [select id,stagename from opportunity limit 1];
        Account acc = [select id, active_contract__c,primary_pulse_account_id__c from account where primary_pulse_account_id__c='12211' limit 1];
        Contract con2 = [select id,status__c,Continuation_Contract__c from contract where name ='currentAccountCon' limit 1];

        System.assertEquals('Active' ,con.status__c);
        System.assertEquals(acc.active_contract__c ,con.Id);
        System.assertEquals('Deactivated' ,con2.status__c);
        System.assertEquals(con.prior_contract__r.Name  ,'currentAccountCon');
        System.assertNotEquals(con.prior_contract__c, null);
        System.assertNotEquals(con2.Continuation_Contract__c, null);
        
        Oppty.stagename='Closed Lost';
        update oppty;

        Contract con1 = [select id,status__c,prior_contract__c from contract where name !='currentAccountCon' limit 1];
        Contract con3 = [select id,status__c,Continuation_Contract__c from contract where name ='currentAccountCon' limit 1];
        Account acc1 = [select id, active_contract__c,primary_pulse_account_id__c from account where primary_pulse_account_id__c='12211' limit 1];

        System.assertEquals('Deactivated' ,con1.status__c);
        System.assertEquals('Active' ,con3.status__c);
        System.assertEquals(null,con1.prior_contract__c);
        System.assertEquals(null,con3.Continuation_Contract__c);
        System.assertEquals(acc1.active_contract__c ,con3.Id);
    
    }
    @istest
    public static void setOppLost_ProRatedContractDeal(){
        test.startTest();
        //to reduce cpu limit (fails on make data)
        //prorated data
        TestObjectCreator.persistImmediate = true;
        DateTime proRateddT = System.now();
        Date proRatedstartDate = date.newinstance(proRateddT.year(), proRateddT.month(), proRateddT.day());
        Date proRatedendDate = date.newinstance(proRateddT.year()+1, proRateddT.month(), proRateddT.day());
        Account proRatedcompany = TestObjectCreator.CreateCompany();
        Account proRatedma = TestObjectCreator.CreateMondayAccount(proRatedcompany);
        Product2 prodForExisitngEvent = TestObjectCreator.CreateProduct();
        TestObjectCreator.persistImmediate = false;

        Contract proRatedcon = TestObjectCreator.CreateContract(proRatedcompany);
        proRatedcon.StartDate=proRatedstartDate;
        proRatedcon.EndDate=proRatedendDate;
        insert proRatedcon;
        Contract_Product__c conProd = new Contract_Product__c(Contract__c=proRatedcon.Id,Product__c=prodForExisitngEvent.Id);
        insert conProd;
        //Existing contract exist
        Contract_Event__c conEvent = new Contract_Event__c(
            Contract__c=proRatedcon.Id, Calculate_Arr__c=true, 
            Contract_Product__c=conProd.Id,
            Product__c= prodForExisitngEvent.Id,
            SKU__c='CORE-PRO',
            IsRecurring__c=true,  
            ARR__c=123, 
            Quantity__c=20,
            Quantity_Unit_Of_Measure__c='Seats',
            Start_Date__c=proRatedstartDate,
            End_Date__c=proRatedendDate);

        proRatedma.Active_Contract__c=proRatedcon.Id;
        proRatedma.primary_pulse_account_id__c='122111';

        insert conEvent;
        update proRatedma;

        TestObjectCreator.persistImmediate = true;
        Opportunity proRatedOpportunity = TestObjectCreator.CreateOpp(proRatedma);
        Quote quoteProRataCont = TestObjectCreator.CreateNonContractQuote(proRatedOpportunity, 'Pro-rated- Additional Seats');
        QuoteLineItem proRataQuoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteProRataCont, 'License', 1, 1.0);
        TestObjectCreator.persistImmediate = false;
        proRataQuoteLicenseLine.Duration__c=12;
        proRataQuoteLicenseLine.ServiceDate=proRatedstartDate;
        proRataQuoteLicenseLine.End_Date__c=proRatedendDate;
        proRataQuoteLicenseLine.Duration__c=12;
        proRataQuoteLicenseLine.Tier__c='Enterprise';
        proRataQuoteLicenseLine.List_Price__c=38;
        proRataQuoteLicenseLine.Net_Per_Unit__c=263;
        proRataQuoteLicenseLine.Added_Seats__c=53;
        proRataQuoteLicenseLine.ARR__c=5353;
        
        update proRataQuoteLicenseLine;

        proRatedOpportunity.syncedquoteid=quoteProRataCont.id;
        update proRatedOpportunity;

        TestObjectCreator.persistImmediate = true;
        List<OpportunityLineItem> proRataOpportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(proRatedOpportunity, proRataQuoteLicenseLine) };
        TestObjectCreator.persistImmediate = false;

        quoteProRataCont.DH_Quote_Status__c='Won';
        quoteProRataCont.Document_Type__c='Sales Order';
        quoteProRataCont.Get_Contract_Id__c=proRatedcon.Id;
        update quoteProRataCont;

        quotelineitem qli = [select id, quoteId from quotelineitem where arr__c=5353];
        Contract con = [select id,status__c,prior_contract__c,contract_arr__c, prior_contract__r.Name,prior_contract__r.status__c from contract where contract_arr__c=5476 limit 1];
        Contract_event__c conEv = [select id,status__c,quote_line_item__r.quoteid from contract_event__c where quote_line_item__r.quoteid=:qli.quoteId];
        Opportunity oppty = [select id,stagename,syncedquoteid from opportunity where syncedquoteid=:qli.quoteid limit 1];
        
        System.assertEquals('Valid' ,conEv.status__c);

        oppty.stagename='Closed Lost';
        update oppty;
        test.stopTest();

        Contract_event__c conEv1 = [select id,status__c,Cancellation_Reason__c,quote_line_item__r.quoteid from contract_event__c where quote_line_item__r.quoteid=:qli.quoteId];
        System.assertEquals('Canceled' ,conEv1.status__c);
        System.assertEquals('Deal Was Lost' ,conEv1.Cancellation_Reason__c);


    
    }
}