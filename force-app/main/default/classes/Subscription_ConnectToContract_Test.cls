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
        Product2 prod = TestObjectCreator.CreateProductWithCode('MON-V6-PRO');
        insert prod;
        Product2 prodFree = TestObjectCreator.CreateProductWithCode('MON-V6-PRO-F');
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

        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user = new User(ProfileId=admin.Id, Alias = 'user1',Country='United Kingdom',Email='useruser@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='useruser@monday.com');
        insert user;

        List<opportunitylineitem> olis=SubscriptionPickerController.claimSubs(new list<String>{string.valueof(sub.Id)},string.valueof(opp.id), new list<String>{sub.Product_Code__c});
        map<Id,Subscription__c> subs= SubscriptionPickerController.getSubscriptions(string.valueof(opp.Id));
        map<Id,Subscription__c> claimed =SubscriptionPickerController.getClaimed(string.valueof(opp.Id));
        map<Id,Subscription__c> removed =SubscriptionPickerController.uncliamSubscriptions(new list<String>{string.valueof(sub.Id)},string.valueof(opp.Id));
        Account maOnUpdate= SubscriptionPickerController.updateMondayAccount(string.valueof(mondayAccount.Id));
        user=SubscriptionPickerController.getUserDetails(string.valueof(user.id));

    }

}