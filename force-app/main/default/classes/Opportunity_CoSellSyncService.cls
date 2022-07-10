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
            String query = 'select Id, Main_Opportunity__c, Main_Opportunity__r.LastModifiedDate, Secondary_Opportunity__c, Last_Sync_from_Main_to_Secondary__c, Secondary_Opportunity_Owner__c'; 
            query += ' from Co_Sell_Request__c';
            query += ' where Status__c = \'Approved\' and Main_Opportunity__r.Need_Sync_Co_Sell__c = true';
            return Database.getQueryLocator(query);
        } catch(Exception e){
            Utilities.sendEmail('Error in Opportunity_CoSellSyncService start: ',e.getMessage()+ ' ' + e.getStackTraceString(), new list<string>{'kseniasm@monday.com'});   
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Co_Sell_Request__c> scope){
        try {
            Map<Id,Id> oppsToSync_map = new Map<Id,Id>(); 
            Map<Id,Co_Sell_Request__c> secOppToCoSellReq_map = new Map<Id,Co_Sell_Request__c>(); 
            for(Co_Sell_Request__c cosellReq: scope){
                oppsToSync_map.put(cosellReq.Main_Opportunity__c, cosellReq.Secondary_Opportunity__c);
                secOppToCoSellReq_map.put(cosellReq.Secondary_Opportunity__c, cosellReq);
            }
            if(oppsToSync_map.isEmpty()) return;
            Set<Id> successIds = syncMainOppsToSec(oppsToSync_map);
            if(successIds.isEmpty()) return;
            list<Co_Sell_Request__c> coSellReqsToUpdate = new list<Co_Sell_Request__c>();
            list<opportunity> oppsToUpdate = new list<opportunity>();
            for(Id secOppId: successIds){
                coSellReqsToUpdate.add(new Co_Sell_Request__c(
                    Id = secOppToCoSellReq_map.get(secOppId).Id,
                    Last_Sync_from_Main_to_Secondary__c = Datetime.now()
                ));
                oppsToUpdate.add(new Opportunity(
                    Id = secOppToCoSellReq_map.get(secOppId).Main_Opportunity__c,
                    Need_Sync_Co_Sell__c = false
                ));
            }
            Database.update(coSellReqsToUpdate);
            Database.update(oppsToUpdate);
        } catch (Exception e) {
            Utilities.sendEmail('Error in Opportunity_CoSellSyncService execute: ',e.getMessage()+ ' ' + e.getStackTraceString(), new list<string>{'kseniasm@monday.com'});   
        }
    }

    public static Set<Id> syncMainOppsToSec(Map<Id,Id> oppsToSync_map){
        Set<Id> res = new Set<Id>();
        Map<Id,Opportunity> mainOppsWithCmtFields_map = new Map<Id,Opportunity>(queryOppsCmtFields(oppsToSync_map.keySet()));
        List<Opportunity> secOppsToUpdate_list = new List<Opportunity>();
        Set<Id> secOppsIds = new Set<Id>(oppsToSync_map.values());
        Map<Id,Opportunity> secOppsWithARROverride = new Map<Id,Opportunity>([select Id from Opportunity where Claimed_ARR_Override__c != null and Id in: secOppsIds]);
        for(Id mainOppId: oppsToSync_map.keySet()){
            Opportunity secOpp = new Opportunity(Id = oppsToSync_map.get(mainOppId));
            Opportunity currMainOpp = mainOppsWithCmtFields_map.get(mainOppId);
            for(Co_sell_Main_to_Secondary_Opp_Mapping__mdt mainToSecCmt: mainToSecOppMapping_cmt){
                if(mainToSecCmt.Field_API_Name__c == 'Claimed_ARR__c' //before sync claimed arr we check if the arr was overwitten
                    && secOppsWithARROverride.containsKey(oppsToSync_map.get(mainOppId))){ //and if it was - we do not sync the claimed arr field
                    //do not sync claimed arr 
                } else {
                    secOpp.put(mainToSecCmt.Field_API_Name__c, currMainOpp.get(mainToSecCmt.Field_API_Name__c));
                }
            }
            secOppsToUpdate_list.add(secOpp);
        }
        if(!secOppsToUpdate_list.isEmpty()) {
            res = updateOppSecCosellAllowed(secOppsToUpdate_list, 'Sync Main to Sec Co-Sell');
        }
        return res;
    }

    public static Set<Id> updateOppSecCosellAllowed(List<Opportunity> opps, String emailTitle){
        String errorsFound = '', currErr = '';
        Set<Id> successIds = new Set<Id>();
        if(opps == null || opps.isEmpty()) return successIds;
        allowSecondaryOppsUpdate = true;
        Database.SaveResult[] lsr = Database.update(opps, false);
        allowSecondaryOppsUpdate = false;
        for (Database.SaveResult sr : lsr) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for(Database.Error err : sr.getErrors()) {
                    currErr = 'Opp ID: ' + sr.getId() + ' ' + err.getStatusCode() + ': ' + err.getMessage();
                    errorsFound += currErr + '<br/>';
                }
            }
        }
        /*
        //success emails
        if(!successIds.isEmpty()){
            String emailBody = '';
            list<opportunity> updatedOpps = [select Id, Name from Opportunity where Id in: successIds];
            for(Opportunity opp: updatedOpps){
                emailBody += '<br/><br/><a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view">'+opp.Name+'</a>';
            }
            Utilities.sendEmail('Success ' + emailTitle, emailBody, new List<String>{'kseniasm@monday.com'});
        }*/
        if(errorsFound != ''){
            Utilities.sendEmail('Error ' + emailTitle, errorsFound, new List<String>{'kseniasm@monday.com'});
        }
        return successIds;
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