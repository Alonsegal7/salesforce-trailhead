@istest
public with sharing class CorrectionLogicTest {
    @TestSetup
    public static void makedata() {
            Id correctoinRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Correction_Opportunity').getRecordTypeId();
            TestObjectCreator.persistImmediate = true;
            DateTime dT = System.now();
            Date startDate = date.newinstance(dT.year(), dT.month(), dT.day());
            Date endDate = date.newinstance(dT.year()+1, dT.month(), dT.day());
            Account company = TestObjectCreator.CreateCompany();
            Account ma = TestObjectCreator.CreateMondayAccount(company);
            Product2 prodForExisitngEvent = TestObjectCreator.CreateProduct();

            TestObjectCreator.persistImmediate = false;

            TestObjectCreator.persistImmediate = true;
            Opportunity generalOpp = TestObjectCreator.CreateOpp(ma);
            Quote quotegeneraCont = TestObjectCreator.CreateNonContractQuote(generalOpp, 'New Contract');
            QuoteLineItem qli = TestObjectCreator.CreateQuoteLineItem(quotegeneraCont, 'License', 1, 1.0);
            TestObjectCreator.persistImmediate = false;

            Contract con = TestObjectCreator.CreateContract(company);
            con.StartDate=startDate;
            con.EndDate=endDate;
            insert con;
            Contract_Product__c conProd = new Contract_Product__c(Contract__c=con.Id,Product__c=prodForExisitngEvent.Id);
            insert conProd;   

            Billing_Entity__c be1 = TestObjectCreator.CreateBE();
            Billing_Entity__c be2 = TestObjectCreator.CreateBE();

            be1.name='this is the first one';
            be2.name='this is the second one';
            be2.VAT_Number__c='erere';
            insert be1;
            insert be2;

            
            //Existing contract exist
            Contract_Event__c conEvent = new Contract_Event__c(
                Contract__c=con.Id, Calculate_Arr__c=true, 
                Contract_Product__c=conProd.Id,
                Product__c= prodForExisitngEvent.Id,
                SKU__c='CORE-PRO',
                IsRecurring__c=true,  
                ARR__c=123, 
                Quantity__c=20,
                Quantity_Unit_Of_Measure__c='Seats',
                Start_Date__c=startDate,
                Billing_Entity__c=be1.Id,
                Quote_Line_Item__c=qli.Id,
                End_Date__c=endDate);
            insert conEvent;
    

            generalOpp.ContractId=con.Id;
            generalOpp.Billing_Entity__c=be1.Id;
            quotegeneraCont.Billing_Entity__c=be1.Id;
            
            update quotegeneraCont;
            update generalOpp;
            TestObjectCreator.persistImmediate = true;

            Opportunity corrrectionOppopportunity = TestObjectCreator.CreateOpp(ma);
            TestObjectCreator.persistImmediate = false;

            corrrectionOppopportunity.RecordTypeId=correctoinRecordType;
            corrrectionOppopportunity.Billing_Entity__c=be2.Id;
            update corrrectionOppopportunity;

            TestObjectCreator.persistImmediate = true;

            Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(corrrectionOppopportunity, 'New Contract');
            TestObjectCreator.persistImmediate = false;


            quoteNewCont.name='correction';
            quoteNewCont.Billing_Entity__c=be2.Id;
            update quoteNewCont;
            corrrectionOppopportunity.SyncedQuoteId=quoteNewCont.Id;
            corrrectionOppopportunity.Related_Opportunity__c=generalOpp.Id;
            update corrrectionOppopportunity;

    }

    @istest
    public static void TestCorrectionCon(){

        Billing_Entity__c be1 = [select id from Billing_Entity__c where name ='this is the first one'];
        Billing_Entity__c be2 = [select id from Billing_Entity__c where name ='this is the second one'];


        Quote q = [select id,ContractId from quote where name = 'correction' limit 1];
        Contract_Event__c coni = [select id, billing_entity__c from Contract_Event__c limit 1];
        system.assertEquals(coni.Billing_Entity__c, be1.id);//beofre the be change

        q.DH_Quote_Status__c='Won';
        q.Document_Type__c='Sales Order';
        test.startTest();
        update q;
        test.stopTest();

        Quote q1 = [select id,ContractId from quote where name = 'correction' limit 1];

        Contract_Event__c coni2 = [select id, billing_entity__c from Contract_Event__c limit 1];
        
        Contract con = [select id from contract limit 1];
        List<Contract> conts = [select id from contract];
        
        system.assertEquals(con.Id, q1.ContractId);//will not create contract
        system.assertEquals(coni2.Billing_Entity__c, be2.id);//after the be change
        system.assertEquals(1, conts.size());//should be only 1 
    }
}