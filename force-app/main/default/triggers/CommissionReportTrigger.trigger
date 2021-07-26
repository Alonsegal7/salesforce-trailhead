trigger CommissionReportTrigger on Commission_Report__c (after insert, after update, after delete) {
    if(Trigger.isAfter && Trigger.isInsert){
        PartnerCommissionService commissionHandler = new PartnerCommissionService();
        commissionHandler.connectNewReportsToCollectionsCommitments(Trigger.new);
    }
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
}