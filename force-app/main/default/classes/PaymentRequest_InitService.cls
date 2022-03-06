public without sharing class PaymentRequest_InitService {
    //runs in before insert & update trigger
    public void updateStatusPicklist(List<Payment_Request__c> newPaymentReqList, Map<Id,Payment_Request__c> oldPaymentReqMap){
        for(Payment_Request__c paymentReq: newPaymentReqList){
            if(oldPaymentReqMap == null || paymentReq.Status__c != oldPaymentReqMap.get(paymentReq.Id).Status__c){
                paymentReq.Status_Picklist__c = paymentReq.Status__c;
            }
        }
    }

    //when payment request status updates we look for all related MDF payment requests and update the status there too
    //the payment request status is not a formula on MDF payment request b/c we need to use a condition on the status for 
    //a rollup summary of the MDF pay req amount for Marketing activities
    //runs in after update trigger
    public void updateMDFPayReqsStatusChange(List<Payment_Request__c> newPaymentReqs_list, Map<Id,Payment_Request__c> oldPaymentReqs_map){ 
        Map<Id, Payment_Request__c> payReqs_map = new Map<Id, Payment_Request__c>();
        for(Payment_Request__c payReq: newPaymentReqs_list){
            if(payReq.Status__c != oldPaymentReqs_map.get(payReq.Id).Status__c){
                payReqs_map.put(payReq.Id, payReq);
            }
        }
        if(payReqs_map.isEmpty()) return;
        List<MDF_Payment_Portion__c> mdfPayReq_list = [select Id, Payment_Request__c from MDF_Payment_Portion__c where Payment_Request__c in: payReqs_map.keySet()];
        if(mdfPayReq_list.isEmpty()) return;
        for(MDF_Payment_Portion__c mdfPayReq: mdfPayReq_list){
            mdfPayReq.Payment_Request_Status__c = payReqs_map.get(mdfPayReq.Payment_Request__c).Status__c;
        }
        Database.update(mdfPayReq_list);
    }
}