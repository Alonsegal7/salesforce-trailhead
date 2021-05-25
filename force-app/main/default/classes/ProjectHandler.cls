public with sharing class ProjectHandler {
    public static Set<Id> handoverIds = new Set<Id>();
    public static List<Project__c> projectsToPopulate = new List<Project__c>();
    
    public static void beforeInsert(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
        populateProjectAges(projectsList, oldMap);
    }

    public static void beforeUpdate(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
        populateProjectAges(projectsList, oldMap);
        updateProjectCounter(projectsList, oldMap);
    }

    public static void populateProjectAges(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
        List<Project__c> projectsToUpdate = new List<Project__c>();
        if(oldMap == null){
            for(Project__c project : projectsList){
                projectsToUpdate.add(project);
            } 
        }

        else{
            for(Project__c project : projectsList){
                if(project.Project_Status__c == 'Postponed' && oldMap.get(project.Id).Project_Status__c != 'Postponed'){
                    projectsToUpdate.add(project);
                }
            } 
        }

        if(projectsToUpdate != null && !projectsToUpdate.isEmpty() && projectsToUpdate.size() > 0){
            for(Project__c project : projectsToUpdate){
                if(project.Project_Status__c == 'Postponed'){
                    if(project.Postponed_Times__c == null || project.Postponed_Times__c == 0){
                        project.Postponed_Times__c = 0;
                    }
                    project.Postponed_Start_Date__c = System.now();
                    project.Postponed_End_Date__c = null;
                }
            } 
        }
    }

    public static void updateProjectCounter(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
        Integer daysEndStart = 0;

        for(Project__c project : projectsList){
            if(project.Project_Status__c != 'Postponed' && oldMap.get(project.Id).Project_Status__c == 'Postponed'){
                project.Postponed_End_Date__c = System.now();
                daysEndStart = (Date.valueOf(project.Postponed_End_Date__c)).daysBetween(Date.valueOf(project.Postponed_Start_Date__c))*(-1);
                project.Postponed_Times__c += daysEndStart;
            }
        }
    }

    // public static void before_updateProject(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
    //     List<Project__c> projectToUpdate = new List<Project__c>();
    //     List<Project__c> postponedDates = new List<Project__c>();

    //     for(Project__c project : projectsList){
    //         if(project.Project_Status__c != oldMap.get(project.Id).Project_Status__c){
    //             if(project.Project_Status__c == 'Postponed' && oldMap.get(project.Id).Project_Status__c != 'Postponed'){
    //                 if(project.Postponed_Times__c == null || project.Postponed_Times__c == 0){
    //                     project.Postponed_Times__c = 0;
    //                 }
    //                 project.Postponed_Start_Date__c = System.now();
    //                 project.Postponed_End_Date__c = null;
    //             }

    //             if(project.Project_Status__c != 'Postponed' && oldMap.get(project.Id).Project_Status__c == 'Postponed'){
    //                 project.Postponed_End_Date__c = System.now();
    //                 Integer daysEndStart = (Date.valueOf(project.Postponed_End_Date__c)).daysBetween(Date.valueOf(project.Postponed_Start_Date__c))*(-1);
    //                 project.Postponed_Times__c += daysEndStart;
    //             }
    //         }
    //     }
    // }

    // public static void before_insertProject(List<Project__c> projectList, Map<Id, Project__c> oldMap){
    //     for(Project__c project : projectList){
    //         if(project.Project_Status__c == 'Postponed'){
    //             if(project.Postponed_Times__c == null || project.Postponed_Times__c == 0){
    //                 project.Postponed_Times__c = 0;
    //             }
    //             project.Postponed_Start_Date__c = System.now();
    //             project.Postponed_End_Date__c = null;
    //         }

    //         if(project.Handover__c != null){
    //             projectsToPopulate.add(project);
    //             handoverIds.add(project.Handover__c);
    //         }
    //     }

    //     if(projectsToPopulate != null && !projectsToPopulate.isEmpty() && projectsToPopulate.size() > 0 && handoverIds != null && !handoverIds.isEmpty() && handoverIds.size() > 0){
    //         populateProjectFieldsFromHandover(projectsToPopulate, handoverIds); 
    //     }
    // }

    // public static void populateProjectFieldsFromHandover(List<Project__c> projectsToPopulate, Set<Id> handoverIds){
    //     Map<Id, Handover__c> handoversWithDetails = new Map<Id, Handover__c>(
    //         [SELECT Id, Billing_Entity__c, Extended_Hours__c, Opportunity__c, Expiration_Date__c, PS_Hours__c, PS_Start_Date__c, Price_Per_Hour_v1__c, Quote__c, Which_Solution_Account_is_Using__c
    //         FROM Handover__c WHERE Id IN: handoverIds]);

    //     for(Project__c proj : projectsToPopulate){
    //         proj.Billing_Entity__c = handoversWithDetails.get(proj.Handover__c).Billing_Entity__c;
    //     }
    // }
}