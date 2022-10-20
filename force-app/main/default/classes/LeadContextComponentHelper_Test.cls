@istest
public without sharing class LeadContextComponentHelper_Test {

    @isTest
    static void getUserIdTest(){
        Test.startTest();

        User testUser = [SELECT Id, Name FROM User WHERE Name != null LIMIT 1];
        //The test user dont have name beacuse we cant set a name this is why the expected result is empty list
        System.assertEquals(LeadContextComponentHelper.getUserId(testUser.Name)[0].Id, testUser.Id);
        Test.stopTest();
    }
}
