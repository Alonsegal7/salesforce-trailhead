trigger ContractEventTrigger on Contract_Event__c (before insert, before update, after update, after insert, after delete) {
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) {
            CalloutHandler.HandleCallout (trigger.new,'Insert',null);
            ContractStatusService.handleContractAndContractProductStatus(trigger.new,null);
        }
        if (trigger.IsUpdate){
            CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
            ContractStatusService.handleContractAndContractProductStatus(trigger.new,trigger.oldmap);
        } 
    }
}