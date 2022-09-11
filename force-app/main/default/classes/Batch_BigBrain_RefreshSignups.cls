public without sharing class Batch_BigBrain_RefreshSignups implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts,Database.Stateful {
    public boolean IS_LIMITED = false;
    private Integer refreshed_cntr = 0;
    private Integer failed_cntr = 0;

    public Batch_BigBrain_RefreshSignups(Boolean limited){
        this.IS_LIMITED = limited; 
    }

    public void execute(SchedulableContext SC) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this, 100);
        } catch(Exception e){
            Utilities.sendEmail('Batch_BigBrain_RefreshSignups Schedulable Failed', e.getMessage() + e.getStackTraceString(), BigBrain_LeadPoolService.emailRecipients); 
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try {
            Id rawSignupRtId = Utilities.rawSignupRecordTypeId;
            Id preLeadRtId = Utilities.preLeadRecordTypeId;
            Datetime trial_dt = Date.today().addDays(-13);
            String query = 'select id, primary_pulse_account_id__c from Lead where primary_pulse_account_id__c != null and createdDate >=: trial_dt'; //trial not expired - for all
            if(this.IS_LIMITED) query += ' and RecordTypeId =: rawSignupRtId and Signup_Cleanup_Reason__c = \'domain_null\''; //limited - raw signus with domain null
            else query += ' and RecordTypeId =: preLeadRtId'; //unlimited - pre leads , get score and engagement
            return Database.getQueryLocator(query);
        } catch(Exception e){
            Utilities.sendEmail('Failed to refresh data (start)', e.getMessage() + e.getStackTraceString(), BigBrain_LeadPoolService.emailRecipients); 
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<lead> scope){
        set<string> pulse_account_ids = new set<string>();
        try {
            System.debug('entered execute, limited is: '+this.IS_LIMITED);
            for(lead l: scope){
                pulse_account_ids.add(l.primary_pulse_account_id__c);
            }
            Map<String,Object> res = BigBrain_LeadPoolService.refreshSignups(new list<string>(pulse_account_ids), this.IS_LIMITED);
            String status = res.get('status') != null ? String.valueOf(res.get('status')) : null;
            if(status == 'success') this.refreshed_cntr += Integer.valueOf(res.get('refreshed_cntr'));
            else if(status == 'error') this.failed_cntr += scope.size();
        } catch (Exception e) {
            Utilities.sendEmail('Failed to refresh data (execute)', e.getMessage() + e.getStackTraceString(), BigBrain_LeadPoolService.emailRecipients); 
            this.failed_cntr += scope.size();  
        }
    }

    public void finish(Database.BatchableContext BC){
        String subject = 'Finished refresh data';
        if(this.IS_LIMITED) subject += ' for raw signups in trial with blank domain';
        else subject += ' for pre leads in trial';
        Utilities.sendEmail(subject, 'num of refreshed records: '+this.refreshed_cntr + '; num of failed records: '+this.failed_cntr, BigBrain_LeadPoolService.emailRecipients); 
    }
}
