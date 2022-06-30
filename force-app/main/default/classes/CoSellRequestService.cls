public without sharing class CoSellRequestService {

    public static Boolean insertFromCode = false;
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
    public static void send10Kemail(Id opportunityId){
        try {
            User runningUserInfo = [select FirstName, LastName from User where Id =: UserInfo.getUserId()];
            Opportunity opp = [select Id, Name, Account.Name from Opportunity where Id =: opportunityId];
            opp.CoSell_TH_Error_Triggered_by__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            update opp;
            String body = '';
            body += runningUserInfo.FirstName + ' ' + runningUserInfo.LastName + ' has tried to submit a co-sell request for '+ opp.Account.Name + ' from opportunity ' + opp.Name + '(Id: '+opp.Id+') and got blocked because this deal does not match the ARR TH requirment for Co-Sell (10K)';
            list<string> toAddresses = new list<string>();
            toAddresses.add('kseniasm@monday.com');
            toAddresses.add('avivc@monday.com');
            toAddresses.add('naomida@monday.com');
            Utilities.sendEmail('Co-Sell 10K arr TH validation occured on '+ opp.Account.Name, body, toAddresses);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
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
        insertFromCode = true;
        Map<String,Object> res = new Map<String,Object>();
        try {
            Map<Id,Opportunity> oppsMap = new Map<Id,Opportunity>([select Id, OwnerId, RecordType.DeveloperName, Owner.Group__c, Owner.AccountId, Owner.ManagerId, Account.Co_Sell_Leader__c from Opportunity where Id =: newCoSellReq.Secondary_Opportunity__c or Id =: newCoSellReq.Main_Opportunity__c]);
            setPartnerCompanyId(newCoSellReq,oppsMap);
            setSecondaryOwnerIdAssociate(newCoSellReq,oppsMap);
            setSalesUserId(newCoSellReq,oppsMap);
            setAssignedApprover(newCoSellReq, oppsMap.values());
            Database.insert(newCoSellReq);
            updateOppsCoSellReq(newCoSellReq);
            submitCoSellReqForApproval(newCoSellReq.Id);
            res.put('newCoSellReqId',newCoSellReq.Id);
            String approverName = [select Name from User where Id =: newCoSellReq.Assigned_Approver__c].Name;
            res.put('managerName', approverName);
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    //runs in before update trigger of Co_Sell_Request__c
    public static void postApproveActions(List<Co_Sell_Request__c> newCoSellReqList, Map<Id,Co_Sell_Request__c> oldCoSellReqMap){
        Map<Id,Co_Sell_Request__c> newReqs_map = new Map<Id,Co_Sell_Request__c>(); //only for new requests (not associate)
        List<Co_Sell_Request__c> associateReqs_lst = new List<Co_Sell_Request__c>(); //only for associate requests
        Set<Id> oppIds_set = new Set<Id>();

        for(Co_Sell_Request__c coSellReq: newCoSellReqList){
            if(coSellReq.Status__c == 'Approved' && coSellReq.Status__c != oldCoSellReqMap.get(coSellReq.Id).Status__c){ 
                coSellReq.Last_Sync_from_Main_to_Secondary__c = Datetime.now();
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
        Opportunity_CoSellSyncService.updateOppSecCosellAllowed(oppsToUpdate, 'Update Co-Sell Opps Post Approval');
        //update claimed subs where claimed on opportunity equals main opp with secondary opp to be on claimed on opportunity (co sell)
        updateSubscriptions(newCoSellReqList);
    }

    public static void updateSubscriptions(List<Co_Sell_Request__c> newCoSellReqList){
        Set<Id> mainOppsIds = new Set<Id>();
        Set<Id> secOppsIds = new Set<Id>();
        Map<Id,Co_Sell_Request__c> mainOppCoSellReq_map = new Map<Id,Co_Sell_Request__c>();
        for(Co_Sell_Request__c coSellReq: newCoSellReqList){
            mainOppCoSellReq_map.put(coSellReq.Main_Opportunity__c, coSellReq);
            mainOppsIds.add(coSellReq.Main_Opportunity__c);
            if(coSellReq.Secondary_Opportunity__c != null) secOppsIds.add(coSellReq.Secondary_Opportunity__c);
        }
        Set<Id> allOppsIds = new Set<Id>(mainOppsIds);
        allOppsIds.addAll(secOppsIds);
        List<Subscription__c> claimedSubs = [select Id, Is_Claimed__c, Claimed_On_Opportunity__c, Claimed_On_Opportunity_Co_Sell__c 
                                                from Subscription__c 
                                                where (Claimed_On_Opportunity__c in: allOppsIds or Claimed_On_Opportunity_Co_Sell__c in: allOppsIds) 
                                                and Is_Claimed__c = true];
        if(claimedSubs.isEmpty()) return;
        List<Subscription__c> subsToUpdate = new List<Subscription__c>();
        for(Subscription__c sub: claimedSubs){
            if(sub.Claimed_On_Opportunity__c != null && mainOppCoSellReq_map.containsKey(sub.Claimed_On_Opportunity__c)){ //Claimed_On_Opportunity__c matches main opp
                if(sub.Claimed_On_Opportunity_Co_Sell__c == null //claimed on co-sell is empty
                    || sub.Claimed_On_Opportunity_Co_Sell__c != mainOppCoSellReq_map.get(sub.Claimed_On_Opportunity__c).Secondary_Opportunity__c){ //claimed on co-sell does not match sec opp
                        //put sec opp in claimed on opp co-sell on sub
                        sub.Claimed_On_Opportunity_Co_Sell__c = mainOppCoSellReq_map.get(sub.Claimed_On_Opportunity__c).Secondary_Opportunity__c;
                        sub.Claimed_By_Co_Sell__c = mainOppCoSellReq_map.get(sub.Claimed_On_Opportunity__c).Secondary_Opportunity_Owner__c;
                        sub.Claim_Date_Co_Sell__c = Datetime.now();
                        subsToUpdate.add(sub);
                } else {
                    continue; //main & sec opps are referenced correctly on sub -> continue to next sub
                }           
            } else { // main opp is not referenced or referenced incorrectly on sub -> unclaim sub
                sub.Is_Claimed__c = false;
                sub.Claimed_On_Opportunity__c = null;
                sub.Claimed_On_Opportunity_Co_Sell__c = null;
                sub.Claimed_By_Co_Sell__c = null;
                sub.Claim_Date_Co_Sell__c = null;
                sub.Claimed_By_Main__c = null;
                sub.Claim_Date_Main__c = null;
                subsToUpdate.add(sub);
            }
        }
        if(!subsToUpdate.isEmpty()) Database.update(subsToUpdate);
    }

    public static void dailyFillSurveyReminder(){
        list<String> leaders_list = new list<String>{'Partners', 'Sales'};
        List<Co_Sell_Request__c> cr_list = [select Id, Name, Sales_User__c, Partner_User__c, Monday_Account__r.co_sell_leader__c, 
                                            Main_Opportunity__c, Main_Opportunity__r.RecordType.DeveloperName, Secondary_Opportunity__c, Secondary_Opportunity__r.RecordType.DeveloperName
                                            from Co_Sell_Request__c where Status__c = 'Approved' and Impact_Survey_Filled__c = false and Main_Opportunity__r.StageName = 'Closed Won' and Monday_Account__r.co_sell_leader__c in: leaders_list];
        if(cr_list.isEmpty()) return;
        Id owea_id = [select Id from OrgWideEmailAddress where Address = 'bizops@monday.com' limit 1].Id;
        list<String> emailTempsNames = new list<String>{'Co_Sell_Impact_Survey_Reminder', 'Co_Sell_Impact_Survey_Reminder_Partners'};
        Map<String,Id> emailTempsMap = new Map<String,Id>();
        for(EmailTemplate et: [select id, DeveloperName from EmailTemplate where DeveloperName in: emailTempsNames limit 2]){
            if(et.DeveloperName == 'Co_Sell_Impact_Survey_Reminder') emailTempsMap.put('Sales', et.Id);
            else if(et.DeveloperName == 'Co_Sell_Impact_Survey_Reminder_Partners') emailTempsMap.put('Partners', et.Id);
        }
        List<Messaging.SingleEmailMessage> mail_list = new List<Messaging.SingleEmailMessage>();
        for(Co_Sell_Request__c cr: cr_list){
            Id whatId = null;
            Id whoId = null;
            Id templateId = null;
            if(cr.Monday_Account__r.co_sell_leader__c == 'Partners') {
                whoId = cr.Partner_User__c;
                templateId = emailTempsMap.get('Partners');
                if(cr.Main_Opportunity__r.RecordType.DeveloperName == 'Partner_Opportunity'){
                    whatId = cr.Main_Opportunity__c;
                } else {
                    whatId = cr.Secondary_Opportunity__c;
                }
            } else if(cr.Monday_Account__r.co_sell_leader__c == 'Sales') {
                whoId = cr.Sales_User__c;
                templateId = emailTempsMap.get('Sales');
                if(cr.Main_Opportunity__r.RecordType.DeveloperName == 'Internal_Opportunity'){
                    whatId = cr.Main_Opportunity__c;
                } else {
                    whatId = cr.Secondary_Opportunity__c;
                }
            }
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
            mail.setOrgWideEmailAddressId(owea_id);
            mail.setBccAddresses(new list<String>{'kseniasm@monday.com'});
            mail.setSaveAsActivity(false);
            mail.setReplyTo('noreply@monday.com');
            mail_list.add(mail);
        }
        Messaging.sendEmail(mail_list);
    }

    private static void setAssignedApprover(Co_Sell_Request__c newCoSellReq, List<Opportunity> oppsList){
        String coSellLeader = oppsList.get(0).Account.Co_Sell_Leader__c;
        if(coSellLeader == 'Partners') newCoSellReq.Assigned_Approver__c = newCoSellReq.CPM__c;
        else if(coSellLeader == 'Sales') newCoSellReq.Assigned_Approver__c = [select ManagerId from User where Id =: newCoSellReq.Sales_User__c].ManagerId;
    }

    private static void setSalesUserId(Co_Sell_Request__c newCoSellReq, Map<Id,Opportunity> oppsMap){
        if(newCoSellReq.Sales_User__c == null) {
            newCoSellReq.Sales_User__c = oppsMap.get(newCoSellReq.Main_Opportunity__c).RecordType.DeveloperName == 'Internal_Opportunity' ? oppsMap.get(newCoSellReq.Main_Opportunity__c).OwnerId : newCoSellReq.Secondary_Opportunity_Owner__c;
        }
    }

    private static void setSecondaryOwnerIdAssociate(Co_Sell_Request__c newCoSellReq, Map<Id,Opportunity> oppsMap){
        if(newCoSellReq.Type__c == 'Associate'){
            newCoSellReq.Secondary_Opportunity_Owner__c = oppsMap.get(newCoSellReq.Secondary_Opportunity__c).OwnerId;
        }
    }

    private static void setPartnerCompanyId(Co_Sell_Request__c newCoSellReq, Map<Id,Opportunity> oppsMap){
        if(newCoSellReq.Partner_Company__c == null){ //client finds the partner id for current opp only
            if(newCoSellReq.Type__c == 'Create' && newCoSellReq.Secondary_Opportunity_Owner__c != null){
                User partnerUser = [select Id, AccountId, ManagerId from User where Id =: newCoSellReq.Secondary_Opportunity_Owner__c];
                newCoSellReq.Partner_Company__c = partnerUser.AccountId;
                newCoSellReq.Partner_User__c = partnerUser.Id;
                newCoSellReq.CPM__c = partnerUser.ManagerId;
            } else if(newCoSellReq.Type__c == 'Associate' && newCoSellReq.Secondary_Opportunity__c != null){
                try{
                    Opportunity opp = oppsMap.get(newCoSellReq.Secondary_Opportunity__c);
                    newCoSellReq.Partner_Company__c = opp.Owner.AccountId;
                    newCoSellReq.Partner_User__c = opp.OwnerId;
                    newCoSellReq.CPM__c = opp.Owner.ManagerId;
                } catch (Exception e) {
                    throw new AuraHandledException('Partner Company not found.');
                }
            }
            if(!Test.isRunningTest() && newCoSellReq.Partner_Company__c == null) throw new AuraHandledException('Partner Company not found.');
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
        req.setProcessDefinitionNameOrId('Co_sell_Request_Approval_Process_v2');
        req.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req);
    }

    private static void handleNew(Map<Id,Co_Sell_Request__c> newReqs_map, Map<Id,Opportunity> oppsWithCmtFields_map, List<Opportunity> oppsToUpdate){
        Id partnerOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        Id internalOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        if(!newReqs_map.isEmpty()){ // new 
            Co_Sell_Request__c currReq;
            Opportunity currMainOpp;
            List<Opportunity> newSecondaryOpps = new List<Opportunity>();
            List<Account> mondayAccountsToUpdate = new List<Account>();
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
                if(currReq.Main_Opportunity_Record_Type__c == 'Internal_Opportunity') tempOpp.RecordTypeId = partnerOppRT;
                else tempOpp.RecordTypeId = internalOppRT;
                //cmt mapping from main to sec
                for(Co_sell_Main_to_Secondary_Opp_Mapping__mdt mainToSecCmt: Opportunity_CoSellSyncService.mainToSecOppMapping_cmt){
                    tempOpp.put(mainToSecCmt.Field_API_Name__c, currMainOpp.get(mainToSecCmt.Field_API_Name__c));
                }
                newSecondaryOpps.add(tempOpp);
                mondayAccountsToUpdate.add(new Account(
                    Id = currReq.Monday_Account__c,
                    Partner__c = currReq.Partner_User__c
                ));
            }
            System.debug('secondaryOpps: '+newSecondaryOpps);
            Database.insert(newSecondaryOpps);
            Database.update(mondayAccountsToUpdate);
    
            // update main opps with secondary lookup and main co-sell true
            for(Opportunity secOpp: newSecondaryOpps){
                currReq = newReqs_map.get(secOpp.Co_Sell_Opportunity__c);
                Opportunity tempOpp = new Opportunity(
                    Id = secOpp.Co_Sell_Opportunity__c,
                    Co_Sell_Opportunity__c = secOpp.Id,
                    Main_Co_Sell_Opportunity__c = true,
                    Co_Sell_Reason__c = currReq.Reason__c
                );

                if(currReq.Reason__c == 'Professional Services Sales Expertise'){
                    //cmt mapping from co-sell request to main opp
                    for(Co_sell_Request_to_Main_Opp_Mapping__mdt requestToMainOppCmt: requestToMainOppMapping_cmt){
                        tempOpp.put(requestToMainOppCmt.Opp_Field_API_Name__c, currReq.get(requestToMainOppCmt.Req_Field_API_Name__c));
                    }
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
                if(associateReq.Reason__c == 'Professional Services Sales Expertise'){
                    //cmt mapping from co-sell request to main opp
                    for(Co_sell_Request_to_Main_Opp_Mapping__mdt requestToMainOppCmt: requestToMainOppMapping_cmt){
                        currMainOpp.put(requestToMainOppCmt.Opp_Field_API_Name__c, associateReq.get(requestToMainOppCmt.Req_Field_API_Name__c));
                    }
                }
                //co-sell fields on opp
                currMainOpp.Co_Sell_Opportunity__c = currSecOpp.Id;
                currMainOpp.Main_Co_Sell_Opportunity__c = true;
                currMainOpp.Co_Sell_Reason__c = associateReq.Reason__c;
                currSecOpp.Co_Sell_Opportunity__c = currMainOpp.Id;
                currSecOpp.Main_Co_Sell_Opportunity__c = false;
                currSecOpp.Co_Sell_Reason__c = associateReq.Reason__c;
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
            Opportunity_CoSellSyncService.updateOppSecCosellAllowed(oppsToUpdate, 'Co-Sell Unsync Quote from Sec Opps Post Approval');
        }
    }

}