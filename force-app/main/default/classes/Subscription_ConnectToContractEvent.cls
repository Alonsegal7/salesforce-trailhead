public without sharing class Subscription_ConnectToContractEvent {
    public static void Subscription_ConnectToContract(List<Subscription__c> newSubs, map<Id, Subscription__c> oldMap) {
        try{
            set<string> subsPulseIds= new set<string>();
            if(oldMap==null)//insert
                for(Subscription__c sub: newSubs){
                    subsPulseIds.add(sub.Pulse_Account_Id__c);
                }
            else{//update only for Manual Trigger
                for(Subscription__c sub: newSubs){
                    if(sub.Manual_Trigger__c!=oldMap.get(sub.id).Manual_Trigger__c&&sub.Manual_Trigger__c=='Create Active Contract')
                        subsPulseIds.add(sub.Pulse_Account_Id__c);
                }
            }
            if(subsPulseIds.isEmpty())
                return;

            map<string,Account> accountsByPulseId= new map<string,Account>(); 
            for(Account acc: [select id,primary_pulse_account_id__c,Active_Contract__c,Company__c,Active_Contract__r.EndDate
                                from Account where primary_pulse_account_id__c in: subsPulseIds]){
                if(!accountsByPulseId.containsKey(acc.primary_pulse_account_id__c))
                    accountsByPulseId.put(acc.primary_pulse_account_id__c,acc);
            }
            List<Contract> contractsToUpdate= new List<Contract>();
            List<Contract> contractsToDeactivate= new List<Contract>();

            for(Subscription__c sub: newSubs){
                if(accountsByPulseId.containsKey(sub.Pulse_Account_Id__c)){
                    Account acc=accountsByPulseId.get(sub.Pulse_Account_Id__c);
                    sub.Monday_Account__c=acc.Id;
                     if(sub.Status__c=='ACTIVE'&&sub.Contract__c==null){//if contract is selected in BB, do not create/connect to another contract
                        if(acc.Active_Contract__c!=null&&sub.Deactivation_Date__c<=acc.Active_Contract__r.EndDate){//connect to existing active contract
                            sub.Contract__c=acc.Active_Contract__c;
                            if(sub.SO_Import_Type__c=='Pro-rated'){//for pro rated deal imported in BB, do not update prices as they are not aligned in BB
                                contractsToUpdate.add(new contract(id=sub.Contract__c,
                                                                    Seats__c=integer.valueof(sub.Seats__c)));
                            }else{
                                contractsToUpdate.add(new contract(id=sub.Contract__c,
                                                                    Seats__c=integer.valueof(sub.Seats__c),
                                                                    List_Price__c=sub.List_Price__c,
                                                                    Unit_Price__c=sub.Unit_Price__c,
                                                                    Discount__c=sub.Discount__c));
                            }
                        }
                        else if(acc.Active_Contract__c!=null&&sub.Deactivation_Date__c>acc.Active_Contract__r.EndDate) {//Active Contract is related to the account and subscription dates are above contract end date -needs to decativate
                                contractsToDeactivate.add(new contract(id=acc.Active_Contract__c,Status__c='Deactivated'));
                        }
                    }
                }
            }
            //Values for sub creation will kept for pilot    
            if(!contractsToUpdate.isempty())
            update contractsToUpdate;

            if(!contractsToDeactivate.isempty())
            update contractsToDeactivate;


        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Subscription_ConnectToContract ',e,e.getMessage()+'Cons To Create');   
        }

    }

    public static void SubscriptionToContractEvent(List<Subscription__c> newSubs, map<Id, Subscription__c> oldMap) {
        try {
        Map<Id, Subscription__c> subsMapToGetARR = new Map<Id, Subscription__c>();
        List <Subscription__c> subsConEventToCreate = new List <Subscription__c>();
        List <Subscription__c> subsConEventToUpdate = new List <Subscription__c>();
        Map<Id, List<Contract_Event__c>> existingContractAndconEventMap = new Map<Id, List<Contract_Event__c>>();
        List <Contract_Event__c> proRatedConEventToCreate = new List<Contract_Event__c>();
        Set<Id> contractIds = new Set<Id>();
        
        //First, Create a set of contract id's from subs to define a map of contract events related to the set(Used later in SameTermEventExist function)
        for (Subscription__c sub : newSubs) {
            if (sub.Contract__c!=null) {
                contractIds.add(sub.Contract__c);
            }
        }
        if (!contractIds.isEmpty()) {
             //Prepere a map to check if there is a contract event with the same term for this subscription  (Used later in SameTermEventExist function)
            for (Contract_Event__c existingConEvnt : [select Id,Contract__c, Start_Date__c, End_Date__c, ARR__c, IsRecurring__c from Contract_Event__c where IsRecurring__c=true and Contract__c in:contractIds ])
            {
                if (existingContractAndconEventMap.containsKey(existingConEvnt.Contract__c)) {
                    existingContractAndconEventMap.get(existingConEvnt.Contract__c).add(existingConEvnt);
                }
                else {
                    existingContractAndconEventMap.put(existingConEvnt.Contract__c, new List <Contract_Event__c>{existingConEvnt});
                }
            }      
        }

            if (oldMap==null) {//insert 
                for (Subscription__c sub : newSubs) {
                    //Contract was added on the 'before' trigger
                    //Contract event fields is mapped on the ContractEventMapping__mdt (Including the contract created on the before)
                    if(sub.Status__c=='ACTIVE'&&sub.Contract__c!= null&&sub.Activated_via_Import_SO__c==false && !SameTermEventExist(existingContractAndconEventMap,sub)){
                        subsConEventToUpdate.add(sub);
                        proRatedConEventToCreate.addall(ContractEventHandler.DefineContractEvent(subsConEventToUpdate));
                    }
                    //Contract wasn't found on before trigger and didn't imported by so- create contract and event
                    if (sub.Status__c=='ACTIVE'&&sub.Contract__c==null&&sub.Activated_via_Import_SO__c==false) {
                        subsConEventToCreate.add(sub); 
                    }
                }
            }
             
            else {
                for (Subscription__c sub : newSubs) {
                    if(sub.Manual_Trigger__c!=oldMap.get(sub.id).Manual_Trigger__c&&sub.Manual_Trigger__c=='Create Active Contract'){
                        subsConEventToCreate.add(sub);
                    }
                    if (sub.Status__c=='ACTIVE' && sub.arr__c !=null && oldMap.get(sub.id).arr__c==null && sub.contract__c!=null ) {
                        subsMapToGetARR.put(sub.id,sub);
                    } 
                }
            }
                    //Contract event for existing contract
                    if (!proRatedConEventToCreate.isempty()) {
                        System.enqueueJob(new createContractEventsQueueable(proRatedConEventToCreate));
                    }
                    //New contract and contract event
                    if (!subsConEventToCreate.isempty()) {
                        ContractEventHandler.ActivationsContractEventNewContracts(subsConEventToCreate);
                    }
                    //update arr to con event is added after insert (and it was null)
                    if (!subsMapToGetARR.isEmpty()) {
                        updateArrToEvent(subsMapToGetARR);
                    }   

        }catch(Exception e){
            Utilities.sendDebugEmail('Error in SubscriptionToContractEvent ',e,e.getMessage());   
        }
    }
    //Function to check if a subscription holds the same start date, and date, and ARR of contract events - to avoid duplication
    public static Boolean SameTermEventExist(Map<Id, List<Contract_Event__c>> conEvnts, Subscription__c sub){
        Boolean evntExist = false;
        for (Id conKey : conEvnts.keyset()) {
            for (Contract_Event__c singleEvent : conEvnts.get(conKey)) {
                 if (singleEvent.Contract__c==sub.Contract__c&&singleEvent.Start_Date__c==sub.Activation_Date__c && 
                     singleEvent.End_Date__c==sub.Deactivation_Date__c && 
                     singleEvent.ARR__c==sub.ARR__c) {
                     evntExist=true;  
                }
            }
        }
        return evntExist; 
    }
    //There are cases that the arr is inserted to the subscription__c after he created - we need to update the contract event
    public static void updateArrToEvent(Map<Id,Subscription__c> subs){
        List<contract_event__c> conEvntsToUpdate = new List<contract_event__c>();
        for (contract_event__c conEvn:[select id, ARR__c,subscription__c from contract_event__c where subscription__c in:subs.keyset() ]){
            conEvn.arr__c = subs.get(conEvn.subscription__c).arr__c;
            conEvntsToUpdate.add(conEvn);
        }
        update conEvntsToUpdate;
    }

    private class createContractEventsQueueable implements System.Queueable {
        private List<Contract_Event__c> contractEventToCreateList; 
        public createContractEventsQueueable(List<Contract_Event__c> contractEventToCreateList) {
            this.contractEventToCreateList = contractEventToCreateList;
        }
        public void execute(System.QueueableContext ctx) {
            Database.insert(contractEventToCreateList);
        }
    }
}


