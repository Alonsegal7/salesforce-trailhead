public without sharing class Batch_CreateRenewalOpportunities implements Schedulable, Database.Batchable<SObject>, Database.Stateful{
    public Integer oppsCreated=0;
    public date manualDate;

    public Batch_CreateRenewalOpportunities() {}

    //should be replaced with dynamic cmt
    public static Boolean getShouldRun() {
        // string getRenewalAutomaticCreationStatus = '';
        // Apex_Services_Status__mdt RenewalAutomaticCreationStatus = [SELECT Id, Label, Status__c FROM Apex_Services_Status__mdt WHERE Label = 'RenewalAutomaticCreation'][0];
		// getRenewalAutomaticCreationStatus = RenewalAutomaticCreationStatus.Status__c;
		// if (getRenewalAutomaticCreationStatus == 'Active'){
        //     return true;
        // }
        // else{
        //     return false;
        // }
        return false;
    }
    //should be replaced with dynamic cmt
    public static Integer getMonthToAdd() {
        return 2;
    }
    //for manual insert of a date 
    public Batch_CreateRenewalOpportunities(date inputManualDate) {
        this.manualDate = inputManualDate;
    }
    
    public void execute(SchedulableContext sc) {
        Batch_CreateRenewalOpportunities renewalBatch = new Batch_CreateRenewalOpportunities();
        Utilities.cleanFlexQueue();
        Database.executeBatch(renewalBatch,10);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
            date dueDate;
            if(this.manualDate != null){
                dueDate = this.manualDate;
    
            }else{
                dueDate = date.today().addMonths(getMonthToAdd());
    
           }
           System.debug('Scheduled_CreateRenewalOpportunities dueDate: '+ dueDate);
           String query = 'SELECT Id FROM Contract WHERE Primary_Renewal_Owner__c <> null and  Status__c = \'Active\' and Main_Monday_Account_Related__r.of_open_opps__c = 0 and((Renewal_Opportunity_Creation_Status__c <> \'Completed\' and EndDate =: dueDate) or Renewal_Opportunity_Creation_Status__c = \'Initiated\') ORDER BY EndDate DESC';
           System.debug('Scheduled_CreateRenewalOpportunities relevantContractsQuery: '+ query);
           return Database.getQueryLocator(query);
        }


    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Id> contractIds = new List<Id>();
        String automaticSource = 'Automatic Renewal Creation';
        List<Opportunity> renewalOppsCreated = new List<Opportunity>();
        for(sObject con : scope){
            contractIds.add(con.Id);
        }
        system.debug('Batch_CreateRenewalOpportunities Started. # of Relevant Renewal Contracts: '+contractIds.size());
        renewalOppsCreated = Opportunity_RenewalCreation.createRenewalOpportunities(contractIds,automaticSource);
        oppsCreated += renewalOppsCreated.size();
    }

    public void finish(Database.BatchableContext BC){
        system.debug('Batch_CreateRenewalOpportunities Finished. # of Renewal Opps Created: '+oppsCreated);
        Utilities.sendEmail('Finished Batch_CreateRenewalOpportunities Run', '# of Renewal Opps Created: '+oppsCreated ,new list<String>{'noamle@monday.com'});  
    }
}




