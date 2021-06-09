public with sharing class ProfessionalServicesRequest_Handler {
    public static void isBefore(List<Professional_Service_Request__c> profList){
        List<String> profRequest = new List<String>();
    
        for(Professional_Service_Request__c p : profList){
            if(p.Project__c != null){
                p.Project_Id__c = p.Project__c;
            }
            profRequest.add(p.Project_Id__c);
        }
        
        List<Project__c> proj = [SELECT Id FROM Project__c WHERE id IN: profRequest];

        for(Professional_Service_Request__c prof : profList){
            for(Project__c projUpdate : proj){
                prof.Project__c = projUpdate.Id;
            }
        }
    }
}