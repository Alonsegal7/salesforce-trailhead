public class Target_ScheduledAlertOppsWoTarget implements Schedulable{
    public void execute(SchedulableContext SC) {
        Id oppPartnerCompanyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        // LOOK FOR OPPS WITH OWNER THAT HAS A TARGET FOR CURR MONTH BUT OPP IS NOT CONNECTED TO A TARGET
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([select Id, OwnerId, Owner.Name, RecordTypeId, Owner_s_Manager__c, CloseDate from Opportunity where Target__c = null and CloseDate = THIS_MONTH]);
        Decimal beforeFixSize = oppsMap.size();
        String failedToFixOppIdsStr = '';
        String oppIdsToFixString = '';
        String oppIdsWoMatchTargetStr = '';
        String missingTargets = '';

        // GET ALL EXISTING TARGETS FOR CURR MONTH
        list<Target__c> thisMonthTarget = [select Id, User__r.Id from Target__c where Target_Date__c = THIS_MONTH];
        Set<Id> usersWithTarget = new Set<Id>();
        for(Target__c target: thisMonthTarget){
            usersWithTarget.add(target.User__r.Id);
        }

        Map<Id,Set<String>> usersWoTarget = new Map<Id,Set<String>>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Id relevantUserId;
        String newTargetsStr = '';
        if(beforeFixSize > 0){
            // RUN MANUAL FIX IF SUCH OPPS FOUND...
            for(Opportunity opp: oppsMap.values()){
                if(usersWithTarget.contains(opp.OwnerId)) {
                    oppIdsToFixString += String.valueOf(opp.Id) + ',';
                    oppsToUpdate.add(new Opportunity(Id = opp.Id, Manual_Trigger__c = 'Link Target'));
                } else {
                    missingTargets += String.valueOf(opp.Owner.Name) + ' ' + String.valueOf(opp.CloseDate.toStartOfMonth()) + ',';
                    oppIdsWoMatchTargetStr += String.valueOf(opp.Id) + ',';
                    if(opp.RecordTypeId == oppPartnerCompanyRtId && opp.Owner_s_Manager__c != null){
                        relevantUserId = opp.Owner_s_Manager__c;
                    } else {
                        relevantUserId = opp.OwnerId;
                    }
                    if(relevantUserId != null && usersWoTarget.containsKey(relevantUserId)){
                        usersWoTarget.get(relevantUserId).add(String.valueOf(opp.CloseDate.toStartOfMonth()));
                    } else {
                        usersWoTarget.put(relevantUserId, new Set<String>{String.valueOf(opp.CloseDate.toStartOfMonth())});
                    }
                }
            }
            Database.update(oppsToUpdate);

            //CREATE MISSING TARGETS
            Set<Id> successIds = new Set<Id>();
            List<Target__c> newTargets = new List<Target__c>();
            for(Id userId: usersWoTarget.keySet()){
                for(String strDate: usersWoTarget.get(userId)){
                    Target__c newTarget = new Target__c();
                    newTarget.User__c = userId;
                    newTarget.Target_Date__c = Date.valueOf(strDate);
                    newTarget.Amount__c = 0;
                    newTargets.add(newTarget);
                }
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
                    Utilities.sendEmail('Error in creating missing targets', 'Errors found: ' + errorsFound + ' <br/>Targets attempted to insert: ' + JSON.serialize(usersWoTarget) + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), new List<String>{'kseniasm@monday.com'});
                }
            }
            //END CREATE MISSING TARGETS

            Set<Id> newTargetsIds = new Set<Id>(successIds);
            if(newTargetsIds != null && newTargetsIds.isEmpty()){
                List<Target__c> createdTargets = [select User__r.Name, Target_Date__c from Target__c where Id IN: newTargetsIds];
                for(Target__c target: createdTargets){
                    newTargetsStr += String.valueOf(target.User__r.Name) + ' ' + String.valueOf(target.Target_Date__c) + ',';
                }
            }
            Map<Id, Opportunity> oppsFailedToFixMap = new Map<Id, Opportunity>([select Id from Opportunity where Target__c = null and CloseDate = LAST_MONTH and StageName = 'Closed Won']);
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