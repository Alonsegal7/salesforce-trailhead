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

        List<Id> contractIdList = new List<Id>{con.Id};
        
        Test.startTest();

        System.runAs(userRecord){
            opportunity_RenewalCreation.checkOpenRenewalOpps(con.Id);
            opportunity_RenewalCreation.createRenewalOpportunities(contractIdList); 
            opportunity_RenewalCreation.checkOpenExpansionOpps(con.Id);
        }
        Test.stopTest();
        
        con = [SELECT Id, Renewal_Opportunity__c, Renewal_Opportunity_Creation_Status__c FROM Contract WHERE Id =: con.Id LIMIT 1];
        opportunity = [SELECT Id FROM Opportunity WHERE Selected_Company_Contract__c =: con.Id LIMIT 1];
        
        System.assertEquals(con.Renewal_Opportunity__c, opportunity.Id);
        System.assertEquals(con.Renewal_Opportunity_Creation_Status__c, 'Completed');
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

        List<Id> contractIdList = new List<Id>{con.Id};
        
        System.runAs(userRecord){
            opportunity_RenewalCreation.checkOpenRenewalOpps(con.Id);
            opportunity_RenewalCreation.createRenewalOpportunities(contractIdList); 
        }
    }

    public static testmethod void changeContractToMondayAccount() {
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

        TestObjectCreator.persistImmediate=false;
        Account ma2 = TestObjectCreator.CreateMondayAccount(comp);
        ma2.Active_Contract__c = con.Id;
        ma2.ARR__c = 1000;
        insert ma2;

        Account createdAcc = [select id, Renewal_Owner__c from account where arr__c=100 limit 1];
        Account createdAcc1 = [select id, Renewal_Owner__c from account where arr__c=1000 limit 1];

        System.assertEquals(userRecord.Id, createdAcc.Renewal_Owner__c);
        System.assertEquals(userRecord.Id, createdAcc1.Renewal_Owner__c);

    }
}