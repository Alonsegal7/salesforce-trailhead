public without sharing class Batch_PartnersPOSurveyNextDate implements Database.Batchable<sObject>,Schedulable,Database.Stateful{

    private List<String> emailRecepients = new List<String>{'kseniasm@monday.com','avivc@monday.com'};
    private Set<Id> res = new Set<Id>();
    private string debugString = '';
    private Boolean dryRun = false; //a flag to simulate a run without actually updating anything (for testing)

    public Batch_PartnersPOSurveyNextDate(){
    }

    public Batch_PartnersPOSurveyNextDate(Boolean isDryRun){
        //dry run only counts how many accounts match the survey conditions
        this.dryRun = isDryRun;
    }

    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Batch_PartnersPOSurveyNextDate batch = new Batch_PartnersPOSurveyNextDate();
            Database.executeBatch(batch, 30);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_PartnersPOSurveyNextDate ', e, e.getMessage());   
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = Partners_POSurveyHelper.baseQuery();
        try{
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnersPOSurveyNextDate start: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Opportunity> scope){
        try{
            Partners_POSurveyHelper helper = new Partners_POSurveyHelper(scope, dryRun);
            debugString += helper.checkSurveyConditions(res);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnersPOSurveyNextDate execute: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
        }
    }
    
    public void finish(Database.BatchableContext BC){
        String emailTitle = 'Finished Partners Survey Next Date Batch;';
        string emailBody = '';
        if(res.isEmpty()){
            emailTitle += ' total accounts: 0;';
            emailBody += 'No accounts updated today.<br/>' + debugString;
        } else {
            emailTitle += ' total accounts: ' + res.size();
            emailBody += 'Surveys dates were updated on ' + string.valueOf(res.size()) + ' accounts. <br/>' + debugString;
        }
        if(dryRun) emailBody = 'DRY RUN: ' + emailBody;
        Utilities.sendEmail(emailTitle, emailBody, emailRecepients); 
    }
}