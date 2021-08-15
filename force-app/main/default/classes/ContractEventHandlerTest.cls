/* 
    This test class is covering these apex classes:
    Subscription_ConnectToContractEvent
    ContractEventToContract
    ContractEventHandler
*/
@IsTest
public with sharing class ContractEventHandlerTest { 

    @IsTest
    public static void SalesOrderNewContract() {
        TestObjectCreator.persistImmediate = true;
        DateTime dT = System.now();
        Date startDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDate = date.newinstance(dT.year()+1, dT.month(), dT.day());
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        ma.primary_pulse_account_id__c='12211';
        update ma;

        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        quoteLicenseLine.Duration__c=12;
        quoteLicenseLine.ServiceDate=startDate;
        quoteLicenseLine.End_Date__c=endDate;
        quoteLicenseLine.Duration__c=12;
        quoteLicenseLine.Tier__c='Enterprise';
        quoteLicenseLine.List_Price__c=38;
        quoteLicenseLine.Net_Per_Unit__c=263;
        quoteLicenseLine.arr__c=123;
        update quoteLicenseLine;

        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
        quoteNewCont.DH_Quote_Status__c='Won';
        quoteNewCont.Document_Type__c='Sales Order';
        update quoteNewCont;

        Subscription__c sub = TestObjectCreator.CreateSubscription();
        sub.Pulse_Account_Id__c='12211';
        sub.Deactivation_Date__c=endDate;
        sub.Activation_Date__c=startDate;
        sub.Activated_via_Import_SO__c=true;
        update sub;

        Quote quote = [select Id,ContractId from quote where Quote_Type__c='New Contract' limit 1];
        Contract createdCon = [select Id,Contract_Arr__c from contract limit 1];
        Contract_Event__c conEve = [select Id, IsRecurring__c, Net_Unit_Price__c from contract_event__c where contract__c=:createdCon.Id limit 1];
        List<Contract_Event__c> conEvntList = [select id from contract_event__c where contract__c =: createdCon.Id];

        System.assertEquals(createdCon.Id ,quote.ContractId);
        System.assertEquals(263, conEve.Net_Unit_Price__c);
        System.assertEquals(true, conEve.IsRecurring__c);
        System.assertEquals(123, createdCon.Contract_Arr__c);
        System.assertEquals(1, conEvntList.size());
    }
    @IsTest
    public static void SalesOrderProRatedContract() {
        TestObjectCreator.persistImmediate = true;
        DateTime dT = System.now();
        Date startDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDate = date.newinstance(dT.year()+1, dT.month(), dT.day());

        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        TestObjectCreator.persistImmediate = false;

        Contract con = TestObjectCreator.CreateContract(company);
        con.StartDate=startDate;
        con.EndDate=endDate;
        insert con;
        Contract_Event__c conEvent = new Contract_Event__c(
            Contract__c=con.Id, Calculate_Arr__c=true, 
            IsRecurring__c=true,  
            ARR__c=123, 
            Quantity__c=20,
            Quantity_Unit_Of_Measure__c='Seats',
            Start_Date__c=startDate,
            End_Date__c=endDate);
        ma.Active_Contract__c=con.Id;
        ma.primary_pulse_account_id__c='12211';
        insert conEvent;
        update ma;
        TestObjectCreator.persistImmediate = true;

        Opportunity proRatedOpportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteProRataCont = TestObjectCreator.CreateNonContractQuote(proRatedOpportunity, 'Pro-rated- Additional Seats');
        QuoteLineItem proRataQuoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteProRataCont, 'License', 1, 1.0);
        proRataQuoteLicenseLine.Duration__c=12;
        proRataQuoteLicenseLine.ServiceDate=startDate;
        proRataQuoteLicenseLine.End_Date__c=endDate;
        proRataQuoteLicenseLine.Duration__c=12;
        proRataQuoteLicenseLine.Tier__c='Enterprise';
        proRataQuoteLicenseLine.List_Price__c=38;
        proRataQuoteLicenseLine.Net_Per_Unit__c=263;
        proRataQuoteLicenseLine.Added_Seats__c=53;
        proRataQuoteLicenseLine.ARR__c=5353;
        update proRataQuoteLicenseLine;
        List<OpportunityLineItem> proRataOpportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(proRatedOpportunity, proRataQuoteLicenseLine) };
        TestObjectCreator.persistImmediate = false;

        Subscription__c sub = TestObjectCreator.CreateSubscription();
        sub.Pulse_Account_Id__c='12211';
        sub.Deactivation_Date__c=endDate;
        sub.Activation_Date__c=startDate;
        sub.arr__c=123;
        sub.seats__c='20';
        insert sub;

        quoteProRataCont.DH_Quote_Status__c='Won';
        quoteProRataCont.Document_Type__c='Sales Order';
        quoteProRataCont.Get_Contract_Id__c=con.Id;
        Test.startTest();
        update quoteProRataCont;
        Test.stopTest();

        Quote quote = [select Id,ContractId from quote where Quote_Type__c='Pro-rated- Additional Seats' limit 1];
        Contract proRatedCon = [select Id,Contract_Arr__c,Contract_Seats__c from contract where id =: con.Id limit 1];
        List<Contract_Event__c> conEvntList = [select id from contract_event__c];
        List<Contract> conLit =[select id from contract];
        System.assertEquals(proRatedCon.Id ,quote.ContractId);
        System.assertEquals(73 ,proRatedCon.Contract_Seats__c);
        System.assertEquals(5476 ,proRatedCon.Contract_arr__c);
        System.assertEquals(2, conEvntList.size());
        System.assertEquals(1, conLit.size());

    }
    @IsTest
    public static void SalesOrderManTriggerContract() {
        TestObjectCreator.persistImmediate = true;
        DateTime dT = System.now();
        Date startDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDate = date.newinstance(dT.year()+1, dT.month(), dT.day());
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        Contract con = TestObjectCreator.CreateContract(company);
        ma.Active_Contract__c=con.Id;
        update ma;

        quoteLicenseLine.Duration__c=12;
        quoteLicenseLine.ServiceDate=startDate;
        quoteLicenseLine.End_Date__c=endDate;
        quoteLicenseLine.Tier__c='Enterprise';
        quoteLicenseLine.List_Price__c=38;
        quoteLicenseLine.Net_Per_Unit__c=20;
        quoteLicenseLine.Seats__c=124;
        update quoteLicenseLine;

        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
        quoteNewCont.Manual_Trigger__c='Create Active Contract';
        quoteNewCont.Document_Type__c='Sales Order';
        update quoteNewCont;

        Quote quote = [select Id,ContractId from quote where Quote_Type__c='New Contract' limit 1];
        Contract createdCon = [select Id from contract where seats__c=124 limit 1];
        Contract_Event__c conEve = [select Id, IsRecurring__c, Net_Unit_Price__c from contract_event__c where contract__c=:createdCon.Id limit 1];
         
        System.assertEquals(createdCon.Id ,quote.ContractId);
        System.assertEquals(20, conEve.Net_Unit_Price__c);
        System.assertEquals(true, conEve.IsRecurring__c);
    }
    @IsTest
    public static void InitErrorToContractEvent() {
        TestObjectCreator.persistImmediate = true;
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opportunity, 'New Contract');
        QuoteLineItem quoteLicenseLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'License', 1, 1.0);
        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opportunity, quoteLicenseLine) };
        quoteNewCont.DH_Quote_Status__c='Won';
        quoteNewCont.Document_Type__c='Sales Order';
        update quoteNewCont;

        Quote quote = [select Id,ContractId from quote where Quote_Type__c='New Contract' limit 1];
        System.assertEquals(null ,quote.ContractId);
    }
    @IsTest
    public static void SubscriptionWithoutMAContract() {
        DateTime dT = System.now();
        Date dateD = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDateD = date.newinstance(dT.year()+1, dT.month(), dT.day());
        //TestObjectCreator.persistImmediate = true;
        Account company = TestObjectCreator.CreateCompany();
        insert company;

        Account ma = TestObjectCreator.CreateMondayAccount(company);
        ma.primary_pulse_account_id__c='12211';
        insert ma;

        Subscription__c sub = TestObjectCreator.CreateSubscription();
        sub.Pulse_Account_Id__c='12211';
        sub.Deactivation_Date__c=endDateD;
        sub.Activation_Date__c=dateD;
        sub.Activated_via_Import_SO__c=false;
        
        Test.startTest();
        insert sub;
        Test.stopTest();



        Subscription__c createdSub = [select Id,Contract__c from Subscription__c limit 1];
        Contract createdCon = [select Id,StartDate,EndDate from contract limit 1];
        Contract_Event__c conEve = [select Id,ARR__c, IsRecurring__c, Net_Unit_Price__c from contract_event__c where contract__c=:createdCon.Id limit 1];
        Account accWiActiveCon = [select id,primary_pulse_account_id__c, active_contract__c from account where primary_pulse_account_id__c='12211' limit 1]; 
        
        System.assertEquals(createdCon.Id ,createdSub.Contract__c);
        System.assertEquals(1020, conEve.ARR__c);
        System.assertEquals(true, conEve.IsRecurring__c);
        System.assertEquals(createdCon.Id, accWiActiveCon.Active_Contract__c);
        
        Subscription__c sub1 = TestObjectCreator.CreateSubscription();
        sub1.Pulse_Account_Id__c='12211';
        sub1.Deactivation_Date__c=endDateD;
        sub1.Activation_Date__c=dateD;
        sub1.Activated_via_Import_SO__c=false;
        sub1.Name='432342';
        insert sub1;


        List<Contract_Event__c> conEvntList = [select id from contract_event__c];
        Subscription__c createdSub1 = [select Id,Contract__c from Subscription__c where Name='432342' limit 1];

        System.assertEquals(createdCon.Id, createdSub1.Contract__c);
        //sub with same values will not create contract event
        System.assertEquals(1, conEvntList.size());

    }
    @IsTest
    public static void SubscriptionWithMAContract() {
        DateTime dT = System.now();
        Date dateD = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDateD = date.newinstance(dT.year()+1, dT.month(), dT.day());
        Account company = TestObjectCreator.CreateCompany();
        insert company;

        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Contract con = TestObjectCreator.CreateContract(company);
        con.EndDate=endDateD;
        insert con;

        ma.primary_pulse_account_id__c='12211';
        ma.Active_Contract__c=con.Id;
        insert ma;

        Subscription__c sub = TestObjectCreator.CreateSubscription();
        sub.Pulse_Account_Id__c='12211';
        sub.Deactivation_Date__c=endDateD;
        sub.Activation_Date__c=dateD;
        sub.Activated_via_Import_SO__c=false;

        Contract exisCon = [select Id,Contract_arr__c from contract limit 1];
        System.assertEquals(0 ,exisCon.Contract_arr__c);
        
        Test.startTest();
        insert sub;
        Test.stopTest();
        Subscription__c createdSub = [select Id,Contract__c from Subscription__c limit 1];
        Contract exisCon1 = [select Id,Contract_arr__c,Contract_Seats__c from contract limit 1];

        System.assertEquals(1020 ,exisCon1.Contract_arr__c);
        System.assertEquals(50 ,exisCon1.Contract_Seats__c);
        System.assertEquals(exisCon1.Id ,createdSub.Contract__c);
        System.assertEquals(ma.Active_Contract__c ,createdSub.Contract__c);



    }

}