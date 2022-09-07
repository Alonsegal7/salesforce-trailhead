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
                if (Trigger.isInsert) CalloutHandler.HandleCallout (callout_leads,'Insert',null);
                if (Trigger.isUpdate) CalloutHandler.HandleCallout (callout_leads,'Update',Trigger.oldMap);
            }
        }
    }
}