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
        date dateInQ12022 = date.newInstance(2023, 01, 21);
        date dateNotInQ12022 = date.newInstance(2023, 04, 21);
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        //contract creation
        List <Contract> contractsToCreate = new List <Contract> ();
        Contract contract1 = TestObjectCreator.CreateContract(company);
        contract1.Name = 'Test contract 1';
        contract1.Primary_Renewal_Owner__c = user1.Id;
        contract1.EndDate = dateInQ12022;
        contractsToCreate.add(contract1);
        Contract contract2 = TestObjectCreator.CreateContract(company);
        contract2.Name = 'Test contract 2';
        contract2.Primary_Renewal_Owner__c = user1.Id;
        contract2.EndDate = dateNotInQ12022;
        contractsToCreate.add(contract2);
        insert contractsToCreate;
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        ma.ARR__c = 50;
        ma.active_contract__c = contract1.Id;
        ma.OwnerId = user1.Id;
        insert ma;
    } 

    @isTest
    static void checkThatDefinePROAssignmentCheckboxIsTrue() {
        Account ma = [SELECT Id,OwnerId FROM Account WHERE ARR__c = 50 LIMIT 1];
        Contract con = [SELECT Id,Define_Default_PRO_Assignment__c FROM Contract WHERE Name ='Test contract 1'];
        User user2 = [SELECT Id FROM User WHERE Business_Role__c = 'AM' LIMIT 1];
        system.assertEquals(con.Define_Default_PRO_Assignment__c, false); //initialy the checkbox is set to false
        ma.OwnerId= user2.Id; //change owner to user 2
        Test.startTest();
        update ma;
        Test.stopTest();
        con = [SELECT Id, Define_Default_PRO_Assignment__c FROM Contract WHERE Name = 'Test contract 1' LIMIT 1 ];
        system.assertEquals(con.Define_Default_PRO_Assignment__c, true); //following the logic, the define default PRO assignemnt should be true
    }

    @isTest
    static void checkThatDefinePROAssignmentCheckboxIsNotChanging() {
        Account ma = [SELECT Id,OwnerId,active_contract__c FROM Account WHERE ARR__c = 50 LIMIT 1];
        Contract con = [SELECT Id,Define_Default_PRO_Assignment__c FROM Contract WHERE Name ='Test contract 2'];
        User user2 = [SELECT Id FROM User WHERE Business_Role__c = 'AM' LIMIT 1];
        system.assertEquals(con.Define_Default_PRO_Assignment__c, false); //initialy the checkbox is set to false
        ma.active_contract__c= con.id;
        ma.OwnerId= user2.Id; //change owner to user 2
        Test.startTest();
        update ma;
        Test.stopTest();
        //the contract date is not in Q1 checkbox should not change tp true
        con = [SELECT Id, Define_Default_PRO_Assignment__c FROM Contract WHERE Name = 'Test contract 2' LIMIT 1 ];
        system.assertEquals(con.Define_Default_PRO_Assignment__c, false); //following the logic, the define default PRO assignemnt should be true
    }
}