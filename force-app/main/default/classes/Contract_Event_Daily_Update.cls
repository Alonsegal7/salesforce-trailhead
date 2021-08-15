public without sharing class Contract_Event_Daily_Update implements Database.Batchable<Contract_Event__c>, Database.Stateful,Schedulable{
    public Integer updatedConEvents=0;
    public Integer totalConEvntToUpdate=0;

    public Iterable<Contract_Event__c> start(Database.BatchableContext BC){
        return [select id, start_date__c, end_date__c from Contract_Event__c where Calculate_ARR__c=false and isrecurring__c=true and start_date__c=today];
    }

    public void execute(SchedulableContext sc) {
        Utilities.cleanFlexQueue();
        Database.executeBatch(this,20);
    }

    public void execute(Database.BatchableContext bc, List<Contract_Event__c> scope) {
        totalConEvntToUpdate=scope.size();
        List<Contract_Event__c> conEventsToUpdate = new List<Contract_Event__c>();
        for (Contract_Event__c conEvent : scope) {
            conEvent.Calculate_ARR__c=true;
            conEventsToUpdate.add(conEvent);
            updatedConEvents++;
        }
        update conEventsToUpdate;
    }
    public void finish(Database.BatchableContext bc) {
        system.debug('Contract_Event_Daily_Update finished. amount # '+updatedConEvents);
        Utilities.sendEmail('Contract_Event_Daily_Update finished','Contract_Event_Daily_Update finished amount processed #'+updatedConEvents+' out of' +totalConEvntToUpdate,new list<String>{'biztech@monday.com'});   
    }
}