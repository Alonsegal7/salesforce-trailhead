public without sharing class CoSellRequestService {
    
   public static List<Co_sell_Request_to_Main_Opp_Mapping__mdt> requestToMainOppMapping_cmt {
        get {
            if (requestToMainOppMapping_cmt == null) {
                requestToMainOppMapping_cmt = [
                    select Opp_Field_API_Name__c, Req_Field_API_Name__c 
                    from Co_sell_Request_to_Main_Opp_Mapping__mdt
                ];
            }
            return requestToMainOppMapping_cmt;
        }
        set;
    }
    
    @AuraEnabled
    public static List<Opportunity> getAssociatePotentialOpps(Id accountId, String mainOppRecordTypeName){
        try {
            Set<String> recordTypes = new Set<String>{'Internal_Opportunity','Partner_Opportunity'}; //supported RTs
            recordTypes.remove(mainOppRecordTypeName); //we remove the current opp RT to look for the other RTs opps
            List<Opportunity> res = [select Id, Name, OwnerId, Owner.Name, StageName, Owner.AccountId, Co_Sell_Request__c, Co_Sell_Request__r.Status__c, 
                                    SyncedQuoteId, SyncedQuote.DH_Quote_Status__c, SyncedQuote.Is_Published__c, SyncedQuote.CreatedDate
                                        from Opportunity 
                                        where Is_Locked__c = false 
                                        and AccountId =: accountId 
                                        and RecordType.DeveloperName in: recordTypes 
                                        and Co_Sell_Opportunity__c = null 
                                        and (Co_Sell_Request__c = null or Co_Sell_Request__r.Status__c = 'Rejected')];
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Map<String,Object> createNewCoSellRequest(Co_Sell_Request__c newCoSellReq){
        Map<String,Object> res = new Map<String,Object>();
        try {
            getPartnerCompanyId(newCoSellReq);
            Database.insert(newCoSellReq);
            updateOppsCoSellReq(newCoSellReq);
            submitCoSellReqForApproval(newCoSellReq.Id);
            res.put('newCoSellReqId',newCoSellReq.Id);
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    private static void getPartnerCompanyId(Co_Sell_Request__c newCoSellReq){
        if(newCoSellReq.Partner_Company__c == null){ //client finds the partner id for current opp only
            if(newCoSellReq.Type__c == 'Create' && newCoSellReq.Secondary_Opportunity_Owner__c != null){
                newCoSellReq.Partner_Company__c = [select AccountId from User where Id =: newCoSellReq.Secondary_Opportunity_Owner__c].AccountId;
            } else if(newCoSellReq.Type__c == 'Associate' && newCoSellReq.Secondary_Opportunity__c != null){
                try{
                    newCoSellReq.Partner_Company__c = [select Owner.AccountId from Opportunity where Owner.AccountId != null and (Id =: newCoSellReq.Secondary_Opportunity__c or Id =: newCoSellReq.Main_Opportunity__c)].Owner.AccountId;
                } catch (Exception e) {
                    throw new AuraHandledException('Partner Company not found.');
                }
            }
            if(newCoSellReq.Partner_Company__c == null) throw new AuraHandledException('Partner Company not found.');
        } 
    }

    private static void updateOppsCoSellReq(Co_Sell_Request__c newCoSellReq){
        List<Opportunity> oppsToUpdate = new List<Opportunity>{new Opportunity(Id = newCoSellReq.Main_Opportunity__c, Co_Sell_Request__c = newCoSellReq.Id)};
        if(newCoSellReq.Secondary_Opportunity__c != null) oppsToUpdate.add(new Opportunity(Id = newCoSellReq.Secondary_Opportunity__c, Co_Sell_Request__c = newCoSellReq.Id));
        Database.update(oppsToUpdate);
    }

    private static void submitCoSellReqForApproval(Id coSellReqId){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setObjectId(coSellReqId);
        req.setProcessDefinitionNameOrId('Co_sell_Request_Approval_Process');
        req.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req);
    }

    private static void handleNew(Map<Id,Co_Sell_Request__c> newReqs_map, Map<Id,Opportunity> oppsWithCmtFields_map, List<Opportunity> oppsToUpdate){
        if(!newReqs_map.isEmpty()){ // new 
            Co_Sell_Request__c currReq;
            Opportunity currMainOpp;
            List<Opportunity> newSecondaryOpps = new List<Opportunity>();
            // create secondary opps by the mapping of Co_sell_Main_to_Secondary_Opp_Mapping__mdt
            for(Id mainOppId: newReqs_map.keySet()){
                currReq = newReqs_map.get(mainOppId);
                currMainOpp = oppsWithCmtFields_map.get(mainOppId);
                Opportunity tempOpp = new Opportunity(
                    OwnerId = currReq.Secondary_Opportunity_Owner__c,
                    Co_Sell_Opportunity__c = mainOppId,
                    Main_Co_Sell_Opportunity__c = false,
                    Co_Sell_Request__c = currReq.Id
                );
                for(Co_sell_Main_to_Secondary_Opp_Mapping__mdt mainToSecCmt: Opportunity_CoSellSyncService.mainToSecOppMapping_cmt){
                    tempOpp.put(mainToSecCmt.Field_API_Name__c, currMainOpp.get(mainToSecCmt.Field_API_Name__c));
                }
                for(Co_sell_Request_to_Main_Opp_Mapping__mdt requestToMainOppCmt: requestToMainOppMapping_cmt){
                    tempOpp.put(requestToMainOppCmt.Opp_Field_API_Name__c, currReq.get(requestToMainOppCmt.Req_Field_API_Name__c));
                }
                newSecondaryOpps.add(tempOpp);
            }
            System.debug('secondaryOpps: '+newSecondaryOpps);
            Database.insert(newSecondaryOpps);
    
            // update main opps with secondary lookup and main co-sell true
            for(Opportunity secOpp: newSecondaryOpps){
                currReq = newReqs_map.get(secOpp.Co_Sell_Opportunity__c);
                Opportunity tempOpp = new Opportunity(
                    Id = secOpp.Co_Sell_Opportunity__c,
                    Co_Sell_Opportunity__c = secOpp.Id,
                    Main_Co_Sell_Opportunity__c = true
                );
                for(Co_sell_Request_to_Main_Opp_Mapping__mdt requestToMainOppCmt: requestToMainOppMapping_cmt){
                    tempOpp.put(requestToMainOppCmt.Opp_Field_API_Name__c, currReq.get(requestToMainOppCmt.Req_Field_API_Name__c));
                }
                oppsToUpdate.add(tempOpp);
                // update co-sell req with secondary lookup
                currReq.Secondary_Opportunity__c = secOpp.Id;
            }
            System.debug('oppsToUpdate: '+oppsToUpdate);
        }
    }

    private static void handleAssociate(List<Co_Sell_Request__c> associateReqs_lst, Map<Id,Opportunity> oppsWithCmtFields_map, List<Opportunity> oppsToUpdate){
        if(!associateReqs_lst.isEmpty()){ //associate
            Set<Id> secOppsIds = new Set<Id>(); //for unsync quotes
            Opportunity currMainOpp;
            Opportunity currSecOpp;
            for(Co_Sell_Request__c associateReq : associateReqs_lst){
                //1) map all CMT fields from main to sec opp
                //2) update the co-sell fields - Co_Sell_Opportunity__c, Main_Co_Sell_Opportunity__c on both opps
                currSecOpp = oppsWithCmtFields_map.get(associateReq.Secondary_Opportunity__c);
                currMainOpp = oppsWithCmtFields_map.get(associateReq.Main_Opportunity__c);
                //cmt mapping from main to sec
                for(Co_sell_Main_to_Secondary_Opp_Mapping__mdt mainToSecCmt: Opportunity_CoSellSyncService.mainToSecOppMapping_cmt){
                    currSecOpp.put(mainToSecCmt.Field_API_Name__c, currMainOpp.get(mainToSecCmt.Field_API_Name__c));
                }
                //co-sell fields on opp
                currMainOpp.Co_Sell_Opportunity__c = currSecOpp.Id;
                currMainOpp.Main_Co_Sell_Opportunity__c = true;
                currSecOpp.Co_Sell_Opportunity__c = currMainOpp.Id;
                currSecOpp.Main_Co_Sell_Opportunity__c = false;
                oppsToUpdate.add(currMainOpp);
                oppsToUpdate.add(currSecOpp);
                secOppsIds.add(currSecOpp.Id);
            } 
            if(!secOppsIds.isEmpty()){
                Map<Id,Opportunity> secOppsWithQt = new Map<Id,Opportunity>([select Id from Opportunity where SyncedQuoteId != null and Id in: secOppsIds]);
                if(!secOppsWithQt.isEmpty()) System.enqueueJob(new unsyncQuotesFromSecondaryOpps(secOppsWithQt.keySet()));
            }
        }
    }

    private class unsyncQuotesFromSecondaryOpps implements System.Queueable {
        private Set<Id> oppIds;

        public unsyncQuotesFromSecondaryOpps(Set<Id> oppIds) {
            this.oppIds = oppIds;
        }

        public void execute(System.QueueableContext ctx) {
            List<Opportunity> oppsToUpdate = [select Id from Opportunity where SyncedQuoteId != null and Id in: oppIds];
            for(Opportunity opp: oppsToUpdate){
                opp.SyncedQuoteId = null;
            }
            Opportunity_CoSellSyncService.updateOppSecCosellAllowed(oppsToUpdate);
        }
    }

    //runs in before update trigger of Co_Sell_Request__c
    public static void postApproveActions(List<Co_Sell_Request__c> newCoSellReqList, Map<Id,Co_Sell_Request__c> oldCoSellReqMap){
        Map<Id,Co_Sell_Request__c> newReqs_map = new Map<Id,Co_Sell_Request__c>(); //only for new requests (not associate)
        List<Co_Sell_Request__c> associateReqs_lst = new List<Co_Sell_Request__c>(); //only for associate requests
        Set<Id> oppIds_set = new Set<Id>();

        for(Co_Sell_Request__c coSellReq: newCoSellReqList){
            if(coSellReq.Status__c == 'Approved' && coSellReq.Status__c != oldCoSellReqMap.get(coSellReq.Id).Status__c){ 
                oppIds_set.add(coSellReq.Main_Opportunity__c);
                if(coSellReq.Secondary_Opportunity__c == null){ //new 
                    newReqs_map.put(coSellReq.Main_Opportunity__c, coSellReq);
                } else {//associate
                    //1) collect associate cosell reqs (coSellReq.Secondary_Opportunity__c != null) to list<Co_Sell_Request__c> associateCosellReqs and their main & sec opps Ids to one set of opp ids - associateOppsIds
                    //2) get the opps of associateOppsIds with CMT field
                    associateReqs_lst.add(coSellReq);
                    oppIds_set.add(coSellReq.Secondary_Opportunity__c);
                }
            }
        }
        if(newReqs_map.isEmpty() && associateReqs_lst.isEmpty()) return; //no approved reqs found in before update trigger
        Map<Id,Opportunity> oppsWithCmtFields_map = new Map<Id,Opportunity>(Opportunity_CoSellSyncService.queryOppsCmtFields(oppIds_set)); //get opps fields from cmt Co_sell_Main_to_Secondary_Opp_Mapping__mdt

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        handleNew(newReqs_map, oppsWithCmtFields_map, oppsToUpdate);
        handleAssociate(associateReqs_lst, oppsWithCmtFields_map, oppsToUpdate);
        Opportunity_CoSellSyncService.updateOppSecCosellAllowed(oppsToUpdate);
    }
}