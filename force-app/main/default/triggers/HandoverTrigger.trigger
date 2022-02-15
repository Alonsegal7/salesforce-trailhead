trigger HandoverTrigger on Handover__c (after update) {
    if(ProjectItemService.firstRun){
    ProjectItemService.CreateProjectItem(Trigger.new, Trigger.oldMap);
    }
}