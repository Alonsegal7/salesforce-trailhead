@isTest
public with sharing class Account_syncProAssignmentTest {
    @TestSetup
    static void makeData(){
        //users creation
        List <User> usersToCreate = new List<User>();
        profile profileAdmin =[SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user1 = TestUtils.getUserWithoutRole(profileAdmin);
        user1.Group__c='Sales';
        user1.Business_Role__c = 'AE';
        usersToCreate.add(user1);
        User user2 = TestUtils.getUserWithoutRole(profileAdmin);
        user2.Group__c='Sales';
        user2.Business_Role__c = 'AM';
        usersToCreate.add(user2);
        insert usersToCreate;

        Account company = TestObjectCreator.CreateCompany();
        insert company;
        Contract contract = TestObjectCreator.CreateContract(company);
        contract.Name = 'Test contract';
        contract.Primary_Renewal_Owner__c = user1.Id;
        insert contract;
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        ma.ARR__c = 50;
        ma.active_contract__c = contract.Id;
        ma.OwnerId = user1.Id;
        insert ma;
    }

    @isTest
    static void checkThatDefinePROAssignmentCheckboxIsTrue() {
        Account ma = [SELECT Id,OwnerId FROM Account WHERE ARR__c = 50 LIMIT 1];
        Contract con = [SELECT Id, Define_Default_PRO_Assignment__c FROM Contract WHERE Name = 'Test contract' LIMIT 1 ];
        User user2 = [SELECT Id FROM User WHERE Business_Role__c = 'AM' LIMIT 1];
        system.assertEquals(con.Define_Default_PRO_Assignment__c, false); //initialy the checkbox is set to false
        ma.OwnerId= user2.Id; //change owner to user 2
        Test.startTest();
        update ma;
        Test.stopTest();
        con = [SELECT Id, Define_Default_PRO_Assignment__c FROM Contract WHERE Name = 'Test contract' LIMIT 1 ];
        system.assertEquals(con.Define_Default_PRO_Assignment__c, true); //following the logic, the define default PRO assignemnt should be true
    }
}