trigger OnLeadUpdateTrigger on Lead (after insert, after update, after delete, before insert, before update) {
	LeadTriggerHandlerWithoutSharing handlerLeadWithoutSharing = new LeadTriggerHandlerWithoutSharing();
    
    if(Trigger.isBefore){
        if (trigger.isInsert||trigger.IsUpdate){
            Lead_MapRegions.Lead_MapRegions(trigger.new,trigger.oldmap);
            Lead_SetPartnerCompany.Lead_SetPartnerCompany(trigger.new,trigger.oldmap);
            //Lead_ComapnyCreation.Lead_ComapnyCreation(trigger.new,trigger.oldmap);
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        handlerLeadWithoutSharing.afterInsert(Trigger.oldMap, Trigger.newMap);
    }
	
    if(Trigger.isAfter){
        if(Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        // Mark all related tasks as Completed when Lead is Unqualified
        Set<Id> leadIdsToCompleteTasks = new Set<Id>();
        
        for(Id leadId : Trigger.newMap.keySet()){
            Lead oldLead = Trigger.oldMap.get( leadId );
            Lead newLead = Trigger.newMap.get( leadId );
            
            if(newLead != null && oldLead != null && oldLead.Status != newLead.Status && newLead.Status == 'Unqualified'){
                leadIdsToCompleteTasks.add(newLead.Id);
            }
            
            if (newLead.IsConverted == true && oldLead.IsConverted == false){
                LeadConvert.handle(newLead);
            }
        }

        if(leadIdsToCompleteTasks.size() > 0){
            Task[] tasks = [SELECT Id, Status from Task WHERE WhoId=:leadIdsToCompleteTasks];
            for (Task t : tasks) { t.Status = 'Completed'; }
            update tasks;
        }
    }
}