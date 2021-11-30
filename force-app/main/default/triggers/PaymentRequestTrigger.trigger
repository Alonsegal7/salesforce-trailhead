trigger PaymentRequestTrigger on Payment_Request__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        PaymentRequest_InitService initService = new PaymentRequest_InitService();
        initService.updateStatusPicklist(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        Partners_SharingService.createPaymentRequestShares(Trigger.new, Trigger.oldMap);
    }
}