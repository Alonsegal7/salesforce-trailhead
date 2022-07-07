@isTest
public without sharing class Account_selectCSMChampsTest {
    @TestSetup
    static void makeData(){
        TestObjectCreator.persistImmediate = true;
        account acc = TestObjectCreator.CreateAccount();
        Contact con = new Contact(
            Email='test@monday.com', 
            LastName = 'test',
            CSM_Champion__c = true, 
            AccountId = acc.Id);
        insert con;
    }

    static testmethod void test_getAllContacts(){
        account acc = [select Id from Account limit 1];
        Account_selectCSMChamps.getAllContacts(acc.Id);
    }

    static testmethod void test_saveContacts1(){
        contact con = [select Id from contact limit 1];
        Map<String,List<Id>> testMap = new Map<String,List<Id>>();
        testMap.put('originally_selected', null);
        testMap.put('currently_selected', new list<id>{con.Id});
        Account_selectCSMChamps.saveContacts(testMap);
    }

    static testmethod void test_saveContacts2(){
        contact con = [select Id from contact limit 1];
        Map<String,List<Id>> testMap = new Map<String,List<Id>>();
        testMap.put('originally_selected', new list<id>{con.Id});
        testMap.put('currently_selected', null);
        Account_selectCSMChamps.saveContacts(testMap);
    }
}