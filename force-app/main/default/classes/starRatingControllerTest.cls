@isTest 
public with sharing class starRatingControllerTest {
    @IsTest
    static void test1(){
        Account a = TestObjectCreator.CreateAccount();
        a.Co_Sell_Leader__c = 'Sales';
        insert a;

        List<Opportunity> oppsList = new List<Opportunity>();
        Opportunity opp3 = TestObjectCreator.CreateOpp(a);
        insert new List<Opportunity>{opp3};

        Co_Sell_Request__c csr2 = new Co_Sell_Request__c(
            Main_Opportunity__c = opp3.Id,
            Secondary_Opportunity_Owner__c = UserInfo.getUserId(),
            Type__c = 'Create',
            Monday_Account__c = a.Id
        );
        insert csr2;
        
        Map<String,String> valuesMap = new Map<String,String>();
        valuesMap.put('Easy_to_Communicate__c', '5');
        Test.startTest();
        starRatingController.getSurveyInitData('test', true);
        starRatingController.updateValues(csr2.Id, 'Co_Sell_Request__c', valuesMap, 'Impact_Survey_Filled__c');
        Test.stopTest();
    }
}