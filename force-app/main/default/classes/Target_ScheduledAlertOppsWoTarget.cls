public class Target_ScheduledAlertOppsWoTarget implements Schedulable{
    public void execute(SchedulableContext SC) {
        // GET ALL EXISTING TARGETS FOR CURR MONTH
        list<Target__c> thisMonthTarget = [select Id, User__r.Id from Target__c where Target_Date__c = THIS_MONTH];
        Set<Id> usersWithTarget = new Set<Id>();
        for(Target__c target: thisMonthTarget){
            usersWithTarget.add(target.User__r.Id);
        }
        // LOOK FOR OPPS WITH OWNER THAT HAS A TARGET FOR CURR MONTH BUT OPP IS NOT CONNECTED TO A TARGET
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([select Id from Opportunity where Target__c = null and OwnerId IN: usersWithTarget and CloseDate = THIS_MONTH]);
        Decimal beforeFixSize = oppsMap.size();
        String failedToFixOppIdsString = '';
        String oppIdsToFixString = '';

        if(beforeFixSize > 0){
            oppIdsToFixString = oppsMap.keySet().toString();
            // RUN MANUAL FIX IF SUCH OPPS FOUND...
            for(Opportunity opp: oppsMap.values()){
                opp.Manual_Trigger__c = 'Link Target';
            }

            Database.update(oppsMap.values());
            oppsMap = new Map<Id, Opportunity>([select Id from Opportunity where Target__c = null and OwnerId IN: usersWithTarget and CloseDate = LAST_MONTH and StageName = 'Closed Won']);
            Decimal afterFixSize = oppsMap.size();
            if(afterFixSize > 0){
                failedToFixOppIdsString = oppsMap.keySet().toString();
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
        if(failedToFixOppIdsString != ''){
            req.errorMessage = 'ATTENTION! Found opps without target (manual fix failed): ' + failedToFixOppIdsString;
        }
        if(oppIdsToFixString != ''){
            req.additionalInfo = 'WARNING! Found opps without target and tried to run manual fix: ' + oppIdsToFixString;
            if(failedToFixOppIdsString == ''){
                req.additionalInfo = 'RESULT: MANUAL FIX SUCCESSEFULLY FINISHED FOR ALL OPPS! :) ' + req.additionalInfo;
            }
        } else {
            req.additionalInfo = 'RESULT: All this month opps have a target! YAY :)';
        }
        req.recordId=''; 
        requests.add(req);
        Slack_MessageService.sendToSlack(requests);
    }
}