trigger CoSellRequestTrigger on Co_Sell_Request__c (before update, before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        if(UserInfo.getProfileId() != '00e1t000001bu2uAAA' /*Admins*/ && !CoSellRequestService.insertFromCode){
            for(Co_Sell_Request__c cr: Trigger.new){
                cr.addError('Co-Sell requests should be created from "Submit Co-Sell Request" button on Opportunity record page.');
            }
        }
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        CoSellRequestService.postApproveActions(Trigger.new, Trigger.oldMap);
    }
}