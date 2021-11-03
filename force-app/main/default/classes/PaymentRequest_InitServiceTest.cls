@isTest
public without sharing class PaymentRequest_InitServiceTest {
    @TestSetup
    static void makeData(){
        Payment_Request__c newreq = new Payment_Request__c();
        newreq.Status__c = 'Draft';
        newreq.Name = 'test';
        newreq.Month__c = Date.today();
        insert newreq;
    }

    @IsTest
    static void testStatusPicklist(){
        List<Payment_Request__c> paymentReqs = [select Status_Picklist__c from Payment_Request__c];
        Test.startTest();
        for(Payment_Request__c paymentReq: paymentReqs){
            System.assertEquals('Draft', paymentReq.Status_Picklist__c);
        }
        Test.stopTest();
        
    }
}