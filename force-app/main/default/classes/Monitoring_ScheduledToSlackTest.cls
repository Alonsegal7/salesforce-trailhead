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
        System.assertEquals('Main CS Inactive', Monitoring_ScheduledToSlack.signupsMonitoringResult);
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
        System.assertEquals('Main CS Inactive', Monitoring_ScheduledToSlack.signupsMonitoringResult);
    }

    @isTest
    static void shouldSlackOnNewRecoveryPull() {
        
        bb_signups_controls__c recoveryPull = new bb_signups_controls__c(name = 'recovery', last_success_datetime__c = Datetime.now().addHours(-5), active__c = false, is_recovery__c = true, number_of_failures_in_a_row__c = 5);
        bb_signups_controls__c activePull = new bb_signups_controls__c(name = 'pull_signups', last_success_datetime__c = Datetime.now().addHours(-1), active__c = true);
        insert new List<bb_signups_controls__c>{recoveryPull,activePull};
        
        Test.startTest();
        Monitoring_ScheduledToSlack p = new Monitoring_ScheduledToSlack();
        String sch = '0 0 * * * ?';
        String jobId = System.schedule('TestScheduled', sch, p);
        Test.stopTest();
        
        recoveryPull = [SELECT Id, notification_sent__c FROM bb_signups_controls__c WHERE Id =: recoveryPull.Id];
        System.assertNotEquals(null, jobId);
        System.assertEquals('Recovery CS Inactive', Monitoring_ScheduledToSlack.signupsMonitoringResult);
        System.assertEquals(true, recoveryPull.notification_sent__c);
    }
}