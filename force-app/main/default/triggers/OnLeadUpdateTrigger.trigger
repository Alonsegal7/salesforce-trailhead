trigger OnLeadUpdateTrigger on Lead (after insert, after update, after delete, before insert, before update) {
    
    if(Trigger.isBefore){
        if (Trigger.isUpdate || Trigger.isInsert){ //note: the order of execution here is important, edit carefully
            Lead_MapRegions.Lead_MapRegions(Trigger.new,Trigger.oldMap);
            Lead_RelatedCompanyLogic.updateRelatedCompany(Trigger.new, Trigger.oldMap);
            Account_RegionalCompanyService.linkLeadsToExistingRegionalCompanies(Trigger.new,Trigger.oldMap);
            Lead_SetPartnerCompany.Lead_SetPartnerCompany(Trigger.new,Trigger.oldMap);
            Lead_StampsService.run(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            Partners_SharingService.createLeadShares_ManualTrigger(Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isUpdate || Trigger.isInsert){
            Partners_SharingService.createLeadShares(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            Lead_ConvertActions.postConvertActions(Trigger.new,Trigger.oldMap);
            Lead_RelatedTasks.markTasksCompleted(Trigger.new,Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        //callout to bb only for internal & partner leads
        if(Trigger.isDelete) {
            list<lead> callout_leads_del = new list<lead>();
            for(Lead l: Trigger.old){
                if(l.RecordTypeId == Utilities.internalLeadRecordTypeId || l.RecordTypeId == Utilities.partnerLeadRecordTypeId){
                    callout_leads_del.add(l);
                }
            }
            if(!callout_leads_del.isEmpty()){
                // old callouts to BB - will leave only delete to be fired from trigger 
                CalloutHandler.HandleCallout (callout_leads_del,'Delete',null);
            }
        }else if(Trigger.isInsert || Trigger.isUpdate){
            list<lead> callout_leads = new list<lead>();
            for(Lead l: Trigger.new){
                if(l.RecordTypeId == Utilities.internalLeadRecordTypeId || l.RecordTypeId == Utilities.partnerLeadRecordTypeId){
                    callout_leads.add(l);
                }
            }
            if(!callout_leads.isEmpty()){
                //if (Trigger.isInsert) CalloutHandler.HandleCallout (callout_leads,'Insert',null); // moved to BigBrain_CalloutService
                //if (Trigger.isUpdate) CalloutHandler.HandleCallout (callout_leads,'Update',Trigger.oldMap); // moved to BigBrain_CalloutService

                // new callouts to BB - we update Need_Sync_to_BB__c checkbox to true (if it was false)
                // a scheduled job collects the sobjects with Need_Sync_to_BB__c=true and sends callout to BB (async)
                BigBrain_CalloutService.markRecordsToSync(callout_leads, Trigger.oldMap, Trigger.isAfter);
            }
        }
    }
}