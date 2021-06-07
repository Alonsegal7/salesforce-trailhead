trigger DealRegistration_Trigger on Deal_Registration__c (after insert, before insert, before update, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DealRegistration_Handler.isBeforeInsert(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isUpdate){
            DealRegistration_Handler.isBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            DealRegistration_Handler.isAfter(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isUpdate){
            DealRegistration_Handler.isAfter(Trigger.new, Trigger.oldMap);
        }
    }
}