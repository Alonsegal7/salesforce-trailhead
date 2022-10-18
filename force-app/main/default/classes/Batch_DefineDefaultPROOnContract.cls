public without sharing class Batch_DefineDefaultPROOnContract implements Schedulable, Database.Batchable<SObject>, Database.Stateful{

    public Integer contractsUpdated=0;
    public date endDate;
    public Batch_DefineDefaultPROOnContract() {}

    //should be replaced with dynamic cmt
    public static Boolean getShouldRun() {
        return true;
    }

    //should be replaced with dynamic cmt
    public static Integer getMonthToAdd() {
        return 6;
    }

    public void execute(SchedulableContext sc) {
        Batch_DefineDefaultPROOnContract PROUpdateBatch = new Batch_DefineDefaultPROOnContract();
        Utilities.cleanFlexQueue();
        Database.executeBatch(PROUpdateBatch,20); 
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        date today = date.today();
        date dueDate = today.addMonths(getMonthToAdd());
        date conEndDateQ1 = date.newInstance(2023, 03, 31); 
        String query = 'SELECT Id,Primary_Renewal_Owner__c,Renewal_Manager__c,(SELECT Id, OwnerId,Channel_Partner__c,Owner_is_Partner__c,Owner.Segment__c,Owner.Business_Role__c,Owner.Profile.Name FROM Accounts__r ORDER BY ARR__C DESC NULLS LAST LIMIT 1) FROM Contract WHERE Status__c = \'Active\' AND Main_Monday_Account_Related__c <> null AND Last_Event_Payment_Method__c = \'WIRE\' AND Contract_ARR__c > 0 AND Period__c != \'Monthly\' AND ((EndDate =: dueDate AND  Primary_Renewal_Owner__c = null and EndDate <=: conEndDateQ1 ) OR Define_Default_PRO_Assignment__c=true) ORDER BY EndDate DESC';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Contract> scope){
        List<Contract> relevantContracts = new List<Contract>();
        List<Contract> contracstWithPro = new List<Contract>();
        for(Contract con : scope){
            relevantContracts.add(con);
        }
        system.debug('Batch_DefineDefaultPROOnContract Started. # of Relevant Renewal Contracts: '+relevantContracts.size());
        contracstWithPro = contract_DefineDefaultPROAssignment.contract_DefineDefaultPROAssignment(relevantContracts);
        contractsUpdated += contracstWithPro.size();
    }

    public void finish(Database.BatchableContext BC){
        system.debug('Batch_DefineDefaultPROOnContract Finished. # of contract has been updated: '+contractsUpdated);
        Utilities.sendEmail('Finished Batch_DefineDefaultPROOnContract Run', '# of contract has been updated: '+contractsUpdated ,new list<String>{'noamle@monday.com'});  
    }
}






