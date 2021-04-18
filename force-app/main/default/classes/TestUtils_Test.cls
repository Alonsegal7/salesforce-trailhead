@isTest
private class TestUtils_Test {
    @isTest static void getUserWithoutRole(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userRecord = TestUtils.getUserWithoutRole(profileId);      
    }
    
    @isTest static void getProject(){
        Project__c projectRecord = TestUtils.getProject('Test Project', 'Test Project Type', 'Open');      
    }
}