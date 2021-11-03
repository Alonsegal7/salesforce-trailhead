trigger PaymentRequestTrigger on Payment_Request__c (before insert, before update) {
    PaymentRequest_InitService initService = new PaymentRequest_InitService();
    initService.updateStatusPicklist(Trigger.new, Trigger.oldMap);
}