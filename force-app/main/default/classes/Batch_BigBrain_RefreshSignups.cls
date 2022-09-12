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
            set<Id> unlimited_rt = new set<Id>{Utilities.preLeadRecordTypeId, Utilities.internalLeadRecordTypeId, Utilities.partnerLeadRecordTypeId};
            String query = 'select id, primary_pulse_account_id__c, passed_14_days_since_signup__c from Lead where primary_pulse_account_id__c != null and passed_14_days_since_signup__c = false'; //trial not expired - for all
            if(this.IS_LIMITED) query += ' and RecordTypeId =: rawSignupRtId and Signup_Cleanup_Reason__c = \'domain_null\''; //limited - raw signus with domain null
            else query += ' and RecordTypeId in: unlimited_rt'; //unlimited - pre/internal/partner leads refresh score, engagement and numberOfEmployees in case it was null before
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