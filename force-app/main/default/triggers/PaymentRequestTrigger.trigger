trigger PaymentRequestTrigger on Payment_Request__c (before insert, before update, after update) {
    PaymentRequest_InitService initService = new PaymentRequest_InitService();
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        initService.updateStatusPicklist(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        initService.updateMDFPayReqsStatusChange(Trigger.new, Trigger.oldMap);
    }
}