@isTest
public without sharing class PartnerMarketingActivity_Test {
    static testmethod void test1(){
        Id partnerCompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Account partnerAcc = TestObjectCreator.CreateAccount();
        partnerAcc.RecordTypeId = partnerCompanyRecordTypeId;
        insert partnerAcc;
        Partner_Marketing_Activity__c pma = new Partner_Marketing_Activity__c(
            Name = 'Test',
            Channel_Partner__c = partnerAcc.Id
        );
        insert pma;
    }
}