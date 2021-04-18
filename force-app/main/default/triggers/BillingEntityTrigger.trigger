trigger BillingEntityTrigger on Billing_Entity__c (before insert,before update,before delete, after insert, after update, after delete, after undelete) 
{
    list <Trig_Ctrl__mdt> TrigCtrl = [select id,Billing_Entity__c from Trig_Ctrl__mdt where masterlabel=:'Setting' limit 1];
    boolean CtrlRun = false;
    if (TrigCtrl.size()==0 || (TrigCtrl.size()>0 && TrigCtrl[0].Billing_Entity__c)) CtrlRun = true;
    if (!Globals.CodeOff && CtrlRun)
    {
         if (trigger.isBefore)
         {
            if (trigger.isInsert) BillingEntityHandler.HandleBefore (trigger.new,null,'Insert');
            if (trigger.IsUpdate) BillingEntityHandler.HandleBefore (trigger.new,trigger.oldmap,'Update');
            if (trigger.isDelete) BillingEntityHandler.HandleBefore (trigger.old,null,'Delete');
            if (trigger.isUndelete) BillingEntityHandler.HandleBefore (trigger.new,null,'Undelete');
         }
    }
}