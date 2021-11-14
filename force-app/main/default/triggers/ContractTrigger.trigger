trigger ContractTrigger on Contract (before insert, before update, after update, after insert, after delete)  {
    if(Trigger.isBefore && Trigger.isUpdate){
        ContractEventToContract.updateContractArrChangeToOpenOps(Trigger.new, Trigger.oldMap);
        Opportunity_RenewalCreation.updateRelatedRenewalOpportunities(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (Trigger.isUpdate){
            CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
            Opportunity_RenewalCreation.updateRelatedRecordsFields(Trigger.oldMap, Trigger.newMap);
        }
    }
}