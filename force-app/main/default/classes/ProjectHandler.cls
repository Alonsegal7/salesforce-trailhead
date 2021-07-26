public with sharing class ProjectHandler {
    public static Set<Id> handoverIds = new Set<Id>();
    public static List<Project__c> projectsToPopulate = new List<Project__c>();
    
    public static void beforeInsert(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
        populatePostponedTimestamps(projectsList, oldMap);
        popualteProjectStartDate(projectsList, oldMap);
    }

    public static void beforeUpdate(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
        populatePostponedTimestamps(projectsList, oldMap);
        updateProjectCounter(projectsList, oldMap);
        popualteProjectStartDate(projectsList, oldMap);
    }

    public static void populatePostponedTimestamps(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
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

    public static void popualteProjectStartDate(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
        List<Project__c> projectsToUpdate = new List<Project__c>();
        if(oldMap == null){
            for(Project__c project : projectsList){
                if(project.Project_Status__c == 'Postponed' && project.Kickoff_Date__c == null){
                    project.Kickoff_Date__c = System.today();
                    projectsToUpdate.add(project);
                    system.debug('### project.Kickoff_Date__c: ' + project.Kickoff_Date__c);
                }
            } 
        }

        else{
            for(Project__c project : projectsList){
                if(project.Project_Status__c == 'Postponed' && project.Kickoff_Date__c == null){
                    project.Kickoff_Date__c = System.today();
                    projectsToUpdate.add(project);
                }

                else if(project.Project_Status__c == 'Postponed' && project.Kickoff_Date__c != null){
                    if(project.Kickoff_Date__c > System.today()){
                        project.Kickoff_Date__c = System.today();
                        projectsToUpdate.add(project);
                    }
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
}