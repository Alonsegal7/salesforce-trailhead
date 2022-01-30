public without sharing class Opportunity_RenewalCreation {

    //Check if there is already a CS Opportunity related to Contract - if so, the component will not show the ability to create a new Opp
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> checkOpenRenewalOpps(Id recordId){
        system.debug('### recordId: ' + recordId);
        Contract cont = [SELECT Id, Name, AccountId FROM Contract WHERE Id =: recordId LIMIT 1];
        Account company = [SELECT Id, Name FROM ACCOUNT WHERE Id =: cont.AccountId LIMIT 1];
        List<Opportunity> renewalOpps = [
            SELECT Id, Name, StageName, Selected_Company_Contract__c 
            FROM Opportunity 
            WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Selected_Company_Contract__c =: recordId AND (RecordType.DeveloperName = 'CS_Opportunity' OR Type LIKE '%Renewal%')];

        // List<Opportunity> renewalOpps = [
        //     SELECT Id, Name, StageName, Selected_Company_Contract__c 
        //     FROM Opportunity 
        //     WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Company__c =: company.Id AND (RecordType.DeveloperName = 'CS_Opportunity' OR Type LIKE '%Renewal%')];
        system.debug('### renewalOpps: ' + renewalOpps);
        return renewalOpps;
    }

    //Check if there is already an open Expansion Opportunity related to Contract - if so, the component will display a warning message
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> checkOpenExpansionOpps(Id recordId){
        List<Opportunity> expansionOpps = [
            SELECT Id, Name, StageName, Selected_Company_Contract__c 
            FROM Opportunity 
            WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Type = 'Expansion' AND Selected_Company_Contract__c =: recordId];
        system.debug('### expansionOpps: ' + expansionOpps);
        return expansionOpps;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> checkRelatedMAs(Id recordId){
        List<Account> mondayAcc = [SELECT Id, Name, Active_Contract__c, Company__c FROM Account WHERE Active_Contract__c =: recordId AND ARR__c != null ORDER BY ARR__c DESC LIMIT 1];
        
        return mondayAcc;
    }
    
    /*  Create a new CS Opporutnity (Renewal) and maps the relevant data we need.
        The Opportunity gets data from:
        - Contract, Contract Event --> QLI --> Quote OR --> Subscriptions, Monday Account
    */
    @AuraEnabled
    public static Opportunity insertOpportunity(Id recordId){
        Id csOpportunityRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CS_Opportunity').getRecordTypeId();
        System.debug('### csOpportunityRT: ' + csOpportunityRT);
        Id salesOpportunityRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        System.debug('### salesOpportunityRT: ' + salesOpportunityRT);
        Id currentUserProfile = userinfo.getProfileId();
        Id getRelevantRT;
        Id qli;
        Id subs;
        Id billingEntity;

        String pricingVersion = '';
        String paymentTerms = '';
        String paymentMethod = '';

        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id =: currentUserProfile];
        System.debug('### recordId: ' + recordId);
        System.debug('### userProfile: ' + userProfile);
        System.debug('### contractQuery: ' + [SELECT Id FROM Contract WHERE Id =: recordId LIMIT 1]);

        Contract cont = [
            SELECT Id, Name, EndDate, Contract_ARR__c, Primary_Renewal_Owner__c, Renewal_Manager__c, Renewal_Opp_Created_from_Contract__c, Weighted_Average_Net_Per_Unit__c, Contract_Seats__c, Tier__c, Period__c, CurrencyIsoCode
            FROM Contract 
            WHERE Id =: recordId LIMIT 1];
        System.debug('### cont: ' + cont);
        
        for(Contract_Event__c evt : [SELECT Id, Name, Contract__c,Payment_Terms__c, Quote_Line_Item__c, Subscription__c, Billing_Entity__c FROM Contract_Event__c WHERE Contract__c =: recordId ORDER BY CreatedDate DESC LIMIT 1]){
            billingEntity = evt.Billing_Entity__c;
            paymentTerms=evt.Payment_Terms__c;
            System.debug('### evt.Billing_Entity__c: ' + evt.Billing_Entity__c);
            System.debug('### billingEntity: ' + billingEntity);
            if(evt.Quote_Line_Item__c != null){
                qli = evt.Quote_Line_Item__c;
            }

            else if(evt.Subscription__c != null){
                subs = evt.Subscription__c;
            }
        }

        if(qli != null){
            QuoteLineItem getQuoteInfo = [SELECT Id, QuoteId, Quote.Pricing_Version__c, Quote.Payment_Terms__c FROM QuoteLineItem WHERE Id =: qli];
            if(getQuoteInfo != null){
                paymentMethod = 'Wire';
                //paymentTerms = getQuoteInfo.Quote.Payment_Terms__c;
                pricingVersion = String.valueof(getQuoteInfo.Quote.Pricing_Version__c);
            }
        }

        if(subs != null){
            Subscription__c getSubsInfo = [SELECT Id, Pricing_Version__c, Payment_Method__c FROM Subscription__c WHERE Id =: subs];
            if(getSubsInfo != null){
                paymentMethod = getSubsInfo.Payment_Method__c;
                //paymentTerms = '';
                pricingVersion = String.valueof(Integer.valueOf(getSubsInfo.Pricing_Version__c));
            }
        }

        List<Account> mondayAcc  = [SELECT Id, Name, Active_Contract__c, Company__c, Company__r.Name, Pricing_Version__c, Latest_Billing_Entity__c FROM Account WHERE Active_Contract__c =: recordId AND ARR__c != null ORDER BY ARR__c DESC LIMIT 1];
        System.debug('### mondayAcc: ' + mondayAcc);
		System.debug('### billingEntity_v1 ' + billingEntity);
        if(billingEntity == null && qli == null && subs == null && !mondayAcc.isEmpty()){
            billingEntity = mondayAcc[0].Latest_Billing_Entity__c;
        }

        if(userProfile.Name == 'Renewals'){
            System.debug('### userProfile.Name: ' + userProfile.Name);
            getRelevantRT = csOpportunityRT;
        }

        else if(userProfile.Name != 'Partner Community Custom' && userProfile.Name != 'GSI Community User' && userProfile.Name != 'Channel Managers'){
            System.debug('### userProfile.Name_v1: ' + userProfile.Name);
            getRelevantRT = salesOpportunityRT;
        }
        
        System.debug('### getRelevantRT: ' + getRelevantRT);

        system.debug('### pricingVersion: ' + pricingVersion);
        system.debug('### cont_v1: ' + cont);
        try{
            Opportunity newOpp = new Opportunity(
                Name = mondayAcc[0].Company__r.Name + ' - ' + cont.Period__c + ' - ' + cont.Contract_Seats__c + ' - ' + cont.Tier__c + ' - ' + 'Flat Renewal',
                Company__c = mondayAcc[0].Company__c,
                AccountId = mondayAcc[0].Id,
                Type = 'Flat Renewal',
                CloseDate = cont.EndDate,
                Selected_Company_Contract__c = cont.Id,
                Original_Contract_ARR__c = cont.Contract_ARR__c,
                OwnerId = cont.Primary_Renewal_Owner__c,
                Renewal_Manager__c = cont.Renewal_Manager__c,
                RecordTypeId = getRelevantRT,
                StageName = 'Qualified',
                Probability = 20,
                Expected_Seat_Price__c = cont.Weighted_Average_Net_Per_Unit__c,
                Expected_Plan_Seats__c = cont.Contract_Seats__c,
                Expected_Plan_Period__c = cont.Period__c,
                CurrencyIsoCode = cont.CurrencyIsoCode,
                Expected_Plan_Tier__c = cont.Tier__c,
                Pricing_Version__c = pricingVersion,
                Payment_Method__c = paymentMethod,
                Payment_Terms__c = paymentTerms,
                Billing_Entity__c = billingEntity,
                Manual_Renewal_Creation__c = true
            );
            system.debug('### newOpp: ' + newOpp);
            insert newOpp;
            cont.Renewal_Opp_Created_from_Contract__c = true;
            update cont;
            system.debug('### newOpp_v1: ' + newOpp);
            return newOpp;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static void updateRelatedRecordsFields(Map<Id, Contract> oldContracts, Map<Id, Contract> newContracts){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Account> accsToUpdate = new List<Account>();
        Map<Id, Contract> relevantContMap = new Map<Id, Contract>();
        Boolean NeedToUpdateOpp=false;

        for (Contract singleCon : newContracts.values()) {
            if((newContracts.get(singleCon.Id).Contract_ARR__c != oldContracts.get(singleCon.Id).Contract_ARR__c) || (singleCon.Renewal_Manager__c != oldContracts.get(singleCon.Id).Renewal_Manager__c || singleCon.Primary_Renewal_Owner__c != oldContracts.get(singleCon.Id).Primary_Renewal_Owner__c)){
                relevantContMap.put(singleCon.Id, singleCon);
                if ((newContracts.get(singleCon.Id).Contract_ARR__c != oldContracts.get(singleCon.Id).Contract_ARR__c)) {
                    NeedToUpdateOpp=true;
                }
            }
        }
        if (!relevantContMap.isEmpty()) {
            List<Account> realtedMA = [SELECT Id, Renewal_Manager__c, Renewal_Owner__c, Active_Contract__c FROM Account WHERE Active_Contract__c IN: relevantContMap.keySet() AND ARR__c != null ORDER BY ARR__c DESC];  
            for (Account acc : realtedMA) {
                acc.Renewal_Manager__c = relevantContMap.get(acc.Active_Contract__c).Renewal_Manager__c;
                acc.Renewal_Owner__c  = relevantContMap.get(acc.Active_Contract__c).Primary_Renewal_Owner__c;
                accsToUpdate.add(acc);
            }
        }   
         if (NeedToUpdateOpp) {
             List<Opportunity> oppList = [SELECT Id, Selected_Company_Contract__c, Original_Contract_ARR__c FROM Opportunity WHERE Selected_Company_Contract__c IN: relevantContMap.keySet() AND RecordType.DeveloperName = 'CS_Opportunity' AND StageName != 'Closed Won' AND StageName != 'Closed Lost'];
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