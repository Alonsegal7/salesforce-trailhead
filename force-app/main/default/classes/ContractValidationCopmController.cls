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
            Opportunity oppInfo= [select id,Account.primary_pulse_account_id__c,AccountId,StageName,Account.Active_Contract__c,Account.Pricing_Version__c,
                                    Pricing_Version__c,CurrencyIsoCode,Account.Currency__c
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

    @AuraEnabled
    public static Account findMondayAccount(String bbId, String maId){
        try{
            list<Account> acc=[select id,Plan_Name__c,Name,Owner.Name
                                from Account 
                                where primary_pulse_account_id__c=:bbId and Id!=:maId];
            system.debug('Raz Ben Ron find ma by BB id: '+bbId);
            if(!acc.isempty()){//found MA with same BB id
                system.debug('Raz Ben Ron find ma by acc[0]: '+acc[0]);
                return acc[0];
            }else {
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id handleSaveAccount(String oppId,String existingMAId ,String foundMAId, String BBId, Boolean connectAccount){
        try{
            system.debug('Raz Ben Ron Acc save oppId: '+oppId);
            system.debug('Raz Ben Ron Acc save foundMAId: '+foundMAId);
            system.debug('Raz Ben Ron Acc save BBId: '+BBId);
            system.debug('Raz Ben Ron Acc save connectAccount: '+connectAccount);
            system.debug('Raz Ben Ron Acc Save existingMAId: '+existingMAId);
            if(connectAccount){
                system.debug('in update account on opp: '+connectAccount);
                if(foundMAId!=null)
                    update new Opportunity(Id=oppId,AccountId=foundMAId);
                    return foundMAId;
            }else{
                if(existingMAId!=null)
                    update new Account(Id=existingMAId,primary_pulse_account_id__c=BBId);
                    return existingMAId;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}