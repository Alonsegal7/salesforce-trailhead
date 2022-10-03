public without sharing class Opportunity_RenewalCreation {

    //Check if there is already a CS Opportunity related to Contract - if so, the component will not show the ability to create a new Opp
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> checkOpenRenewalOpps(Id recordId){
        Contract cont = [SELECT Id, Name, AccountId FROM Contract WHERE Id =: recordId LIMIT 1];
        Account company = [SELECT Id, Name FROM ACCOUNT WHERE Id =: cont.AccountId LIMIT 1];
        List<Opportunity> renewalOpps = [
            SELECT Id, Name, StageName, Selected_Company_Contract__c 
            FROM Opportunity 
            WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Selected_Company_Contract__c =: recordId AND (RecordType.DeveloperName = 'CS_Opportunity' OR Type LIKE '%Renewal%')];
        return renewalOpps;
    }

    //Check if there is already an open Expansion Opportunity related to Contract - if so, the component will display a warning message
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> checkOpenExpansionOpps(Id recordId){
        List<Opportunity> expansionOpps = [
            SELECT Id, Name, StageName, Selected_Company_Contract__c 
            FROM Opportunity 
            WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Type = 'Expansion' AND Selected_Company_Contract__c=:recordId] ;
        return expansionOpps;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> checkRelatedMAs(Id recordId){
        List<Account> mondayAcc = [SELECT Id, Name, Active_Contract__c, Company__c FROM Account WHERE Active_Contract__c =: recordId AND ARR__c != null ORDER BY ARR__c DESC LIMIT 1];
        return mondayAcc;
    }

    @AuraEnabled(cacheable=true)
    public static Id checkCurrentContract(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if (sObjName == 'Account'){
            return [SELECT Active_Contract__c  FROM Account WHERE Id =: recordId LIMIT 1]?.Active_Contract__c;
    
         }
        else{
             return recordId;

        }
    }
    
    /*
    Create new Renewal Opportunities, can be used:
    1. For manual renewal opportunity creation from the contract LWC
    2. For automatic renewal opportunity creation in bulk (x months before the contract end date) 
    */
    @AuraEnabled
    public static List<Opportunity> createRenewalOpportunities(List<Id> renewalContractIds,String Source){
        Id currentUserProfile = userinfo.getProfileId();
        Id qli, subs, billingEntity;
        String pricingVersion, paymentTerms, paymentMethod = '';
        System.debug(Source);
        List<Contract> relevantContracts =  new List<Contract>([
            SELECT Id, Name, EndDate,Renewal_Manager__c, Contract_ARR__c, Primary_Renewal_Owner__c, Renewal_Opp_Created_from_Contract__c, Weighted_Average_Net_Per_Unit__c, Contract_Seats__c, Tier__c, Period__c, CurrencyIsoCode, Renewal_Opportunity_Creation_Status__c, Last_Event_Payment_Method__c, Last_SO_Event_Payment_Terms__c,
            (SELECT Id, Billing_Entity__c FROM Contract_Events__r ORDER BY CreatedDate DESC LIMIT 1),
            (SELECT Id, Name, Active_Contract__c,Owner_s_Profile__c,Company__c,of_open_opps__c, Company__r.Name, Pricing_Version__c, Latest_Billing_Entity__c FROM Accounts__r WHERE ARR__c != null ORDER BY ARR__c DESC LIMIT 1)
            FROM Contract 
            WHERE Id IN: renewalContractIds 
            LIMIT 200]);
        List<Opportunity> renewalOppsToCreate = new List<Opportunity>(); 
        if(relevantContracts.isEmpty()) return renewalOppsToCreate;
        Map<Id,Contract> contractsWithIds = new Map<Id,Contract>();
        for (Contract c : relevantContracts) {
            Account primaryMa= c.accounts__r[0];
            //if (primaryMa.of_open_opps__c == 0){ //maybe we would add here more conditions in cases that the num of open opps bigger then 1 
                Id getRelevantRT = (primaryMa.Owner_s_Profile__c == 'Partner Community Custom' || primaryMa.Owner_s_Profile__c == 'Channel Managers') ? Utilities.partnerOppRecordTypeId :Utilities.internalOppRecordTypeId;   
                renewalOppsToCreate.add(new Opportunity(
                    Name = primaryMa.Company__r.Name + ' - ' + c.Period__c + ' - ' + c.contract_Seats__c + ' - ' + c.Tier__c + ' - ' + 'Flat Renewal',
                    Company__c = primaryMa.Company__c,
                    AccountId = primaryMa.Id,
                    Type = 'Flat Renewal',
                    CloseDate = c.EndDate,
                    Selected_Company_Contract__c = c.Id,
                    Original_Contract_ARR__c = c.Contract_ARR__c,
                    OwnerId = c.Primary_Renewal_Owner__c,
                    RecordTypeId = getRelevantRT,
                    StageName = 'Qualified',
                    Probability = 20,
                    Expected_Seat_Price__c = c.Weighted_Average_Net_Per_Unit__c,
                    Expected_Plan_Seats__c = c.Contract_Seats__c,
                    Expected_Plan_Period__c = c.Period__c,
                    CurrencyIsoCode = c.CurrencyIsoCode,
                    Expected_Plan_Tier__c = c.Tier__c,
                    Pricing_Version__c = pricingVersion,
                    Payment_Method__c = c.Last_Event_Payment_Method__c,
                    Payment_Terms__c = c.Last_SO_Event_Payment_Terms__c,
                    Billing_Entity__c = c.Contract_Events__r[0].Billing_Entity__c,
                    Renewal_Manager__c = c.Renewal_Manager__c,
                    Renewal_Source_Creation__c = Source
                ));
                c.Renewal_Opportunity_Creation_Status__c = 'Initiated';
                c.Renewal_Opp_Created_from_Contract__c = true;
                contractsWithIds.put(c.Id,c); 
            //}          
        }
        //mark the renewal creation status for all the relevant contract as 'Initiated'
        try {
            update contractsWithIds.values();
        } catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
        }

        //create the renewal opportunities
        try {
            Database.insert(renewalOppsToCreate, false);
        } catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return renewalOppsToCreate;
    }
    /*
    Used to mark the renewal status of contracts as Completed after a renewal opportunity is successfully created, done in queuable because the contract is locked when the opportunity is created
    */
    public static void updateRenewalStatus(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
        Set<Id> relevantContractIds = new Set<Id>();
        Map<Id,Opportunity> renewalOppsToContractsMap = new Map<Id,Opportunity>();
        if (oldOpps == null) {
            for (Opportunity opp : newOpps) {
                if (opp.Selected_Company_Contract__c != null) {
                    renewalOppsToContractsMap.put(opp.Selected_Company_Contract__c, opp);
                }
            }
            if (renewalOppsToContractsMap != null) {
                List<Contract> contractsToUpdate = new List<Contract>([SELECT Id, Renewal_Opportunity_Creation_Status__c FROM Contract WHERE Id IN: renewalOppsToContractsMap.keySet()]);
                for (Contract c : contractsToUpdate) {
                    c.Renewal_Opportunity__c = renewalOppsToContractsMap.get(c.Id).Id;
                    if (c.Renewal_Opportunity_Creation_Status__c == 'Initiated') c.Renewal_Opportunity_Creation_Status__c = 'Completed';
                }
                try {
                    Database.update(contractsToUpdate, false);
                } catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                }
            }
        }
    }
    
    /*
    Used to update records related to a contract upon certain changes on the contract.
    Contract changes triggering the logic: Contract ARR, Renewal Manager, Primary Renewal Owner
    Related objects updated by this logic: Accounts (MAs), Opportunities   
    */
    public static void updateRelatedRecordsFields(List <Contract> newContracts, Map<Id, Contract> oldContracts){
        Set<Id> accountsIdsToChangePRO = new Set<Id>();
        Set<Id> accountsIdsToChangeRM = new Set<Id>();
        Set<Id> oppsIdsToChangeContractARR = new Set<Id>();
        Map<Id,Contract> relevantContMap = new map <Id,Contract>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Account> accsToUpdate = new List<Account>();

        for (Contract con : newContracts) {
            if(((con.Main_Monday_Account_Related__c != null) && (con.Renewal_Manager__c != oldContracts.get(con.Id).Renewal_Manager__c  || con.Primary_Renewal_Owner__c != oldContracts.get(con.Id).Primary_Renewal_Owner__c)) || con.Contract_ARR__c != oldContracts.get(con.Id).Contract_ARR__c){
                relevantContMap.put(con.Id, con);
            }
            if ((con.Renewal_Manager__c != oldContracts.get(con.Id).Renewal_Manager__c && con.Main_Monday_Account_Related__c != null)) {
                accountsIdsToChangeRM.add(con.Main_Monday_Account_Related__c);
            }
            if ((con.Primary_Renewal_Owner__c != oldContracts.get(con.Id).Primary_Renewal_Owner__c  && con.Main_Monday_Account_Related__c != null)) {
                accountsIdsToChangePRO.add(con.Main_Monday_Account_Related__c);
            }
            if ((con.Contract_ARR__c != oldContracts.get(con.Id).Contract_ARR__c)) {
                oppsIdsToChangeContractARR.add(con.Id);
            }
        }
        if (relevantContMap.isEmpty()) return;

        if(!accountsIdsToChangeRM.isEmpty()){
            for (account acc: [SELECT id,Renewal_Manager__c,Active_Contract__c FROM account WHERE id in: accountsIdsToChangeRM]){
                acc.Renewal_Manager__c = relevantContMap.get(acc.Active_Contract__c).Renewal_Manager__c;
                accsToUpdate.add(acc);
            }

        }
        if(!accountsIdsToChangePRO.isEmpty()){
            for (account acc: [SELECT id,Renewal_Owner__c,Active_Contract__c FROM account WHERE id in: accountsIdsToChangePRO]){
                acc.Renewal_Owner__c = relevantContMap.get(acc.Active_Contract__c).Primary_Renewal_Owner__c;
                accsToUpdate.add(acc);
            }

        }
        if(!oppsIdsToChangeContractARR.isEmpty()){
            List<Opportunity> oppList = [SELECT Id, Selected_Company_Contract__c, Original_Contract_ARR__c FROM Opportunity WHERE Selected_Company_Contract__c IN: oppsIdsToChangeContractARR AND RecordType.DeveloperName = 'CS_Opportunity' AND StageName != 'Closed Won' AND StageName != 'Closed Lost'];
            if (!oppList.isEmpty()) {
                for (Opportunity oppty : oppList) {
                    oppty.Original_Contract_ARR__c = relevantContMap.get(oppty.Selected_Company_Contract__c).Contract_ARR__c;
                    oppsToUpdate.add(oppty);
                }
            }
        }
        if(!oppsToUpdate.isEmpty()){
            Database.update(oppsToUpdate);
        }

        if(!accsToUpdate.isEmpty()){
            Database.update(accsToUpdate);
        }
    }

    /*
    Trigger: Account created w/ Active Contract or Active contract changed on existing account
    Action: Changes the renewal owner on the contract to be the renewal owner on the account
    */
    
    public static void getProFromActiveContract(Map<Id, Account> oldAccts, List<Account> newAccts){
        try{
        List<Account> relevanAccts = new List<Account>();
        Map<Id, Contract> relevantContMap = new Map<Id, Contract>();
        Set<Id> relevantContId = new Set<Id>();
        //Get account that changed thier active contract
        if (oldAccts==null) {//Insert
            for (Account acc : newAccts) {
                if (acc.Active_Contract__c!=null) {
                    relevantContId.add(acc.Active_Contract__c);
                    relevanAccts.add(acc);
                }
            }
        }
        else {//Update
            for (Account acc : newAccts) {
                if (acc.Active_Contract__c!=null && acc.Active_Contract__c!=oldAccts.get(acc.Id).Active_Contract__c) {
                    relevantContId.add(acc.Active_Contract__c);
                    relevanAccts.add(acc);
                }
            }
        }
            if (!relevantContId.isEmpty()) {
                for (Contract con : [select Id,Primary_Renewal_Owner__c from contract where id in:relevantContId]) {
                    relevantContMap.put(con.Id,con);
                }
            }
            if (!relevanAccts.isEmpty()) {
                for (Account acc : relevanAccts) {
                    acc.Renewal_Owner__c=relevantContMap.get(acc.active_contract__c).Primary_Renewal_Owner__c;
                }   
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in getProFromActiveContract ',e,e.getMessage());   
        }
    }
}