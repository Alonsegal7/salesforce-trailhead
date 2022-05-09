public without sharing class Batch_CreateRenewalOpportunities implements Schedulable, Database.Batchable<SObject>, Database.Stateful{
    
    
    public Integer oppsCreated=0;
    public date endDate;

    public Batch_CreateRenewalOpportunities() {}

    //should be replaced with dynamic cmt
    public static Boolean getShouldRun() {
        return true;
    }

    //should be replaced with dynamic cmt
    public static Integer getMonthToAdd() {
        return 4;
    }
    
    public void execute(SchedulableContext sc) {
        if (!getShouldRun()) return;
        date today = date.today();
        date dueDate = today.addMonths(getMonthToAdd());
        System.debug('Scheduled_CreateRenewalOpportunities dueDate: '+ dueDate);
        Batch_CreateRenewalOpportunities renewalBatch = new Batch_CreateRenewalOpportunities(dueDate);
        Utilities.cleanFlexQueue();
        Database.executeBatch(renewalBatch,20);
    }

    public Batch_CreateRenewalOpportunities(date dueDate) {
        endDate = dueDate;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Contract WHERE Renewal_Opportunity_Creation_Status__c <> \'Completed\' and Status__c = \'Active\' and EndDate =: endDate and Primary_Renewal_Owner__c <> null  ORDER BY EndDate DESC';
        System.debug('Scheduled_CreateRenewalOpportunities relevantContractsQuery: '+ query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Id> contractIds = new List<Id>();
        List<Opportunity> renewalOppsCreated = new List<Opportunity>();
        for(sObject con : scope){
            contractIds.add(con.Id);
        }
        system.debug('Batch_CreateRenewalOpportunities Started. # of Relevant Renewal Contracts: '+contractIds.size());
        renewalOppsCreated = Opportunity_RenewalCreation.createRenewalOpportunities(contractIds);
        oppsCreated += renewalOppsCreated.size();
    }

    public void finish(Database.BatchableContext BC){
        system.debug('Batch_CreateRenewalOpportunities Finished. # of Renewal Opps Created: '+oppsCreated);
        Utilities.sendEmail('Finished Batch_CreateRenewalOpportunities Run', '# of Renewal Opps Created: '+oppsCreated ,new list<String>{'michaelim@monday.com'});  
    }
}
