public without sharing class PaymentRequest_InitService {
    public void updateStatusPicklist(List<Payment_Request__c> newPaymentReqList, Map<Id,Payment_Request__c> oldPaymentReqMap){
        for(Payment_Request__c paymentReq: newPaymentReqList){
            if(oldPaymentReqMap == null || paymentReq.Status__c != oldPaymentReqMap.get(paymentReq.Id).Status__c){
                paymentReq.Status_Picklist__c = paymentReq.Status__c;
            }
        }
    }
}