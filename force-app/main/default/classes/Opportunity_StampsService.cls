public without sharing class Opportunity_StampsService {

    public static void run(list<Opportunity> newOpps, map<Id,Opportunity> oldMap){
        try {
            updateOwnerStamps(newOpps,oldMap);
            updateCloseProcessPathOnReopen(newOpps,oldMap);
        } catch(Exception e) {
            Utilities.sendDebugEmail('Error in Account_StampsService',e,e.getMessage());
        }
    }

    //only in before update
    public static void updateCloseProcessPathOnReopen(list<Opportunity> newOpps, map<Id,Opportunity> oldMap){
        if(oldMap == null) return;
        for(Opportunity opp: newOpps){
            if(opp.StageName != oldMap.get(opp.Id).StageName && opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost'){
                opp.Close_Process_Path__c = '';
            }
        }
    }

    //before insert and update
    public static void updateOwnerStamps(list<Opportunity> newOpps, map<Id,Opportunity> oldMap) {
        List<Opportunity> relevantOppsOwnerChange = new List<Opportunity>();
        Set<Id> relevantUsers = new Set<Id>();

        for(Opportunity opp: newOpps){
            if(oldMap == null || opp.OwnerId != oldMap.get(opp.Id).OwnerId){
                relevantUsers.add(opp.OwnerId);
                relevantOppsOwnerChange.add(opp);
            }
        }

        if (relevantOppsOwnerChange.isEmpty()) return;
        
        Map<Id,User> usersMap = new Map<Id,User>([SELECT Id, AccountId, Team__c, Profile.Name, Group__c,
                                                    ManagerId, Manager.ManagerId, Manager.Team__c 
                                                    FROM USER 
                                                    WHERE Id IN: relevantUsers]);

        //update owner-related stamps on the relevant opps
        for (Opportunity opp: relevantOppsOwnerChange) {
            User currOwner = usersMap.get(opp.OwnerId);
            if (currOwner != null) {
                opp.Channel_Partner__c = currOwner.AccountId;
                if(currOwner.Profile.Name == 'Channel Managers'){ //Owner is CPM
                    opp.CPM_Manager2__c = currOwner.ManagerId;
                    opp.Owner_s_Manager__c = currOwner.Id;
                    opp.Owner_s_Manager_Team__c = currOwner.Team__c;
                } else { //Owner is not CPM (can be partner, sales or other...)
                    opp.CPM_Manager2__c = currOwner.AccountId != null ? currOwner.Manager.ManagerId : null; //if owner is partner
                    opp.Owner_s_Manager__c = currOwner.ManagerId;
                    opp.Owner_s_Manager_Team__c = currOwner.Manager.Team__c;
                }
            }
        }
    }
}
