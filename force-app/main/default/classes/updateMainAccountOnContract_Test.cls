@isTest
public with sharing class updateMainAccountOnContract_Test {
    @TestSetup
    static void makeData(){
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        Contract contract1 = TestObjectCreator.CreateContract(company);
        contract1.Name = 'Test contract 1';
        insert contract1;
        Contract contract2 = TestObjectCreator.CreateContract(company);
        contract2.Name = 'Test contract 2';
        insert contract2;
        Account ma1 = TestObjectCreator.CreateMondayAccount(company);
        ma1.ARR__c = 50;
        ma1.active_contract__c = contract1.id;
        insert ma1;
        Account ma2 = TestObjectCreator.CreateMondayAccount(company);
        ma2.ARR__c = 100;
        ma2.active_contract__c = contract1.id;
        insert ma2;
        contract1.Main_Monday_Account_Related__c = ma2.id;
        update contract1;
    }

    @isTest
    static void checkMainAccountOnContractWhenARRChanges() {
        Account ma1 = [SELECT Id, ARR__c, active_contract__c FROM Account WHERE ARR__c = 50 LIMIT 1 ];
        Account ma2 = [SELECT Id, ARR__c, active_contract__c FROM Account WHERE ARR__c = 100 LIMIT 1 ];
        Contract con = [SELECT Id, Main_Monday_Account_Related__c FROM Contract WHERE Name = 'Test contract 1' LIMIT 1 ];
        system.assertEquals(con.Main_Monday_Account_Related__c, ma2.id); //initialy the main monday account on the contract is ma2
        ma1.ARR__c = 150; //make ma1 the ma with highest ARR
        Test.startTest();
        update ma1;
        Test.stopTest();
        con = [SELECT Id, Main_Monday_Account_Related__c FROM Contract LIMIT 1 ];
        system.assertEquals(con.Main_Monday_Account_Related__c, ma1.Id); //following the logic, the main monday account on the contract is ma1
    }
    
    @isTest
    static void checkMainAccountOnContractWhenCurrentContractChanges() {
        Account ma1 = [SELECT Id, ARR__c, active_contract__c FROM Account WHERE ARR__c = 50 LIMIT 1 ];
        Contract contract2 = [SELECT Id, Main_Monday_Account_Related__c FROM Contract WHERE Name ='Test contract 2' LIMIT 1 ];
        system.assertEquals(contract2.Main_Monday_Account_Related__c, null);
        ma1.active_contract__c = contract2.Id;
        Test.startTest();
        update ma1;
        Test.stopTest();
        contract2 = [SELECT Id, Main_Monday_Account_Related__c FROM Contract WHERE Name ='Test contract 2' LIMIT 1 ];
        system.assertEquals(contract2.Main_Monday_Account_Related__c, ma1.Id);
    }
}
