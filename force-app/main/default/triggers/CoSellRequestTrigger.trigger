trigger CoSellRequestTrigger on Co_Sell_Request__c (before update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        CoSellRequestService.postApproveActions(Trigger.new, Trigger.oldMap);
    }
}