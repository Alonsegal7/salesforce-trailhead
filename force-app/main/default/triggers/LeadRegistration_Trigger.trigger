trigger LeadRegistration_Trigger on Lead_Registration__c (after insert, before insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            system.debug('### trigger before');
            LeadRegistration_Handler.isBeforeInsert(Trigger.new, Trigger.oldMap);
            // LeadRegistration_Handler.validateLeadRegistration_Test(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            system.debug('### trigger after');
            LeadRegistration_Handler.isAfterInsert(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isUpdate){
            system.debug('### trigger after update');
            LeadRegistration_Handler.isAfterInsert(Trigger.new, Trigger.oldMap);
        }
    }
}