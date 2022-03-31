public without sharing class Project_ProjectStamps {
    public static List<Project__c> Project_HealthscoreStamp(List<Project__c> projectList) {
        Set<Id> accountIdsList = new Set<Id>();
        for (Project__c p : projectList) {
            accountIdsList.add(p.monday_Account__c);
        }
        Map<Id,Account> relatedAccountMap = new Map<Id,Account>([SELECT Id,Health_Score__c FROM Account WHERE Id IN: accountIdsList]);
        for (Project__c p : projectList) {
            if (p.monday_Account__c != null && relatedAccountMap.get(p.monday_Account__c).Health_Score__c != null) {
                p.Health_Score_30_Days_Stamp__c =relatedAccountMap.get(p.monday_Account__c).Health_Score__c;     
            }
        }
        try {
            update projectList ;
        } catch (Exception e) {
            System.debug('Project_ProjectStamps failed to update Project_HealthscoreStamp '+e.getMessage());
            
        }  
        return projectList ;
    } 
}


