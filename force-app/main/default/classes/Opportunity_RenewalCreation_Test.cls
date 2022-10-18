@isTest
public with sharing class Opportunity_RenewalCreation_Test {
    @TestSetup
    static void makeData(){
        //--Users Creation
        List<User> usersToCreate = new List<User>();
        profile profileAdmin =[SELECT Id FROM Profile WHERE Name='System Administrator'];
        //create sales user 1 
        User user1 = TestUtils.getUserWithoutRole(profileAdmin);
        user1.Segment__c = 'Enterprise';
        user1.Group__c='Sales';
        user1.Business_Role__c = 'AM';
        user1.LastName = 'Test User 1';
        usersToCreate.add(user1);
        //create sales user 2 
        User user2 = TestUtils.getUserWithoutRole(profileAdmin);
        user2.Segment__c = 'SMB';
        user2.Group__c='Sales';
        user2.Business_Role__c = 'AE';
        user2.LastName = 'Test User 2';
        usersToCreate.add(user2);
        insert usersToCreate;
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        //Contract creation 
        List<Contract> contractsToCreate = new List<Contract>();
        Contract contract = TestObjectCreator.CreateContract(company);
        contract.Name = 'Test contract';
        contract.Status__c='Active';
        contract.Primary_Renewal_Owner__c = user1.Id;
        contract.Renewal_Manager__c = user1.Id;
        insert contract;
        //MA creation
        Account ma= TestObjectCreator.CreateMondayAccount(company);
        ma.Name='MA for test';
        ma.ARR__c = 150;
        ma.active_contract__c = contract.id;
        insert ma;
        //Update main monday account related on contract 
        contract.Main_Monday_Account_Related__c = ma.id;
        update contract;
    }

    @IsTest
    public static void changeRMOnContractShouldUpdateRMOnAccount() {
        Contract con = [SELECT Id,Name,Renewal_Manager__c FROM Contract WHERE Name = 'Test contract' LIMIT 1 ];
        User user2 = [SELECT Id FROM User WHERE LastName = 'Test User 2' LIMIT 1];
        Account ma = [SELECT Id, Renewal_Manager__c FROM Account WHERE ARR__c = 150 LIMIT 1];
        Test.startTest();
        con.Renewal_Manager__c = user2.Id;
        update con;
        Test.stopTest();
        con = [SELECT Id,Name,Renewal_Manager__c FROM Contract WHERE Name = 'Test contract' LIMIT 1 ];
        ma = [SELECT Id, Renewal_Manager__c FROM Account WHERE ARR__c = 150 LIMIT 1];
        System.assertEquals(con.Renewal_Manager__c, ma.Renewal_Manager__c);
    }
    @IsTest
    public static void changePROOnContractShouldUpdatePROOnAccount() {
        Contract con = [SELECT Id,Primary_Renewal_Owner__c FROM Contract WHERE Name = 'Test contract' LIMIT 1 ];
        User user2 = [SELECT Id FROM User WHERE LastName = 'Test User 2' LIMIT 1];
        Account ma = [SELECT Id, Renewal_Owner__c FROM Account WHERE ARR__c = 150 LIMIT 1];
        Test.startTest();
        con.Primary_Renewal_Owner__c = user2.Id;
        update con;
        Test.stopTest();
        con = [SELECT Id,Primary_Renewal_Owner__c FROM Contract WHERE Name = 'Test contract' LIMIT 1 ];
        ma = [SELECT Id, Renewal_Owner__c FROM Account WHERE ARR__c = 150 LIMIT 1];
        System.assertEquals(con.Primary_Renewal_Owner__c, ma.Renewal_Owner__c);

    }
    @IsTest
    public static void changeRMAndPROOnContractShouldUpdateRMAndPROOOnAccount() {
        Contract con = [SELECT Id,Primary_Renewal_Owner__c,Renewal_Manager__c FROM Contract WHERE Name = 'Test contract' LIMIT 1 ];
        User user2 = [SELECT Id FROM User WHERE LastName = 'Test User 2' LIMIT 1];
        Account ma = [SELECT Id, Renewal_Owner__c,Renewal_Manager__c FROM Account WHERE ARR__c = 150 LIMIT 1];
        System.assertNotEquals(ma.Renewal_Owner__c, user2.Id);
        System.assertNotEquals(ma.Renewal_Owner__c, user2.Id);
        Test.startTest();
        con.Primary_Renewal_Owner__c = user2.Id;
        con.Renewal_Manager__c = user2.Id;
        update con;
        Test.stopTest();
        con = [SELECT Id,Primary_Renewal_Owner__c,Renewal_Manager__c FROM Contract WHERE Name = 'Test contract' LIMIT 1 ];
        ma = [SELECT Id, Renewal_Owner__c,Renewal_Manager__c FROM Account WHERE ARR__c = 150 LIMIT 1];
        System.assertEquals(con.Primary_Renewal_Owner__c, ma.Renewal_Owner__c);
        System.assertEquals(con.Renewal_Manager__c, ma.Renewal_Manager__c);

    }

}

