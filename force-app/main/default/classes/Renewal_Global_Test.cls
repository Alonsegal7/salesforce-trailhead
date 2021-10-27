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
    
    
}