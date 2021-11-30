public without sharing class Contract_Event_Daily_Update implements Database.Batchable<Contract_Event__c>, Database.Stateful,Schedulable{
    public Integer updatedConEvents=0;
    public Integer totalConEvntToUpdate=0;

    public Iterable<Contract_Event__c> start(Database.BatchableContext BC){
        return [select id, start_date__c, end_date__c, Contract__r.Status__c, Contract__r.Prior_Contract__r.Id from Contract_Event__c where Calculate_ARR__c=false and isrecurring__c=true and start_date__c=today];
    }

    public void execute(SchedulableContext sc) {
        try{
        Utilities.cleanFlexQueue();
        Database.executeBatch(this,20);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Contract_Event_Daily_Update ', e, e.getMessage());
            Utilities.sendSlackMessage('Error in Contract_Event_Daily_Update', 'biz-tech-monitoring', null , e, e.getMessage(), null, null);                        
        }
    }

    public void execute(Database.BatchableContext bc, List<Contract_Event__c> scope) {
        totalConEvntToUpdate=scope.size();
        Set<Id> priorConts = new Set<Id>();
        Map<Id, Id> oldContNewCont = new Map<Id, Id>();
        List<Contract_Event__c> conEventsToUpdate = new List<Contract_Event__c>();
        List<Account> accToUpdate = new List<Account>();
        Map<Id, string> contHandle = new Map<Id,string>();
        List<Contract> contToUpdate = new List<Contract>();

        for (Contract_Event__c conEvent : scope) {
            conEvent.Calculate_ARR__c=true;
            conEventsToUpdate.add(conEvent);
            updatedConEvents++;
            //Check if need to replace prior contract with new contract
            if (conEvent.Contract__r.Status__c=='Future Activation' && conEvent.Contract__r.Prior_Contract__c!=null && !priorConts.contains(conEvent.Contract__r.Prior_Contract__r.Id)) {
                priorConts.add(conEvent.Contract__r.Prior_Contract__r.Id);
                oldContNewCont.put(conEvent.Contract__r.Prior_Contract__c,conEvent.Contract__c);
                contHandle.put(conEvent.Contract__r.Id,'Active');
                contHandle.put(conEvent.Contract__r.Prior_Contract__r.Id,'Deactivated');     
            }
            if (conEvent.Contract__r.Status__c=='Future Activation' && conEvent.Contract__r.Prior_Contract__c==null && !contHandle.containskey(conEvent.Contract__r.Id)) {
                contHandle.put(conEvent.Contract__r.Id,'Active');
            }
        }
           //Replace prior contract with new contract
        if (!priorConts.isEmpty()) {
            List<Account> relevantAccounts = [select id, active_contract__c from account where active_contract__c IN: priorConts ];
            for (Account acc : relevantAccounts) {
                acc.active_contract__c=oldContNewCont.get(acc.active_contract__c);
                accToUpdate.add(acc);
            }
        }

        if (!contHandle.isEmpty()) {
            for (Contract con : [select Id, Status__c from Contract where Id IN:contHandle.keySet() ]) {
                con.Status__c=contHandle.get(con.Id);
                contToUpdate.add(con);
            }
        }

        if (!conEventsToUpdate.isempty()) {
            update conEventsToUpdate;
        }
        if (!accToUpdate.isempty()) {
            update accToUpdate;
        }    
        if (!contToUpdate.isempty()) {
            update contToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('Contract_Event_Daily_Update finished. amount # '+updatedConEvents);
        Utilities.sendEmail('Contract_Event_Daily_Update finished','Contract_Event_Daily_Update finished amount processed # '+updatedConEvents+' out of ' +totalConEvntToUpdate,new list<String>{'biztech@monday.com'});   
    }
}