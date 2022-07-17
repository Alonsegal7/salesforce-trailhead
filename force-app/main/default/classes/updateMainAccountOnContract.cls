public with sharing class updateMainAccountOnContract {
    public static void updateMainAccountOnContract(List<Account> newAccounts, Map<Id,Account> oldAccounts){
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Set<Id> contractIds = new Set<Id>(); //Set of unique contract Ids to run on
        List<Contract> contractsToUpdate = new List<Contract>(); //List of all the relevant contracts to update the 'main monday account' field on
        for (Account ma : newAccounts) { //for each account that was triggerd, check if relevant: is monday account and Account ARR changed OR Current Contract changed and
            if (ma.RecordTypeId == MARecordTypeId) { //RT is monday account
                if (ma.Active_Contract__c != null && 
                (ma.ARR__c != oldAccounts.get(ma.Id).ARR__c || ma.Active_Contract__c != oldAccounts.get(ma.Id).Active_Contract__c)) { 
                    contractIds.add(ma.Active_Contract__c); //add the contract id to the set of contracts
                }
            }
        }
        List<account> allRelatedMAs = [SELECT Id, ARR__c, Active_Contract__c FROM Account WHERE Active_Contract__c IN: contractIds]; //get all monday accounts that their Active_Contract__c (contract id) is in the contracts set
        Map<Id, List<Account>> contractsMap = new Map<Id, List<Account>> (); //empty map with columns: contract id, matching monday accounts (list)
        for (Account relatedMA : allRelatedMAs) { //put monday account values in the contractsMap
            if (contractsMap.containsKey(relatedMA.Active_Contract__c)) { //if key exist in map
                contractsMap.get(relatedMA.Active_Contract__c).add(relatedMA); //add related MA to it's row
            }
            else { //key does not exist
                contractsMap.put(relatedMA.Active_Contract__c,new List<Account>{relatedMA}); //create a new row in map
            }
        }
        for (Id contractId : contractsMap.keySet()) {
            List<Account> relatedMasForCurrentContract = contractsMap.get(contractId);
            Id maWithhighestARR;
            Integer maxARR = 0;
            for (Account mondayAccount : relatedMasForCurrentContract) {
                if (mondayAccount.ARR__c > maxARR){
                    maWithhighestARR = mondayAccount.Id;
                }
            }
            contractsToUpdate.add(new Contract (Id=contractId, Main_Monday_Account_Related__c = maWithhighestARR));
        }
        update contractsToUpdate;   
    }
}