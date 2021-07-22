public with sharing class KickoffHandler {

    public static void afterInsert(Map<Id, Kickoff__c> kickoffMap, Map<Id, Kickoff__c> oldMap){
        updateProjectStartDate(kickoffMap, oldMap);
    }

    public static void updateProjectStartDate(Map<Id, Kickoff__c> kickoffMap, Map<Id, Kickoff__c> oldMap){
        Set<Id> projId = new Set<Id>();
        List<Project__c> projToUpdate = new List<Project__c>();
        // List<Project__c> projectList = new List<Project__c>();
        Map<Id, Id> mileProjMap = new Map<Id, Id>(); //Milestone Id, Project Id
        Map<Id, Kickoff__c> mileKicMap = new Map<Id, Kickoff__c>(); //Milestone Id, Kickoff

        for(Milestone__c mile : [SELECT Id, Project__c, Kickoff__c FROM Milestone__c WHERE Kickoff__c IN: kickoffMap.keySet()]){
            for(Kickoff__c kick : kickoffMap.values()){
                projId.add(mile.Project__c);
                mileProjMap.put(mile.Id, mile.Project__c);
                mileKicMap.put(mile.Id, kick);
            }
        }

        if(!projId.isEmpty()){
            List<Project__c> projectList = [SELECT Id, Kickoff_Date__c FROM Project__c WHERE Id IN: projId];
            if(!projectList.isEmpty()){
                for(Id mileKic : mileKicMap.keySet()){
                    for(Id mileProj : mileProjMap.keySet()){
                        for(Project__c proj : projectList){
                            if(mileKic == mileProj && mileProjMap.get(mileProj).Project__c == proj.Id){
                                proj.Kickoff_Date__c = mileKicMap.get(mileKic.Id).Kickoff_meeting_date__c;
                                projToUpdate.add(proj);
                            }
                        }
                    }
                }
            }
        }

        system.debug('### projToUpdate: ' + projToUpdate);
        if(!projToUpdate.isEmpty()){
            Database.update(projToUpdate);
        }
    }
}
