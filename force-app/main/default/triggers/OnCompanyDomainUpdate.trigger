trigger OnCompanyDomainUpdate on Company_Domain__c (before insert,before update,before delete, after insert, after update, after delete) {
    
    if (Trigger.isBefore) {
        if (trigger.isInsert||trigger.IsUpdate){
            CompanyDomain_Service.validateFormat(trigger.new);
        }
    }

    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
}