public without sharing class Target_ScheduledAlertOppsWoTarget implements Schedulable{

    public void execute(SchedulableContext SC) {
        Id oppPartnerCompanyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        // LOOK FOR OPPS WITH OWNER THAT HAS A TARGET FOR CURR MONTH BUT OPP IS NOT CONNECTED TO A TARGET
        String dynamicQuery = 'select Id, OwnerId, Owner.Name, Owner.AccountId, RecordTypeId, Owner_s_Manager__c, CloseDate, GSI__c,Target__c,CP_Target__c,GSI_Target__c from Opportunity where (Target__c = null or (CP_Target__c = null and Owner.AccountId != null) or (GSI_Target__c = null and GSI__c != null)) and CloseDate = THIS_MONTH';
        if(!Test.isRunningTest()) dynamicQuery += '  and Owner.Profile.Name != \'System Administrator\'';
        List<Opportunity> oppsList = Database.query(dynamicQuery);
        Decimal beforeFixSize = 0;
        String failedToFixOppIdsStr = '';
        String oppIdsToFixString = '';
        String oppIdsWoMatchTargetStr = '';
        String missingTargets = '';
        String newTargetsStr = '';

        if(oppsList != null && !oppsList.isEmpty()) {
            Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>(oppsList);
            beforeFixSize = oppsMap.size();
    
            // GET ALL EXISTING TARGETS FOR CURR MONTH
            list<Target__c> thisMonthTarget = [select Id, User__c, Partner_Company__c from Target__c where Target_Date__c = THIS_MONTH];
            Set<Id> usersWithTarget = new Set<Id>();
            Set<Id> partnerCompsWithTarget = new Set<Id>();
            for(Target__c target: thisMonthTarget){
                if(target.User__c != null) usersWithTarget.add(target.User__c); //collect users with existing targets this month
                if(target.Partner_Company__c != null) partnerCompsWithTarget.add(target.Partner_Company__c); ////collect partner companies (accounts) with existing targets this month
            }
    
            Set<Id> usersWoTargetThisMonth = new Set<Id>();
            Set<Id> partnerCompsWoTargetThisMonth = new Set<Id>();
            Set<Id> gsiWoTargetThisMonth = new Set<Id>();
            Map<Id,Opportunity> oppsToUpdate_map = new Map<Id,Opportunity>();
            Id relevantUserId;
            Id relevantPartnerCompId;
            Id relevantGsiId;
        
            // RUN MANUAL FIX IF SUCH OPPS FOUND...
            for(Opportunity opp: oppsMap.values()){
                //get id for user target if user target is missing
                if(opp.Target__c == null){
                    if(opp.RecordTypeId == oppPartnerCompanyRtId && opp.Owner_s_Manager__c != null){
                        relevantUserId = opp.Owner_s_Manager__c;
                    } else {
                        relevantUserId = opp.OwnerId;
                    }
                    if(usersWithTarget.contains(relevantUserId)) { //opps w/ existing user targets
                        oppIdsToFixString += String.valueOf(opp.Id) + ',';
                        oppsToUpdate_map.put(opp.Id, new Opportunity(Id = opp.Id, Manual_Trigger__c = 'Link Target')); //triggers the Trget Service to run and link opp to existing target (works for targets of users, partners & GSIs)
                    } else { //opps w/o existing user targets
                        missingTargets += String.valueOf(opp.Owner.Name) + ',';
                        oppIdsWoMatchTargetStr += String.valueOf(opp.Id) + ',';
                        usersWoTargetThisMonth.add(relevantUserId);
                    }
                }
                //get id for partner comp if CP target is missing
                if(opp.RecordTypeId == oppPartnerCompanyRtId && opp.Owner.AccountId != null && opp.CP_Target__c == null){
                    relevantPartnerCompId = opp.Owner.AccountId;
                } else {
                    relevantPartnerCompId = null;
                }
                if(partnerCompsWithTarget.contains(relevantPartnerCompId)) { //opps w/ existing user targets
                    oppIdsToFixString += String.valueOf(opp.Id) + ',';
                    if(!oppsToUpdate_map.containsKey(opp.Id)) oppsToUpdate_map.put(opp.Id, new Opportunity(Id = opp.Id, Manual_Trigger__c = 'Link Target')); //triggers the Trget Service to run and link opp to existing target (works for targets of users, partners & GSIs)
                } else { //opps w/o existing CP targets
                    missingTargets += String.valueOf(relevantPartnerCompId)+ ',';
                    oppIdsWoMatchTargetStr += String.valueOf(opp.Id) + ',';
                    partnerCompsWoTargetThisMonth.add(relevantPartnerCompId);
                }

                //get id for partner comp if GSI target is missing
                if(opp.GSI__c != null && opp.GSI_Target__c == null){
                    relevantGsiId = opp.GSI__c;
                } else {
                    relevantGsiId = null;
                }
                if(partnerCompsWithTarget.contains(relevantGsiId)) { //opps w/ existing user targets
                    oppIdsToFixString += String.valueOf(opp.Id) + ',';
                    if(!oppsToUpdate_map.containsKey(opp.Id)) oppsToUpdate_map.put(opp.Id, new Opportunity(Id = opp.Id, Manual_Trigger__c = 'Link Target')); //triggers the Trget Service to run and link opp to existing target (works for targets of users, partners & GSIs)
                } else { //opps w/o existing GSI targets
                    missingTargets += String.valueOf(relevantGsiId)+ ',';
                    oppIdsWoMatchTargetStr += String.valueOf(opp.Id) + ',';
                    gsiWoTargetThisMonth.add(relevantGsiId);
                }
            }
            Database.update(oppsToUpdate_map.values());
    
            //CREATE MISSING TARGETS
            Set<Id> successIds = new Set<Id>();
            List<Target__c> newTargets = new List<Target__c>();
            if(Date.today().day() > Date.today().addDays(1).day()){ //today is last day of month - we create new user targets only at end of month
                //USER TARGETS
                for(Id userId: usersWoTargetThisMonth){
                    Target__c newUserTarget = new Target__c();
                    newUserTarget.OwnerId = userId;
                    newUserTarget.User__c = userId;
                    newUserTarget.Target_Date__c = Date.today().toStartOfMonth();
                    newUserTarget.Amount__c = 0;
                    newTargets.add(newUserTarget);
                }
            }
            //CP TARGETS
            for(Id cpId: partnerCompsWoTargetThisMonth){
                Target__c newCpTarget = new Target__c();
                newCpTarget.Partner_Company__c = cpId;
                newCpTarget.Target_Date__c = Date.today().toStartOfMonth();
                newCpTarget.Amount__c = 0;
                newCpTarget.Department__c = 'Channel Partners';
                newTargets.add(newCpTarget);
            }
            //GSI TARGETS
            for(Id gsiId: gsiWoTargetThisMonth){
                Target__c newGsiTarget = new Target__c();
                newGsiTarget.Partner_Company__c = gsiId;
                newGsiTarget.Target_Date__c = Date.today().toStartOfMonth();
                newGsiTarget.Amount__c = 0;
                newGsiTarget.Department__c = 'GSI';
                newTargets.add(newGsiTarget);
            }
            if(!newTargets.isEmpty()) {
                String errorsFound = '', currErr = '';
                Database.SaveResult[] lsr = Database.insert(newTargets, false); // specify false for second parameter (allOrNone) so that if a record fails, the remainder of the DML operation can still succeed 
                for (Database.SaveResult sr : lsr) {
                    if (sr.isSuccess()) {
                        successIds.add(sr.getId());
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            currErr = err.getStatusCode() + ': ' + err.getMessage();
                            if(sr.getId() != null) currErr = 'Target__c ID: ' + sr.getId() + ' ' + currErr;
                            errorsFound += currErr + ', ';
                            system.debug('Target_ScheduledAlertOppsWoTarget error in targets insert: ' + errorsFound);
                        }
                    }
                }
                if(!successIds.isEmpty()){
                    Utilities.sendEmail('Successfully created missing targets!', 'Ids of new targets: ' + successIds + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), new List<String>{'kseniasm@monday.com'});
                }
                if(errorsFound != ''){
                    Utilities.sendEmail('Error in creating missing targets', 'Errors found: ' + errorsFound + ' <br/>Targets attempted to insert: ' + JSON.serialize(usersWoTargetThisMonth) + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), new List<String>{'kseniasm@monday.com'});
                }
            }
            //END CREATE MISSING TARGETS
    
            //STRINGS FOR SLACK MSG
            Set<Id> newTargetsIds = new Set<Id>(successIds);
            if(newTargetsIds != null && !newTargetsIds.isEmpty()){
                List<Target__c> createdTargets = [select User__r.Name, Partner_Company__r.Name from Target__c where Id IN: newTargetsIds];
                for(Target__c target: createdTargets){
                    if(target.User__r.Name != null) newTargetsStr += String.valueOf(target.User__r.Name) + ',';
                    if(target.Partner_Company__r.Name != null) newTargetsStr += String.valueOf(target.Partner_Company__r.Name) + ',';
                }
            }
            List<Opportunity> oppsFailedToFix_lst = Database.query(dynamicQuery);
            Map<Id, Opportunity> oppsFailedToFixMap = new Map<Id, Opportunity>(oppsFailedToFix_lst);
            Decimal afterFixSize = oppsFailedToFixMap.size();
            if(afterFixSize > 0){
                failedToFixOppIdsStr = oppsFailedToFixMap.keySet().toString();
            }
        }
        
        // SEND SLACK ALERT
        List<Slack_MessageService.slackRequest> requests = new List<Slack_MessageService.slackRequest>();
        Slack_MessageService.slackRequest req = new Slack_MessageService.slackRequest();
        req.slackMessage='Targets and Opps Link Health Script';
        req.channel='#biz-tech-monitoring';
        req.emoji=':drum_with_drumsticks:';
        req.additionalInfo=''; // put here all the details including the string of all fixed/unfixed opps
        req.errorMessage=''; //only when we still have opps without target after fix
        if(failedToFixOppIdsStr != ''){
            req.errorMessage = 'ATTENTION #1! Found opps without target (manual fix failed): ' + failedToFixOppIdsStr;
        }
        if(missingTargets != ''){
            req.errorMessage += '; ATTENTION #2! We have missing targets: ' + missingTargets;
        }
        if(oppIdsToFixString != '' || oppIdsWoMatchTargetStr != ''){
            if(oppIdsToFixString != ''){
                req.additionalInfo = 'WARNING #1! Found opps without target and tried to run manual fix: ' + oppIdsToFixString;
                if(failedToFixOppIdsStr == ''){
                    req.additionalInfo += '; RESULT: MANUAL FIX SUCCESSEFULLY FINISHED FOR ALL OPPS! :)';
                } else {
                    req.additionalInfo += '; RESULT: MANUAL FIX FAILED FOR SOME OPPS! :(';
                }
            }
            if(oppIdsWoMatchTargetStr != ''){
                req.additionalInfo += '; WARNING #2! Found opps with owner that has no matching target: ' + oppIdsWoMatchTargetStr + '; Missing targets: ' + missingTargets;
                if(newTargetsStr != ''){
                    req.additionalInfo += '; RESULT: Created missing targets: ' + newTargetsStr;
                } else {
                    req.additionalInfo += '; RESULT: Failed to create new targets :(';
                }
            }
        } else {
            req.additionalInfo = 'RESULT: All this month opps have a target! YAY :)';
        }
        req.recordId=''; 
        requests.add(req);
        Slack_MessageService.sendToSlack(requests);
    }
}