public with sharing class ContractEventToContract {
    public static Map<string, id> createdContForSubOrder = new Map<string, id>();
    public static void ContractEventCreateNewContract(Map<Id, List<Contract_Event__c>> conEvents, List<SObject> objects, string objType) {
       try{
        List<Contract_Event__c> conEventToInsert = new List<Contract_Event__c>();
        Map<string, Contract_Product__c> conProdMap = new Map<string, Contract_Product__c>();
        Map<Id,Contract> createdContsMap = new Map<Id, Contract>();
        List<Quote> quoteToUpdate = new List<Quote>();
        List<Account> masterMondayAccountToUpdate = new List<Account>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Subscription__c> subsToUpdate = new List<Subscription__c>();
        List<Contract> contractToDeactivate = new List<Contract>();
        List<Contract> priorContractsToUpdate = new List<Contract>();

        //Find the Contract_Creation_Product__c event to create contract (There could be many - for now, take the frist added)
        for (Id key : conEvents.keyset()) {
            Boolean contracCreated=false;
            for (Contract_Event__c conEvnt : conEvents.get(key)) {
                if (conEvnt.Contract_Creation_Product__c && contracCreated==false) {
                    Contract newCon = createContract(conEvnt);
                    createdContsMap.put(key, newCon);
                    contracCreated=true;
                }
            }
        }
        //Now, insert the contract and assign the contract events to the created contract     
        if (!createdContsMap.isEmpty()) {
            insert createdContsMap.values();
            for (Id key : conEvents.keyset()) {
                for (Contract_Event__c conEvnt : conEvents.get(key)) {
                    conProdMap.put(string.valueof(createdContsMap.get(key).Id) + string.valueof(conEvnt.Product__c),createContractProduct(conEvnt,createdContsMap.get(key)));
                    conEvnt.contract__c=createdContsMap.get(key).Id;
                    conEventToInsert.add(conEvnt);
                }
            }
        }
        //Set a contract product for each contract event
        if (!conProdMap.isEmpty()) {
            insert conProdMap.values();
        }
        //Update the inserted contract products to the contract events
        for (Contract_Event__c conEvnt : conEventToInsert) {
            conEvnt.Contract_Product__c=conProdMap.get(string.valueof(conEvnt.Contract__c)+string.valueof(conEvnt.Product__c)).Id;
        }
        //Insert contract events
        if (!conEventToInsert.isEmpty()) {
            insert conEventToInsert;
        }
        //After the contracts created, update it on Master monday account, opp, chain prior contract (if exist) and quote and deactivate selected company contract
        if (objType=='Quote') {
            for (SObject obj : objects) { 
                masterMondayAccountToUpdate.add(new Account(Id=(Id)obj.get('AccountId'),Active_Contract__c = createdContsMap.get(obj.Id).Id));
                oppsToUpdate.add(new Opportunity(Id=(Id)obj.get('OpportunityId'),ContractId=createdContsMap.get(obj.Id).Id));
                quoteToUpdate.add(new Quote(Id=obj.Id,ContractId=createdContsMap.get(obj.Id).Id));
                if (obj.get('Manual_Trigger__c')=='Create Active Contract') {
                    if (obj.get('ContractId')!=null) {
                        contractToDeactivate.add(new Contract(Id=(Id)obj.get('ContractId'), Status__c='Deactivated'));
                        priorContractsToUpdate.add(new Contract(Id=createdContsMap.get(obj.Id).Id,Prior_Contract__c=(Id)obj.get('ContractId')));
                    }
                }
                else {
                    if (obj.get('Selected_Company_Contract__c')!=null) {
                        contractToDeactivate.add(new Contract(Id=(Id)obj.get('Selected_Company_Contract__c'), Status__c='Deactivated'));//For pilot, the selected company contract will be the monday account active contract (defined on Selected_Company_Contract__c formula)
                        priorContractsToUpdate.add(new Contract(Id=createdContsMap.get(obj.Id).Id,Prior_Contract__c=(Id)obj.get('Selected_Company_Contract__c')));
                    }
                }
            }

            if (!quoteToUpdate.isEmpty()) {
                update quoteToUpdate;
            }
            if (!oppsToUpdate.isEmpty()) {
                System.enqueueJob(new updateOppQueueable(oppsToUpdate));
            }
            if (!contractToDeactivate.isEmpty()) {
                System.enqueueJob(new updateContractToInactiveQueueable(contractToDeactivate));
            }
            if (!masterMondayAccountToUpdate.isEmpty()) {
                System.enqueueJob(new updateAccountQueueable(masterMondayAccountToUpdate));
            }
            if (!priorContractsToUpdate.isEmpty()) {
                System.enqueueJob(new updatePriorContract(priorContractsToUpdate));
            }
        }
        if (objType=='Subscription') {
            for (SObject obj : objects) { 
                if (obj.get('Manual_Trigger__c')=='Create Active Contract') {
                    subsToUpdate.add(new Subscription__c(Id=obj.id,Contract__c=createdContsMap.get(obj.Id).Id,Manual_Trigger__c=''));
                    contractToDeactivate.add(new Contract(Id=(Id)obj.get('Contract__c'),Status__c='Deactivated'));
                }
                else {
                    subsToUpdate.add(new Subscription__c(Id=obj.id,Contract__c=createdContsMap.get(obj.Id).Id));
                    createdContForSubOrder.put((string)obj.get('Order_Number__c'),createdContsMap.get(obj.Id).Id);
                }
                masterMondayAccountToUpdate.add(new Account(Id=(Id)obj.get('Monday_Account__c'),Active_Contract__c = createdContsMap.get(obj.Id).Id));
            }

            if (!subsToUpdate.isEmpty()) {
                update subsToUpdate;
            }
            if (!masterMondayAccountToUpdate.isEmpty()) {
                System.enqueueJob(new updateAccountQueueable(masterMondayAccountToUpdate));
            }
            if (!contractToDeactivate.isEmpty()) {
                System.enqueueJob(new updateContractToInactiveQueueable(contractToDeactivate));
            }

        }
     }catch(Exception e){
        Utilities.sendDebugEmail('Error in ContractEventCreateNewContract ',e,e.getMessage());  
     }
}
    public static Contract createContract(Contract_Event__c conEvent){
        //Contract define fields are added on ConEventMetadata
            String conName;
            conName=conEvent.Company_Name__c + ' - ' + conEvent.Subscription_Tier__c+ ' - '+conEvent.Quantity__c;
            Contract contract = new Contract(
            Name = conName.left(80),
        	AccountId = conEvent.Company_Id__c,
            Status__c='Active',
            ContractTerm = conEvent.Duration__c.intValue()>0?conEvent.Duration__c.intValue():1,
            CurrencyIsoCode = conEvent.CurrencyIsoCode,
            StartDate = conEvent.Start_Date__c,
            EndDate = conEvent.End_Date__c,
            Source__c=conEvent.Source__c,
            Tier__c = conEvent.Subscription_Tier__c,
            List_Price__c = conEvent.List_Unit_Price__c,
            Unit_Price__c = conEvent.Net_Unit_Price__c,
            Discount__c = conEvent.Discount__c,
            Deal_Structure__c=conEvent.Deal_Structure__c,
            Rollout_Plan__c=conEvent.Rollout_Plan__c,
            Period__c=conEvent.Period__c,
            //Remove after fully go live (We keep this for non pilot users)
            Seats__c =conEvent.Quantity__c,
            Auto_Renewal__c=conEvent.Auto_Renewal__c
        );
        return contract;
        }
    
    //When a new contract event is arrived and arr is changed - find all related open opps to update new ARR
    public static void updateContractArrChangeToOpenOps(List<Contract> contracts, Map<Id,Contract> oldConts){
        try{
        List<Contract> relevantConts = new List<Contract>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Contract con : contracts) {
            if (con.Contract_ARR__c != oldConts.get(con.Id).Contract_ARR__c) {
                relevantConts.add(con);
            }
        }
        Map<Id, Contract> conMap = new Map<Id, Contract>(relevantConts);
        List<Opportunity> relevantOppList = new List<Opportunity>([select id,Selected_Company_Contract__c from opportunity where IsClosed=false and Selected_Company_Contract__c in:conMap.keySet()]);

        for (Opportunity opp : relevantOppList) {
            opp.Related_Contract_ARR__c = conMap.get(opp.Selected_Company_Contract__c).Contract_ARR__c;
            oppsToUpdate.add(opp);
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }catch(Exception e){
        Utilities.sendDebugEmail('Error in ContractEventCreateNewContract.updateContractArrChangeToOpenOps ',e,e.getMessage());  
    }
}

    public static Contract_Product__c createContractProduct(Contract_Event__c conEvent, Contract Con){
        Contract_Product__c conProd = new Contract_Product__c(
            Product__c=conEvent.Product__c, 
            Contract__c=con.Id);
        return conProd;
    }

    private class updateOppQueueable implements System.Queueable {
        private List<Opportunity> oppToUpdateList; 
        public updateOppQueueable(List<Opportunity> oppToUpdateList) {
            this.oppToUpdateList = oppToUpdateList;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(oppToUpdateList);
        }
    }
    private class updateAccountQueueable implements System.Queueable {
        private List<Account> accToUpdateList; 
        public updateAccountQueueable(List<Account> accToUpdateList) {
            this.accToUpdateList = accToUpdateList;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(accToUpdateList);
        }
    }

    private class updateContractToInactiveQueueable implements System.Queueable {
        private List<Contract> contractToUpdateList; 
        public updateContractToInactiveQueueable(List<Contract> contractToUpdateList) {
            this.contractToUpdateList = contractToUpdateList;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(contractToUpdateList);
        }
    }

    private class updatePriorContract implements System.Queueable {
        private List<Contract> contractToUpdateList; 
        public updatePriorContract(List<Contract> contractToUpdateList) {
            this.contractToUpdateList = contractToUpdateList;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(contractToUpdateList);
        }
    }
}