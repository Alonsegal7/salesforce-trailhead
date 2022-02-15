trigger HandoverTrigger on Handover__c (after update) {
    ProjectItemService.CreateProjectItem(Trigger.new, Trigger.oldMap);
}