public class Monitoring_ScheduledToSlack implements Schedulable {
        
    public void execute(SchedulableContext ctx) {   
        monitorLeadPoolSignupsPull();
    }
    
    public static String signupsMonitoringResult;

    //checks if there's more then 2 hour gap between now and last successfull signups pull or if the pull_signups is inactive (means there were 5 failed attempts)
    static void monitorLeadPoolSignupsPull() {
        
        bb_signups_controls__c mainSignUpsPull = [SELECT id, last_success_datetime__c, number_of_failures_in_a_row__c, active__c FROM bb_signups_controls__c WHERE Name = 'pull_signups' LIMIT 1];
        
        if (mainSignUpsPull == null || !mainSignUpsPull.active__c) {
            System.debug('Main pull is inactive. Last success: ' +mainSignUpsPull?.last_success_datetime__c+ '. UTC time now: ' +Datetime.now());
            Utilities.sendSlackMessage('Signups pull is inactive', 'biz-tech-monitoring', null , null, null, 'Last Success: ' + mainSignUpsPull?.last_success_datetime__c + ' (UTC)', null);
            signupsMonitoringResult = 'Inactive Pull Detected';   
        }
        else if (Datetime.now().addHours(-2) > mainSignUpsPull.last_success_datetime__c) {
            System.debug('found 2 hour gap between: ' +mainSignUpsPull.last_success_datetime__c+ ' and now: ' +Datetime.now());
            Utilities.sendSlackMessage('Signups pull failed', 'biz-tech-monitoring', null , null, null, 'Last Success: ' + mainSignUpsPull.last_success_datetime__c + ' (UTC)', null);   
            signupsMonitoringResult = 'Time Gap Detected';   
        }
    }
}