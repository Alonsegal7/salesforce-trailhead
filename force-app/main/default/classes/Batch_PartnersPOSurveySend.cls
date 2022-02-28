public without sharing class Batch_PartnersPOSurveySend implements Database.Batchable<sObject>,Schedulable,Database.Stateful{

    private List<String> emailRecepients = new List<String>{'kseniasm@monday.com','avivc@monday.com'};
    private Set<Id> res = new Set<Id>();
    private integer totalCons = 0;
    private string debugString = '';
    private Boolean dryRun = false;

    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Batch_PartnersPOSurveySend batch = new Batch_PartnersPOSurveySend();
            Database.executeBatch(batch, 30);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_PartnersPOSurveySend ', e, e.getMessage());   
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select Id, Name, AccountId, Account.Name, Of_Post_Onboarding_Surveys__c from Contact where Account.Next_PO_Survey_Date__c = TODAY';
        try{
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnersPOSurveySend start: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Contact> scope){
        try{
            List<Contact> contactsToUpdate = new List<Contact>();
            for(Contact con: scope){
                debugString += '<br/><a href="https://monday.lightning.force.com/lightning/r/Contact/'+con.Id+'/view">'+con.Name+'</a> ('+con.account.name+') will recieve survey.';
                Decimal numOfSurveys = con.Of_Post_Onboarding_Surveys__c;
                contactsToUpdate.add(new Contact(
                    Id = con.Id,
                    Last_Opportunity_For_Survey__c = 
                    Partners_Post_Onboarding_Survey_Date__c = Date.today(), 
                    Of_Post_Onboarding_Surveys__c = numOfSurveys + 1
                ));
            }
            if(!contactsToUpdate.isEmpty()) Database.update(contactsToUpdate);
            totalCons = contactsToUpdate.size();
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnersPOSurveySend execute: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
        }
    }
    
    public void finish(Database.BatchableContext BC){
        String emailTitle = 'Finished Sending Partners Post Onboarding Survey;';
        string emailBody = '';
        if(res.isEmpty()){
            emailTitle += ' total contacts: 0';
            emailBody += 'No surveys sent today.';
        } else {
            emailTitle += ' total contacts: ' + totalCons;
            emailBody += 'Contacts List:<br/>' + debugString;
        }
        if(dryRun) emailBody = 'DRY RUN: ' + emailBody;
        Utilities.sendEmail(emailTitle, emailBody, emailRecepients); 
    }
}