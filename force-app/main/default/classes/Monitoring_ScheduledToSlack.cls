public class Monitoring_ScheduledToSlack implements Schedulable {
        
    public void execute(SchedulableContext ctx) {   
        monitorLeadPoolSignupsPull();
    }
    
    public static String signupsMonitoringResult;

    static void monitorLeadPoolSignupsPull() {
        
        List<bb_signups_controls__c> csToUpdate = new List<bb_signups_controls__c>();
        
        //checks the main cs and notify on 2 hour gap between now and last successfull signups pull or if inactive for some reason        
        List<bb_signups_controls__c> mainSignUpsPulls = new List<bb_signups_controls__c>([SELECT id, last_success_datetime__c, number_of_failures_in_a_row__c, active__c, notification_sent__c 
        FROM bb_signups_controls__c WHERE Name = 'pull_signups' AND notification_sent__c = false LIMIT 1]);
        bb_signups_controls__c mainSignUpsPull = mainSignUpsPulls[0];
        if (mainSignUpsPull == null || !mainSignUpsPull.active__c ||  Datetime.now().addHours(-2) > mainSignUpsPull.last_success_datetime__c) {
            System.debug('Main pull is inactive or has 2 hour time gap from last success. Last success: ' +mainSignUpsPull?.last_success_datetime__c+ '. UTC time now: ' +Datetime.now());
            Utilities.sendSlackMessage('Signups main pull is inactive or has 2 hour time gap from last success' , 'biz-tech-monitoring', null , null, null, 'Last Success: ' + mainSignUpsPull?.last_success_datetime__c + ' (UTC)', null);
            signupsMonitoringResult = 'Main CS Inactive';
            mainSignUpsPull.notification_sent__c = true;
            csToUpdate.add(mainSignUpsPull);
        }
        //check if there are any new recovery cs created
        List<bb_signups_controls__c> newRecoveries = new List<bb_signups_controls__c>([SELECT id, last_success_datetime__c, number_of_failures_in_a_row__c, exception_subject__c, exception_body__c, active__c, notification_sent__c 
        FROM bb_signups_controls__c WHERE is_recovery__c = true AND notification_sent__c = false AND number_of_failures_in_a_row__c = 5]);
        for (bb_signups_controls__c recovery_cs : newRecoveries) {
            System.debug('Found inactive recovery pull: ' + recovery_cs.exception_subject__c + ' Error: ' + recovery_cs.exception_body__c);
            Utilities.sendSlackMessage(recovery_cs.exception_subject__c + ' (Recovery)' , 'biz-tech-monitoring', null , null, null, recovery_cs.exception_body__c, null);
            signupsMonitoringResult = 'Recovery CS Inactive';
            recovery_cs.notification_sent__c = true;
            csToUpdate.add(recovery_cs);
        }
        update csToUpdate;
    }
}