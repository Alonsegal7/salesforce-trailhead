trigger Subscription_Trigger on Subscription__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    Apex_Services_Status__mdt subscription_ConnectToContractEventServiceStatus = Apex_Services_Status__mdt.getInstance('Subscription_ConnectToContractEvent');
    Apex_Services_Status__mdt subscription_ConnectToContractServiceStatus = Apex_Services_Status__mdt.getInstance('Subscription_ConnectToContract');

    if (trigger.isBefore){
        if (subscription_ConnectToContractEventServiceStatus.Status__c=='Active') {
            if (trigger.isInsert){
                Subscription_ConnectToContractEvent.Subscription_ConnectToContract(trigger.new,trigger.oldMap);
            }
            if (trigger.isUpdate){
                Subscription_ConnectToContractEvent.Subscription_ConnectToContract(trigger.new,trigger.oldMap);
            }
        }
        if (subscription_ConnectToContractServiceStatus.Status__c=='Active') {
            if (trigger.isInsert){
                Subscription_ConnectToContract.Subscription_ConnectToContract(trigger.new,trigger.oldMap);
            }
            if (trigger.isUpdate){
                Subscription_ConnectToContract.Subscription_ConnectToContract(trigger.new,trigger.oldMap);
            }
        }
    }
    
    if(Trigger.isAfter){
        if (Trigger.isDelete) {
            CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        }
        if (trigger.isInsert) {
            CalloutHandler.HandleCallout (trigger.new,'Insert',null);
            if (subscription_ConnectToContractEventServiceStatus.Status__c=='Active') {
                Subscription_ConnectToContractEvent.SubscriptionToContractEvent(trigger.new,null);
            }
        }
        if (trigger.IsUpdate) {
            CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
            if (subscription_ConnectToContractEventServiceStatus.Status__c=='Active') {
                Subscription_ConnectToContractEvent.SubscriptionToContractEvent(trigger.new,trigger.oldMap);
            }
        }
    }
}