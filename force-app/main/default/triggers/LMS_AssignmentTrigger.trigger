trigger LMS_AssignmentTrigger on LMS_Assignment__c  (before insert,before update,before delete, after insert, after update, after delete, after undelete) 
{
    list <Trig_Ctrl__mdt> TrigCtrl = [select id, LMS_Assignment__c from Trig_Ctrl__mdt where masterlabel=:'Setting' limit 1];
    boolean CtrlRun = false;
    if (TrigCtrl.size()==0 || (TrigCtrl.size()>0 && TrigCtrl[0].LMS_Assignment__c)) CtrlRun = true;
    if (!Globals.CodeOff && CtrlRun){
         if (trigger.isBefore){
            if (trigger.isInsert) LMS_AssignmentHandler.HandleBefore (trigger.new, null, 'Insert');
            if (trigger.IsUpdate) LMS_AssignmentHandler.HandleBefore (trigger.new, trigger.oldmap, 'Update');
            if (trigger.isDelete) LMS_AssignmentHandler.HandleBefore (trigger.old, null, 'Delete');
            if (trigger.isUndelete) LMS_AssignmentHandler.HandleBefore (trigger.new, null, 'Undelete');
         }
		 if (Trigger.isAfter){
			if (Trigger.isDelete) LMS_AssignmentHandler.HandleAfter (trigger.old); else LMS_AssignmentHandler.HandleAfter (trigger.new);
		 }
    }
}