public with sharing class ContractValidationCopmController {
    @AuraEnabled(cacheable=true)
    public static Contract getBBContract(String oppId){
        try{
        list<Id> oppIds=new list<Id>{Id.Valueof(oppId)};
        Contract currentCon=ExistingContractValidation.getContract(oppIds)[0];
        system.debug('Raz Ben Ron currentCon from Controller, '+currentCon);
        return currentCon;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static list<Contract> sendContractToBB(Contract conToSend){
        try{
            list<Contract> contracts=new list<Contract>{conToSend};
            contracts=SendContractToBB.sendContract(contracts);
            return contracts;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Opportunity findExisingContracts(String oppId){
        try{
            Opportunity oppInfo= [select id,Account.primary_pulse_account_id__c,AccountId,StageName,Account.Active_Contract__c
                                    from Opportunity 
                                    where id=:oppId][0];
            return oppInfo;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Contract createContract(Contract contToCreate){
        try{
            Account acc=[select id,Company__c from Account where primary_pulse_account_id__c=:contToCreate.Pulse_Account_Id__c][0];
            system.debug('Raz Ben Ron contract to create from controller: '+contToCreate);
            if(acc.Company__c!=null)
                contToCreate.AccountId=acc.Company__c;
            insert contToCreate;
            acc.Active_Contract__c=contToCreate.Id;
            system.debug('acc: '+acc);
            update acc;
            return contToCreate;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}