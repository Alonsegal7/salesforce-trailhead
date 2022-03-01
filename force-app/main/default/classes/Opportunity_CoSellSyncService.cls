public without sharing class Opportunity_CoSellSyncService implements Database.Batchable<sObject>, Schedulable{

    private static Boolean allowSecondaryOppsUpdate = false; 
    public static List<Co_sell_Main_to_Secondary_Opp_Mapping__mdt> mainToSecOppMapping_cmt {
        get {
                if (mainToSecOppMapping_cmt == null) {
                    mainToSecOppMapping_cmt = [
                        select Field_API_Name__c 
                        from Co_sell_Main_to_Secondary_Opp_Mapping__mdt
                    ];
                }
                return mainToSecOppMapping_cmt;
        } set;
    }

    public static Boolean checkIfSecondaryOppsUpdateAllowed(){
        return allowSecondaryOppsUpdate;
    }

    public static List<Opportunity> queryOppsCmtFields(Set<Id> oppIds_set){
        String fieldsStr = '';
        for(Co_sell_Main_to_Secondary_Opp_Mapping__mdt mainToSecCmt: mainToSecOppMapping_cmt){
            fieldsStr += ','+mainToSecCmt.Field_API_Name__c;
        }
        String query = 'select Id' + fieldsStr +' from Opportunity WHERE Id in: oppIds_set';
        List<Opportunity> oppsWithCmtFields = Database.query(query);
        return oppsWithCmtFields;
    }

    public void execute(SchedulableContext SC) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this, 20);
        } catch(Exception e){
            Utilities.sendEmail('Error in Opportunity_CoSellSyncService execute schedule: ',e.getMessage()+ ' ' + e.getStackTraceString(), new list<string>{'kseniasm@monday.com'});   
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        try {
            //select all main co-sell opps where last mondified is in the last week
            String query = 'select Id, Main_Opportunity__c, Main_Opportunity__r.LastModifiedDate, Secondary_Opportunity__c, Secondary_Opportunity__r.LastModifiedDate'; 
            query += ' from Co_Sell_Request__c';
            query += ' where Status__c = \'Approved\' and Main_Opportunity__r.LastModifiedDate = LAST_WEEK';
            return Database.getQueryLocator(query);
        } catch(Exception e){
            Utilities.sendEmail('Error in Opportunity_CoSellSyncService start: ',e.getMessage()+ ' ' + e.getStackTraceString(), new list<string>{'kseniasm@monday.com'});   
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Co_Sell_Request__c> scope){
        try {
            Map<Id,Id> oppsToSync_map = new Map<Id,Id>(); 
            for(Co_Sell_Request__c cosellReq: scope){
                if(cosellReq.Main_Opportunity__r.LastModifiedDate > cosellReq.Secondary_Opportunity__r.LastModifiedDate){ // main co sell opp was updated since last sync to sec opp
                    oppsToSync_map.put(cosellReq.Main_Opportunity__c, cosellReq.Secondary_Opportunity__c);
                }
            }
            if(!oppsToSync_map.isEmpty()) syncMainOppsToSec(oppsToSync_map);
        } catch (Exception e) {
            Utilities.sendEmail('Error in Opportunity_CoSellSyncService execute: ',e.getMessage()+ ' ' + e.getStackTraceString(), new list<string>{'kseniasm@monday.com'});   
        }
    }

    public static void syncMainOppsToSec(Map<Id,Id> oppsToSync_map){
        Map<Id,Opportunity> mainOppsWithCmtFields_map = new Map<Id,Opportunity>(queryOppsCmtFields(oppsToSync_map.keySet()));
        List<Opportunity> secOppsToUpdate_list = new List<Opportunity>();
        for(Id mainOppId: oppsToSync_map.keySet()){
            Opportunity secOpp = new Opportunity(Id = oppsToSync_map.get(mainOppId));
            Opportunity currMainOpp = mainOppsWithCmtFields_map.get(mainOppId);
            for(Co_sell_Main_to_Secondary_Opp_Mapping__mdt mainToSecCmt: mainToSecOppMapping_cmt){
                secOpp.put(mainToSecCmt.Field_API_Name__c, currMainOpp.get(mainToSecCmt.Field_API_Name__c));
            }
            secOppsToUpdate_list.add(secOpp);
        }
        if(!secOppsToUpdate_list.isEmpty()) {
            updateOppSecCosellAllowed(secOppsToUpdate_list);
        }
    }

    public static void updateOppSecCosellAllowed(List<Opportunity> opps){
        if(opps == null || opps.isEmpty()) return;
        allowSecondaryOppsUpdate = true;
        Database.update(opps);
        allowSecondaryOppsUpdate = false;
    }

    public static void syncCoSellOppsClosedWon(List<Opportunity> newOpps, Map<Id,Opportunity> oldOppsMap){
        Set<Id> potentialOpps_set = new Set<Id>();
        for(Opportunity opp: newOpps){
            if(isMainCoSellOpp(opp) && opp.StageName == 'Closed Won' && opp.StageName != oldOppsMap.get(opp.Id).StageName){
                potentialOpps_set.add(opp.Id);
            }
        }
        if(potentialOpps_set.isEmpty()) return; //no potential opps found - exit
        Map<Id,Id> oppsToSync_map = new Map<Id,Id>();
        for(Co_Sell_Request__c cosellReq: [select Main_Opportunity__c, Secondary_Opportunity__c from Co_Sell_Request__c where Main_Opportunity__c in: potentialOpps_set]){
            oppsToSync_map.put(cosellReq.Main_Opportunity__c, cosellReq.Secondary_Opportunity__c);
        }
        if(!oppsToSync_map.isEmpty()) syncMainOppsToSec(oppsToSync_map); 
    }

    public static Boolean isMainCoSellOpp(Opportunity opp){
        return (opp.Co_Sell_Opportunity__c != null && opp.Main_Co_Sell_Opportunity__c);
    }

    public static Boolean isSecondaryCoSellOpp(Opportunity opp){
        return (opp.Co_Sell_Opportunity__c != null && !opp.Main_Co_Sell_Opportunity__c);
    }

    public void finish(Database.BatchableContext BC){}
}
