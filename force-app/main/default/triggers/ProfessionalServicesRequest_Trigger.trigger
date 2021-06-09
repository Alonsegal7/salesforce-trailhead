trigger ProfessionalServicesRequest_Trigger on Professional_Service_Request__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            ProfessionalServicesRequest_Handler.isBefore(Trigger.new);
        }

        if(Trigger.isInsert){
            ProfessionalServicesRequest_Handler.isBefore(Trigger.new);
        }
        
    }
}