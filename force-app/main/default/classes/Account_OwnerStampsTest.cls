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
        userRecord2.ManagerId = userRecord1.Id;
        insert userRecord2;
        Account accountRecord = TestObjectCreator.CreateAccount();
        insert accountRecord;
        accountRecord.OwnerId = userRecord1.Id;
        update accountRecord; 
    }

    @isTest
    static void CheckPreviousOwnerUpdate(){
        User user1 = [select Id from User Where LastName = 'Test1' limit 1];
        User user2 = [select Id from User Where LastName = 'Test2' limit 1];
        Account acc = [select Id from Account limit 1];
        acc.OwnerId = user2.Id;
        Update acc; 
        acc = [select Id, PreviousOwner__c from Account limit 1];
        system.assertEquals(user1.Id, acc.PreviousOwner__c);
    }

    @isTest
    static void CheckBusinessRolesStamps(){
        User user1 = [select Id from User Where LastName = 'Test1' limit 1];
        User user2 = [select Id from User Where LastName = 'Test2' limit 1];
        Account acc = [select Id, AE__c from Account limit 1];
        system.assertEquals(acc.AE__c, user1.Id);
        acc.OwnerId = user2.Id;
        Update acc; 
        acc = [select Id, AE__c from Account limit 1];
        system.assertEquals(acc.AE__c, null);
    }

    @isTest
    static void checkCSMstampAdd(){
        User user2 = [select Id, ManagerId from User Where LastName = 'Test2' limit 1];
        Account acc = [select Id, CSM_Manager__c from Account limit 1];
        system.assertEquals(acc.CSM_Manager__c, null);
        
        Test.startTest();
        acc.CSM__c = user2.Id;
        update acc;
        Test.stopTest();

        acc = [select Id, CSM_Manager__c from Account limit 1];
        system.assertEquals(acc.CSM_Manager__c, user2.ManagerId);
    }

    @isTest
    static void checkCSMstampRemoval(){
        User user2 = [select Id, ManagerId from User Where LastName = 'Test2' limit 1];
        Account acc = [select Id, CSM_Manager__c from Account limit 1];
        acc.CSM__c = user2.Id;
        update acc;
        
        Test.startTest();
        acc.CSM__c = null;
        update acc;
        Test.stopTest();

        acc = [select Id, CSM_Manager__c from Account limit 1];
        system.assertEquals(acc.CSM_Manager__c, null);
    }
}