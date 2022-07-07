public without sharing class Batch_PartnersPOSurveySend implements Database.Batchable<sObject>,Schedulable,Database.Stateful{

    private List<String> emailRecepients = new List<String>{'kseniasm@monday.com','avivc@monday.com'};
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
        List<String> types = new List<String>{'Partners - Post Onboarding', 'Partners - Ongoing'};
        String query = 'select Id, Survey_Type__c, Account__c, Contact__c, Partner_PO_Survey_Opportunity__c, Survey_Sent_Date__c, Account__r.Plan_Tier__c, Account__r.Plan_Seats__c,';
        query += ' Account__r.Monday_Account_Status__c, Account__r.Channel_Partner__c, Account__r.Partner__c, Account__r.Partner_CSM__c, Account__r.PSM__c, PCSM__c, PSM__c, Partner__c from Survey__c';
        query += ' where Survey_Sent_Date__c <= TODAY AND Survey_Type__c in: types AND Survey_Status__c = \'Future\' AND Canceled__c = False';
        try{
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnersPOSurveySend start: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Survey__c> scope){
        try{
            List<Survey__c> surveysToCancel = new List<Survey__c>();
            List<Survey__c> surveysToUpdate = new List<Survey__c>();
            List<Survey__c> surveysToCreate = new List<Survey__c>();
            List<Survey__c> surveysToCreate_future = new List<Survey__c>();
            Map<Id,Survey__c> accountToSurvey_map = new Map<Id,Survey__c>();
            Integer monthsToAdd;
            for(Survey__c s: scope){
                if(!Test.isRunningTest()){
                    if(s.Account__r.Plan_Tier__c != 'Enterprise' || 
                            (s.Survey_Type__c == 'Partners - Ongoing' && s.Account__r.Plan_Seats__c < 100) || 
                            s.Account__r.Monday_Account_Status__c != 'Paying Account' || 
                            s.Account__r.Channel_Partner__c == null){ //check if survey is not matching criterias for sending - cancel
                        surveysToCancel.add(new Survey__c(
                            Id = s.Id,
                            Canceled__c = true
                        ));
                        continue;
                    }
                }
                accountToSurvey_map.put(s.Account__c, s);
                //generate future surveys
                if(s.Survey_Type__c == 'Partners - Post Onboarding') monthsToAdd = 3;
                else if(s.Survey_Type__c == 'Partners - Ongoing') monthsToAdd = 6;
                else continue;
                surveysToCreate_future.add(new Survey__c(
                    Account__c = s.Account__c,
                    Survey_Type__c = 'Partners - Ongoing',
                    Survey_Sent_Date__c = Date.today().addMonths(monthsToAdd),
                    PCSM__c = s.Account__r.Partner_CSM__c,
                    PSM__c = s.Account__r.PSM__c,
                    Partner__c = s.Account__r.Channel_Partner__c,
                    Survey_Status__c = 'Future'
                ));
            }
            if(!surveysToCancel.isEmpty()) Database.update(surveysToCancel);
            if(accountToSurvey_map.isEmpty()) return;
            //get all Account Contact Relationships
            List<AccountContactRelation> acr_list = [select Id, 
                                                    AccountId, Account.Name, 
                                                    ContactId, Contact.Name, Contact.PCSM_Champion__c
                                                    from AccountContactRelation 
                                                    where AccountId in: accountToSurvey_map.keySet()];
            if(acr_list.isEmpty()) return;
            //mark accounts with champions contacts - for those accounts only champions will recieve surveys, otherwise all contacts will recieve
            Set<Id> accountsWithChampions = new Set<Id>();
            for(AccountContactRelation acr: acr_list){
                if(acr.Contact.PCSM_Champion__c) accountsWithChampions.add(acr.AccountId);
            }
            //generate surveys
            for(AccountContactRelation acr: acr_list){
                if(accountsWithChampions.contains(acr.AccountId) && !acr.Contact.PCSM_Champion__c) continue; //accounts with champions contacts - for those accounts only champions will recieve surveys, otherwise all contacts will recieve
                Survey__c existingSurvey = accountToSurvey_map.get(acr.AccountId);
                if(existingSurvey.Contact__c == null){ // existing survey not assigned yet
                    existingSurvey.Contact__c = acr.ContactId;
                    surveysToUpdate.add(existingSurvey);
                } else { // existing survey is assigned already to first contact - create new surveys for the rest of the contacts
                    surveysToCreate.add(new Survey__c(
                        Account__c = acr.AccountId,
                        Contact__c = acr.ContactId,
                        Partner_PO_Survey_Opportunity__c = existingSurvey.Partner_PO_Survey_Opportunity__c,
                        Survey_Sent_Date__c = existingSurvey.Survey_Sent_Date__c,
                        Survey_Type__c = existingSurvey.Survey_Type__c,
                        PCSM__c = existingSurvey.PCSM__c,
                        PSM__c = existingSurvey.PSM__c,
                        Partner__c = existingSurvey.Partner__c,
                        Survey_Status__c = 'Future'
                    ));
                }
                debugString += '<br/><a href="https://monday.lightning.force.com/lightning/r/Contact/'+acr.ContactId+'/view">'+acr.Contact.Name+'</a> ('+acr.account.name+') will recieve survey.';
            }
            //update & insert the surveys
            if(!surveysToUpdate.isEmpty()) Database.update(surveysToUpdate);
            list<Survey__c> surveysToCreateTotal = new list<Survey__c>(surveysToCreate);
            surveysToCreateTotal.addAll(surveysToCreate_future);
            if(!surveysToCreateTotal.isEmpty()) Database.insert(surveysToCreateTotal);
            //set qualtrix trigger
            List<Survey__c> allTodaySurveys = new List<Survey__c>(surveysToUpdate);
            allTodaySurveys.addAll(surveysToCreate);
            for(Survey__c s: allTodaySurveys){
                s.Trigger_Outbound_Message_Qualtrix__c = 1;
                s.Survey_Status__c = 'Sent';
            }
            Database.update(allTodaySurveys);
            totalCons += allTodaySurveys.size();
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnersPOSurveySend execute: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
        }
    }
    
    public void finish(Database.BatchableContext BC){
        String emailTitle = 'Finished Sending Partners Post Onboarding Survey;';
        string emailBody = '';
        if(totalCons == 0){
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