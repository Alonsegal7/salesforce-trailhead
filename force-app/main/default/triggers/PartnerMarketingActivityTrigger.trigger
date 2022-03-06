trigger PartnerMarketingActivityTrigger on Partner_Marketing_Activity__c (after insert, after update) {
    PartnerMarketingActivity_PortionsService.createPortions(Trigger.new, Trigger.oldMap);
}