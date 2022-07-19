public without sharing class Opportunity_StampsService {

    public static void run(list<Opportunity> newOpps, map<Id,Opportunity> oldMap){
        try {
            updateOwnerStamps(newOpps,oldMap);
            updateCloseProcessPathOnReopen(newOpps,oldMap);
            updatedAddedSeats(newOpps,oldMap);
            updatedGreenBucketConverted(newOpps,oldMap);
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
        
        Map<Id,User> usersMap = new Map<Id,User>([SELECT Id, AccountId, Account.PDM__c, Team__c, Profile.Name, Group__c,
                                                    ManagerId, Manager.ManagerId, Manager.Team__c 
                                                    FROM USER 
                                                    WHERE Id IN: relevantUsers]);

        //update owner-related stamps on the relevant opps
        for (Opportunity opp: relevantOppsOwnerChange) {
            User currOwner = usersMap.get(opp.OwnerId);
            if (currOwner != null) {
                opp.Channel_Partner__c = currOwner.AccountId;
                if(opp.Channel_Partner__c != null && opp.PDM__c == null) {//channel partner assigned and PDM was not assigned before
                    opp.PDM__c = currOwner.Account.PDM__c;
                } 
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

    /*  only before update
        Update Added_Seats__c calculation
        Object: Opportunity
        Fields: Current_Account_Seats__c and Expected_Plan_Seats__c (This field is a core calculation)
    */
    public static void updatedAddedSeats(List<Opportunity> newOpps, Map<Id,Opportunity> oldMap){
        if(oldMap == null) return;
        for(Opportunity opp : newOpps){
            if(opp.StageName != oldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won'){
                if(opp.Expected_Plan_Seats__c == null){
                    opp.Added_Seats__c = 0;
                }

                else{
                    if(opp.Current_Account_Seats__c == null){
                        opp.Added_Seats__c = opp.Expected_Plan_Seats__c;
                    }

                    else{
                        opp.Added_Seats__c = opp.Expected_Plan_Seats__c - opp.Current_Account_Seats__c;
                    }
                }
            }
        }
    }

    /*  before insert & update
        Update Is_GB_when_converted__c
        Object: Opportunity
        Fields: Is_GB_when_converted__c and Expected_Plan_Name__c and Is_Potential_GB_Opportunity__c and CreatedDate
    */
    public static void updatedGreenBucketConverted(List<Opportunity> newOpps, Map<Id,Opportunity> oldMap){
        for(Opportunity opp : newOpps){
            Date createdDateComp = null;
            createdDateComp = Date.newInstance(2021, 3, 6);
            /*  1st Condition --> insert only + Partner RT
                2nd Condition --> insert & update + CreatedDate > 6.3.2021 + Is_GB_when_converted__c = null
            */
            if((oldMap == null && opp.RecordType.DeveloperName == 'Partner_Opportunity' && opp.Expected_Plan_Name__c != null)
                || 
                (opp.Expected_Plan_Name__c != oldMap.get(opp.Id).Expected_Plan_Name__c && opp.Is_GB_when_converted__c == null && opp.CreatedDate > createdDateComp)){
                if(opp.Is_Potential_GB_Opportunity__c == true){
                    opp.Is_GB_when_converted__c = 'True';
                }

                else{
                    opp.Is_GB_when_converted__c = 'False';
                }
            }
        }
    }
}