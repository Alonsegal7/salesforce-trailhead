@isTest 
public with sharing class starRatingControllerTest {
    @IsTest
    static void test1(){
        Account a = TestObjectCreator.CreateAccount();
        a.Co_Sell_Leader__c = 'Sales';
        insert a;
        user u = [select id from user where isActive = true and group__c = 'Sales' and Profile.Name = 'monday Sales - AE' limit 1];

        List<Opportunity> oppsList = new List<Opportunity>();
        Opportunity opp3 = TestObjectCreator.CreateOpp(a);
        insert new List<Opportunity>{opp3};

        Co_Sell_Request__c csr2 = new Co_Sell_Request__c(
            Main_Opportunity__c = opp3.Id,
            Secondary_Opportunity_Owner__c = u.Id,
            Type__c = 'Create',
            Monday_Account__c = a.Id
        );
        insert csr2;
        
        Map<String,String> valuesMap = new Map<String,String>();
        valuesMap.put('Easy_to_Communicate__c', '5');
        Map<String,String> openText = new Map<String,String>();
        openText.put('fieldname', 'Impact_Survey_Open_Text__c');
        openText.put('value', 'testtttt');
        Test.startTest();
        starRatingController.getSurveyInitData('test', true);
        starRatingController.updateValues(csr2.Id, 'Co_Sell_Request__c', valuesMap, openText, 'Impact_Survey_Filled__c');
        Test.stopTest();
    }
}