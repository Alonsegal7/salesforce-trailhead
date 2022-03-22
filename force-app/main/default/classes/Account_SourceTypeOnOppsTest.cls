@isTest
public without sharing class Account_SourceTypeOnOppsTest {
    @TestSetup
    static void makeData(){
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Account a = TestObjectCreator.CreateAccount();
        a.RecordTypeId = MARecordTypeId;
        a.Account_Source_Type__c = 'Inbound';
        insert a;
        Opportunity opp1 = TestObjectCreator.CreateOpp(a);
        insert opp1;
    }

    static testmethod void test1(){
        Account a = [select Id from Account limit 1];
        a.Account_Source_Type__c = 'Outbound';
        update a;
    }
}
