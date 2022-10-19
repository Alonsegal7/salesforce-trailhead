@isTest 
public with sharing class Contract_syncProAssignmentTest {
        @TestSetup
        static void makeData(){
            //users creation
            profile profileAdmin =[SELECT Id FROM Profile WHERE Name='System Administrator'];
            User user1 = TestUtils.getUserWithoutRole(profileAdmin);
            user1.Group__c='Sales';
            user1.Business_Role__c = 'AE';
            insert user1;
            //date ranges
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
            contract1.Last_Event_Payment_Method__c = 'CC';
            contractsToCreate.add(contract1);
            Contract contract2 = TestObjectCreator.CreateContract(company);
            contract2.Name = 'Test contract 2';
            contract2.Primary_Renewal_Owner__c = user1.Id;
            contract2.EndDate = dateNotInQ12022;
            contract2.Last_Event_Payment_Method__c = 'CC';
            contractsToCreate.add(contract2);
            insert contractsToCreate;
        } 
    
        @isTest
        static void checkThatDefinePROAssignmentCheckboxIsTrue() {
            Contract con = [SELECT Id,Define_Default_PRO_Assignment__c FROM Contract WHERE Name ='Test contract 1'];
            system.assertEquals(con.Define_Default_PRO_Assignment__c, false); //initialy the checkbox is set to false
            con.Last_Event_Payment_Method__c= 'WIRE'; //change payment method to Wire
            Test.startTest();
            update con;
            Test.stopTest();
            con = [SELECT Id, Define_Default_PRO_Assignment__c FROM Contract WHERE Name = 'Test contract 1' LIMIT 1 ];
            system.assertEquals(con.Define_Default_PRO_Assignment__c, true); //following the logic, the define default PRO assignemnt should be true
        }
    
        @isTest
        static void checkThatDefinePROAssignmentCheckboxIsNotChanging() {
            Contract con = [SELECT Id,Define_Default_PRO_Assignment__c FROM Contract WHERE Name ='Test contract 2'];
            system.assertEquals(con.Define_Default_PRO_Assignment__c, false); //initialy the checkbox is set to false
            con.Last_Event_Payment_Method__c= 'WIRE'; //change payment method to Wire
            Test.startTest();
            update con;
            Test.stopTest();
            //the contract date is not in Q1 checkbox should not change to true
            con = [SELECT Id, Define_Default_PRO_Assignment__c FROM Contract WHERE Name = 'Test contract 2' LIMIT 1 ];
            system.assertEquals(con.Define_Default_PRO_Assignment__c, false); //following the logic, the define default PRO assignemnt should be true
        }

    }

