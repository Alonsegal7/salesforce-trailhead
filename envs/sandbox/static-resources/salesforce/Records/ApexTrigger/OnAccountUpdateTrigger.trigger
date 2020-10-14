trigger OnAccountUpdateTrigger on Account (before insert,before update,before delete, after insert, after update, after delete, after undelete) {	
    // list <Trig_Ctrl__mdt> TrigCtrl = [select id,account__c from Trig_Ctrl__mdt where masterlabel=:'Setting' limit 1];
    // boolean CtrlRun = false;
    // if (TrigCtrl.size()==0 || (TrigCtrl.size()>0 && TrigCtrl[0].account__c)) CtrlRun = true;
    // if (!Globals.CodeOff && CtrlRun)
    // 
    if (!Globals.CodeOff)
    {
         if (trigger.isBefore)
         {
            if (trigger.isInsert) MondayAccountHelper.HandleBefore(trigger.new, null, 'Insert');
            if (trigger.IsUpdate) MondayAccountHelper.HandleBefore(trigger.new, trigger.oldmap, 'Update');
            if (trigger.isDelete) MondayAccountHelper.HandleBefore(trigger.old, null, 'Delete');
            if (trigger.isUndelete) MondayAccountHelper.HandleBefore(trigger.new, null, 'Undelete');
         }
     
        if (trigger.isAfter)
        {
            if (trigger.isDelete) {
                MondayAccountHelper.HandleAfter(trigger.old, null);  
            } else { 
                MondayAccountHelper.HandleAfter(trigger.new, trigger.oldmap);
            }
        }
    }
    if (Trigger.isBefore) {
        if (trigger.isInsert||trigger.IsUpdate){
            Account_MapRegions.Account_MapRegions (trigger.new,trigger.oldmap);

        }
    }
    if (Trigger.isAfter) {
        if(trigger.isInsert){
            Account_SetCompanyDomains.Account_SetCompanyDomains(trigger.new,trigger.oldmap);
        }
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
    }
    
   	/*
     * Old code before BE change - left here for reverting 25/02/2020 @amiel
    if(Trigger.isUpdate && Trigger.isAfter){
        Account oldAccount = null;
        Account newAccount = null;
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        for(Id accountId : Trigger.newMap.keySet()){
            oldAccount = Trigger.oldMap.get( accountId );
            newAccount = Trigger.newMap.get( accountId );
            if (newAccount.RecordTypeId == recordTypeId && (
                    newAccount.ParentId != oldAccount.ParentId ||
                    newAccount.primary_pulse_account_id__c != oldAccount.primary_pulse_account_id__c)){
            	MondayAccountHelper.handleChange(newAccount);
            }
        }
    }

	 if(Trigger.isBefore){
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        
        for(Account acc : Trigger.new){
            if(acc.RecordTypeId == companyRecordTypeId && (acc.Company_Id__c == null || acc.Company_Id__c == '')){
                acc.Company_Id__c = acc.Name;                 
            }
        }
    }
*/
}