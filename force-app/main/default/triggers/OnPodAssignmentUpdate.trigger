trigger OnPodAssignmentUpdate on Pod_Assignment__c (before insert,before update) {
    if (Trigger.isBefore) {
        if(Trigger.isInsert){
            PodAssignmentsHelper.definePodLeadManagerForSales(Trigger.new, Trigger.oldMap);
            PodAssignmentsHelper.definePodLeadManagerForPartners(Trigger.new, Trigger.oldMap);
          }
        if(Trigger.isUpdate){
            PodAssignmentsHelper.renewalManagerAssignmentActions(Trigger.new, Trigger.oldMap);
            
        }
    }
}

