public with sharing class ProjectHandler {

    /*  Functions:  updateProjectFields
                    updatePostponedAge

        Purpose: Calculate how many days the Project was in Postponed Status
    */
    public static void before_updateProject(List<Project__c> projectsList, Map<Id, Project__c> oldMap){
        List<Project__c> projectToUpdate = new List<Project__c>();
        List<Project__c> postponedDates = new List<Project__c>();

        for(Project__c projects : projectsList){
            if(projects.Project_Status__c != oldMap.get(projects.Id).Project_Status__c){
                if(projects.Project_Status__c == 'Postponed' && oldMap.get(projects.Id).Project_Status__c != 'Postponed'){
                    projects.Postponed_Start_Date__c = System.now();
                    projects.Postponed_End_Date__c = null;
                }

                if(projects.Project_Status__c != 'Postponed' && oldMap.get(projects.Id).Project_Status__c == 'Postponed'){
                    projects.Postponed_End_Date__c = System.now();
                }

                if(projects.Postponed_Start_Date__c != null){
                    postponedDates.add(projects);
                }
            }

            if(projects.Project_Status__c == oldMap.get(projects.Id).Project_Status__c && projects.Project_Status__c == 'Postponed' && projects.Postponed_Counter__c != oldMap.get(projects.Id).Postponed_Counter__c){
                if(projects.Postponed_Age__c != 0 && projects.Postponed_Age__c != null){
                    projects.Postponed_Age__c += 1;
                }

                if(projects.Postponed_Age__c == 0 || projects.Postponed_Age__c == null){
                    postponedDates.add(projects);
                }
            }
        }

        if(postponedDates.size() > 0){
            updatePostponedAge(postponedDates);
        }
    }

    public static void updatePostponedAge(List<Project__c> postponedDates){
        List<Project__c> projectToUpdate = new List<Project__c>();

        for(Project__c project : postponedDates){
            Integer withoutEndDate = System.TODAY().daysBetween(project.Postponed_Start_Date__c.Date());
            Integer withEndDate = 0;
            if(project.Postponed_End_Date__c != null){
                withEndDate = project.Postponed_Start_Date__c.Date().daysBetween(project.Postponed_End_Date__c.Date());
            }

            if(project.Postponed_Age__c != 0 && project.Postponed_Age__c != null){
                if(project.Postponed_Start_Date__c != null && project.Postponed_End_Date__c == null){
                    project.Postponed_Age__c += withoutEndDate;
                }

                if(project.Postponed_Start_Date__c != null && project.Postponed_End_Date__c != null){
                    project.Postponed_Age__c += withEndDate;
                }
            }

            if(project.Postponed_Age__c == 0 || project.Postponed_Age__c == null){
                if(project.Postponed_Start_Date__c != null && project.Postponed_End_Date__c == null){
                    project.Postponed_Age__c = project.Postponed_Counter__c;
                }

                if(project.Postponed_Start_Date__c != null && project.Postponed_End_Date__c != null){
                    project.Postponed_Age__c = withEndDate;
                }
            }
            projectToUpdate.add(project);
        }
    }

    public static void before_insertProject(List<Project__c> projectList){
        for(Project__c project : projectList){
            if(project.Project_Status__c == 'Postponed'){
                project.Postponed_Start_Date__c = System.Now();
            }
        }
    }
}