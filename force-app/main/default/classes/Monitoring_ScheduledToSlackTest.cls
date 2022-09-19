@isTest
public with sharing class Monitoring_ScheduledToSlackTest {
    
    @isTest
    static void shouldSlackOnSignupsError() {

        bb_signups_controls__c activePull = new bb_signups_controls__c(name = 'pull_signups', last_success_datetime__c = Datetime.now().addHours(-3), active__c = true);
        insert activePull;
        
        Test.startTest();
        Monitoring_ScheduledToSlack p = new Monitoring_ScheduledToSlack();
        String sch = '0 0 * * * ?';
        String jobId = System.schedule('TestScheduled', sch, p);
        Test.stopTest();

        System.assertNotEquals(null, jobId);
        System.assertEquals('Time Gap Detected', Monitoring_ScheduledToSlack.signupsMonitoringResult);
    }
    
    @isTest
    static void shouldSlackOnSignupsInactive() {
        
        bb_signups_controls__c activePull = new bb_signups_controls__c(name = 'pull_signups', last_success_datetime__c = Datetime.now().addHours(-1), active__c = false);
        insert activePull;
        
        Test.startTest();
        Monitoring_ScheduledToSlack p = new Monitoring_ScheduledToSlack();
        String sch = '0 0 * * * ?';
        String jobId = System.schedule('TestScheduled', sch, p);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId);
        System.assertEquals('Inactive Pull Detected', Monitoring_ScheduledToSlack.signupsMonitoringResult);
    }
}
