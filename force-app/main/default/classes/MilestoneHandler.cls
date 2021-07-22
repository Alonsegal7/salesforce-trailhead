public with sharing class MilestoneHandler {

    /*public static void beforeInsert(List<Milestone__c> milestoneList, Map<Id, Milestone__c> oldMilestoneMap){
        updateMilestoneName(milestoneList, oldMilestoneMap);
    }*/

    public static void afterInsert(Map<Id, Milestone__c> milestoneMap, Map<Id, Milestone__c> oldMilestoneMap){
        //updateProjectStartDate(milestoneMap, oldMilestoneMap);
        updateProjectFields(milestoneMap, oldMilestoneMap);
    }

    /*public static void updateMilestoneName(List<Milestone__c> milestoneList, Map<Id, Milestone__c> oldMilestoneMap){
        String milestoneName = '';
        Integer sessionMilestoneDay = 0;
        Integer sessionMilestoneMonth = 0;
        Integer sessionMilestoneYear = 0;
        Integer kickoffMilestoneMonth = 0;
        Decimal quarter = 0;
        Set<Id> projId = new Set<Id>();
        List<Project__c> projectList = new List<Project__c>();

        for(Milestone__c m : milestoneList){
            projId.add(m.Project__c);
        }

        for(Project__c p : [SELECT Id, Of_Session_Milestones__c FROM Project__c WHERE Id IN: projId]){
            projectList.add(p);
        }

        if (oldMilestoneMap != null){
            for (Milestone__c mile : milestoneList) {
                for(Project__c proj : projectList){
                    system.debug('### proj: ' + proj);
                    system.debug('### mile: ' + mile);
                    system.debug('### mile.Session_Due_Date__c: ' + mile.Session_Due_Date__c);
                    system.debug('### oldMilestoneMap.get(mile.Id).Session_Due_Date__c: ' + oldMilestoneMap.get(mile.Id).Session_Due_Date__c);
                    if(mile.Project__c == proj.Id && mile.Session_Due_Date__c != oldMilestoneMap.get(mile.Id).Session_Due_Date__c){
                        sessionMilestoneDay = mile.Session_Due_Date__c.day();
                        sessionMilestoneMonth = mile.Session_Due_Date__c.month();
                        sessionMilestoneYear = mile.Session_Due_Date__c.year();
                        quarter = math.floor(mile.CreatedDate.month()/3);
                        system.debug('### quarter: ' + quarter);
                        // quarter = quarter.round(System.RoundingMode.CEILING);
                        system.debug('### quarter1: ' + quarter);
                        system.debug('### proj.Of_Session_Milestones__c: ' + proj.Of_Session_Milestones__c);
                        if(proj.Of_Session_Milestones__c == 0){
                            mile.Name = 'Session #1 - Q' + quarter + ' - ' + sessionMilestoneMonth + '-' + sessionMilestoneDay + '-' + sessionMilestoneYear;
                        }

                        else if(proj.Of_Session_Milestones__c > 0){
                            mile.Name = 'Session #' + proj.Of_Session_Milestones__c + ' - Q' + quarter + ' - ' + sessionMilestoneMonth + '-' + sessionMilestoneDay + '-' + sessionMilestoneYear;
                        }
                        
                        // IF([Milestone__c].Project__r.Of_Session_Milestones__c == 0, 'Session #1 - Q', 'Session #' + TEXT([Milestone__c].Project__r.Of_Session_Milestones__c + 1) + ' - Q') + TEXT(CEILING(MONTH(DATEVALUE([Milestone__c].CreatedDate)) / 3 )) + ' - ' + CASE(MONTH([Milestone__c].Session_Due_Date__c), 1, "Jan", 2, "Feb", 3, "Mar", 4, "Apr", 5, "May", 6, "Jun", 7, "Jul", 8, "Aug", 9, "Sept", 10, "Oct", 11, "Nov", 12, "Dec", "None") + '-' + TEXT(DAY([Milestone__c].Session_Due_Date__c)) + '-' + TEXT(YEAR([Milestone__c].Session_Due_Date__c))Build a formula...
                        // 'KO Q' + TEXT(CEILING(MONTH ([Milestone__c].Kickoff_date1__c) / 3 )) + ' - ' + CASE(MONTH([Milestone__c].Kickoff_date1__c), 1, "Jan", 2, "Feb", 3, "Mar", 4, "Apr", 5, "May", 6, "Jun", 7, "Jul", 8, "Aug", 9, "Sept", 10, "Oct", 11, "Nov", 12, "Dec", "None") + '-' + TEXT(DAY([Milestone__c].Kickoff_date1__c)) + '-' + TEXT(YEAR([Milestone__c].Kickoff_date1__c))Build a formula...
                    }
                }
            }
        }
    }*/

    public static void updateProjectFields(Map<Id, Milestone__c> milestoneMap, Map<Id, Milestone__c> oldMilestoneMap){
        Set<Id> projId = new Set<Id>();
        List<Project__c> projToUpdate = new List<Project__c>();
        for(Milestone__c mile : milestoneMap.values()){
            projId.add(mile.Project__c);
        }

        if(!projId.isEmpty()){
            for(Project__c relatedProject : [SELECT Id, Kickoff_Date__c, of_Milestones__c, Project_Status__c FROM Project__c WHERE Id IN: projId]){
                for(Milestone__c mile : milestoneMap.values()){
                    if(milestoneMap.get(mile.Id).Project__c == relatedProject.Id){
                        if(relatedProject.Project_Status__c == 'Pending Project Start'){
                            relatedProject.Project_Status__c = 'Open';
                            projToUpdate.add(relatedProject); 
                        }

                        /*if(oldMilestoneMap == null){
                            system.debug('### oldMilestoneMap: ' + oldMilestoneMap);
                            relatedProject.Current_Milestone__c = milestoneMap.get(mile.Id).Name;
                            projToUpdate.add(relatedProject);
                        }*/
                    }
                }
            }
        }
        system.debug('### projToUpdate: ' + projToUpdate);
        if(!projToUpdate.isEmpty()){
            Database.update(projToUpdate);
        }
    }

    /*public static void updateProjectStartDate(Map<Id, Milestone__c> milestoneMap, Map<Id, Milestone__c> oldMilestoneMap){
        Set<Id> projId = new Set<Id>();
        Set<Id> kickoffId = new Set<Id>();
        List<Project__c> projToUpdate = new List<Project__c>();
        List<Kickoff__c> kickoffList = new List<Kickoff__c>();
        List<Project__c> projectList = new List<Project__c>();

        for(Milestone__c mile : milestoneMap.values()){
            projId.add(mile.Project__c);
        }

        if(!projId.isEmpty()){
            for(Project__c relatedProject : [SELECT Id, Kickoff_Date__c, of_Milestones__c, Project_Status__c FROM Project__c WHERE Id IN: projId]){
                projectList.add(relatedProject);
            }
        }

        if(!projectList.isEmpty()){
            for(Milestone__c mile : milestoneMap.values()){
                if(milestoneMap.get(mile.Id).RecordType.DeveloperName == 'Session'){
                    for(Project__c proj : projectList){
                        if(milestoneMap.get(mile.Id).Project__c == proj.Id){
                            if(milestoneMap.get(mile.Id).Session_Due_Date__c < proj.Kickoff_Date__c){
                                proj.Kickoff_Date__c = milestoneMap.get(mile.Id).Session_Due_Date__c;
                                projToUpdate.add(proj);
                            }
                        }
                    }
                }
            }
        }
        
        if(!projToUpdate.isEmpty()){
            Database.update(projToUpdate);
        }
    }*/
}