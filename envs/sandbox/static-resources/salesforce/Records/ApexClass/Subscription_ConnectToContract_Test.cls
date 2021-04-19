@isTest
public class Subscription_ConnectToContract_Test {
    @isTest (seealldata = false)
    static void subscriptionCreation_Test(){
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        Account mondayAccount = TestObjectCreator.CreateMondayAccount(company);
        mondayAccount.primary_pulse_account_id__c='12345';
        insert mondayAccount;
        Subscription__c sub = TestObjectCreator.CreateSubscription();
        insert sub;
        sub=[select id,Product_Code__c from Subscription__c where id=:sub.id];
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAccount);
        insert opp;
        Product2 prod = TestObjectCreator.CreateProductWithCode('MON-V8-PRO');
        insert prod;
        Product2 prodFree = TestObjectCreator.CreateProductWithCode('MON-V8-PRO-F');
        insert prodFree;
        Pricebook2 pb = TestObjectCreator.CreatePricebook();
        insert pb;
        PricebookEntry pbe1 = TestObjectCreator.CreatePricebookEntry(prod,1);
        insert pbe1;
        PricebookEntry pbe2 = TestObjectCreator.CreatePricebookEntry(prodFree,1);
        insert pbe2;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.id,
                                                    Product2Id = prod.Id,
                                                    UnitPrice = 1,
                                                    UseStandardPrice = false,
                                                    IsActive = true,CurrencyIsoCode='USD');
        insert pbe;
        PricebookEntry pbeFree = new PricebookEntry(Pricebook2Id = pb.id,
                                                    Product2Id = prodFree.Id,
                                                    UnitPrice = 1,
                                                    UseStandardPrice = false,
                                                    IsActive = true,CurrencyIsoCode='USD');
        insert pbeFree;
        List<opportunitylineitem> olis=SubscriptionPickerController.claimSubs(new list<String>{string.valueof(sub.Id)},string.valueof(opp.id), new list<String>{sub.Product_Code__c});
        map<Id,Subscription__c> subs= SubscriptionPickerController.getSubscriptions(string.valueof(opp.Id));
        map<Id,Subscription__c> claimed =SubscriptionPickerController.getClaimed(string.valueof(opp.Id));
    }

}