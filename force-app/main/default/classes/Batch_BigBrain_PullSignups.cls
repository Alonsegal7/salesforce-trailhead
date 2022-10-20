public without sharing class Batch_BigBrain_PullSignups implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {

    public void execute(SchedulableContext SC) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this,1);
        } catch(Exception e){
            Utilities.sendEmail('Batch_BigBrain_PullSignups Schedulable Failed', e.getMessage() + e.getStackTraceString(), BigBrain_LeadPoolService.emailRecipients); 
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            String query = 'select last_success_datetime__c,number_of_failures_in_a_row__c,active__c,is_recovery__c from bb_signups_controls__c';
            query += ' where active__c = true order by last_success_datetime__c desc limit 50';
            return Database.getQueryLocator(query);
        } catch(Exception e){
            Utilities.sendEmail('Failed to pull signups (start)', e.getMessage() + e.getStackTraceString(), BigBrain_LeadPoolService.emailRecipients);  
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<bb_signups_controls__c> scope){
        try{
            Datetime from_dt;
            Datetime to_dt;
            bb_signups_controls__c cs = scope[0];
            if(cs.is_recovery__c){
                from_dt = cs.last_success_datetime__c.addSeconds(1);
                to_dt = from_dt.addMinutes(15).addSeconds(-1);
            }else{
                from_dt = cs.last_success_datetime__c.addSeconds(1);
                to_dt = datetime.now().addMinutes(-1);
                if(to_dt > from_dt.addMinutes(15)) to_dt = from_dt.addMinutes(15); //max interval is 15 mins - for testing
                // to_dt = to_dt > from_dt.addMinutes(15) ? from_dt.addMinutes(15) : datetime.now().addMinutes(-1); //normally there will be at least 15 mins gap between the from_dt and to_dt
            }
            BigBrain_LeadPoolService.getSignups(from_dt, to_dt, cs);
        } catch (Exception e) {
            Utilities.sendEmail('Failed to pull signups (execute)', e.getMessage() + e.getStackTraceString(), BigBrain_LeadPoolService.emailRecipients);   
        }
    }

    public void finish(Database.BatchableContext BC){}
}