@isTest
public with sharing class Account_OwnerStampsTest {
    @TestSetup
    static void makeData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userRecord1 = TestUtils.getUserWithoutRole(profileId);
        userRecord1.LastName = 'Test1';
        userRecord1.Group__c = 'Sales';
        userRecord1.Business_Role__c = 'AE';
        userRecord1.Seniority__c = 'Rep';
        userRecord1.Function__c = 'Enterprise AE';
        userRecord1.Created_date__c = date.today();
        User userRecord2 = TestUtils.getUserWithoutRole(profileId);
        userRecord2.LastName='Test2';
        userRecord2.Business_Role__c='Scale CSM';
        userRecord2.Group__c = 'CSG';
        insert userRecord1;
        insert userRecord2;
        Account accountRecord = TestObjectCreator.CreateAccount(); //new Account (Name = 'AccTest', OwnerId = userRecord1.Id);
        insert accountRecord;
        accountRecord.OwnerId = userRecord1.Id;
        update accountRecord; 
    }

    static testMethod void CheckPreviousOwnerUpdate(){
        User user1 = [select Id from User Where LastName = 'Test1' limit 1];
        User user2 = [select Id from User Where LastName = 'Test2' limit 1];
        Account acc = [select Id from Account limit 1];
        acc.OwnerId = user2.Id;
        Update acc; 
        acc = [select Id, PreviousOwner__c from Account limit 1];
        system.assertEquals(user1.Id, acc.PreviousOwner__c);
    }

    static testMethod void CheckBusinessRolesStamps(){
        User user1 = [select Id from User Where LastName = 'Test1' limit 1];
        User user2 = [select Id from User Where LastName = 'Test2' limit 1];
        Account acc = [select Id, AE__c from Account limit 1];
        system.assertEquals(acc.AE__c, user1.Id);
        acc.OwnerId = user2.Id;
        Update acc; 
        acc = [select Id, AE__c from Account limit 1];
        system.assertEquals(acc.AE__c, null);
    }
}