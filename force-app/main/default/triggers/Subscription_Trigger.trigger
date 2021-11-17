trigger Subscription_Trigger on Subscription__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    public List<Subscription__c> sortedSubs = new List<Subscription__c>();
    if (trigger.isBefore){  
        //Sort the subs
            if (!Trigger.isDelete) {
                sortedSubs =Subscription_ConnectToContractEvent.sortSubsByContractCreation(trigger.new);
            }
            if (trigger.isInsert){
                Subscription_ConnectToContractEvent.Subscription_ConnectToContract(sortedSubs,trigger.oldMap);
            }
            if (trigger.isUpdate){
                Subscription_ConnectToContractEvent.Subscription_ConnectToContract(sortedSubs,trigger.oldMap);
            }
    }
    if(Trigger.isAfter){
        if (Trigger.isDelete) {
            CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        }
         //Sort the subs
        if (!Trigger.isDelete) {
           sortedSubs =Subscription_ConnectToContractEvent.sortSubsByContractCreation(trigger.new);
        }
        if (trigger.isInsert) {
                CalloutHandler.HandleCallout (trigger.new,'Insert',null);
                Subscription_ConnectToContractEvent.SubscriptionToContractEvent(sortedSubs,null);
        }
        if (trigger.IsUpdate) {
                Subscription_ConnectToContractEvent.SubscriptionToContractEvent(sortedSubs,trigger.oldMap);
                CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);
        }
    }
}