public with sharing class Opportunity_RenewalCreation {
    //Check if there is already a CS Opportunity related to Contract - if so, the component will not show the ability to create a new Opp
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> checkRelatedOpps(Id recordId){
        List<Opportunity> relatedOpp = [
            SELECT Id, Name, StageName, Selected_Company_Contract__c 
            FROM Opportunity 
            WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND RecordType.DeveloperName = 'CS_Opportunity' AND Selected_Company_Contract__c =: recordId];
        
        return relatedOpp;
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
        Id salesOpportunityRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        Id currentUserProfile = userinfo.getProfileId();
        Id getRelevantRT;
        Id qli;
        Id subs;
        Id billingEntity;

        String pricingVersion = '';
        String paymentTerms = '';
        String paymentMethod = '';

        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id =: currentUserProfile];
        System.debug('### userProfile: ' + userProfile);

        Contract cont = [
            SELECT Id, Name, EndDate, Contract_ARR__c, Primary_Renewal_Owner__c, Renewal_Manager__c, Weighted_Average_Net_Per_Unit__c, Contract_Seats__c, Tier__c, Period__c 
            FROM Contract 
            WHERE Id =: recordId LIMIT 1];
        System.debug('### cont: ' + cont);
        
        for(Contract_Event__c evt : [SELECT Id, Name, Contract__c, Quote_Line_Item__c, Subscription__c, Billing_Entity__c FROM Contract_Event__c WHERE Contract__c =: recordId ORDER BY CreatedDate DESC LIMIT 1]){
            billingEntity = evt.Billing_Entity__c;
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
                paymentTerms = getQuoteInfo.Quote.Payment_Terms__c;
                pricingVersion = String.valueof(getQuoteInfo.Quote.Pricing_Version__c);
            }
        }

        if(subs != null){
            Subscription__c getSubsInfo = [SELECT Id, Pricing_Version__c, Payment_Method__c FROM Subscription__c WHERE Id =: subs];
            if(getSubsInfo != null){
                paymentMethod = getSubsInfo.Payment_Method__c;
                paymentTerms = '';
                pricingVersion = String.valueof(Integer.valueOf(getSubsInfo.Pricing_Version__c));
            }
        }

        List<Account> mondayAcc  = [SELECT Id, Name, Active_Contract__c, Company__c, Company__r.Name FROM Account WHERE Active_Contract__c =: recordId AND ARR__c != null ORDER BY ARR__c DESC LIMIT 1];
        System.debug('### mondayAcc: ' + mondayAcc);

        if(userProfile.Name == 'Renewals'){
            getRelevantRT = csOpportunityRT;
        }

        else if(userProfile.Name != 'Partner Community Custom' && userProfile.Name != 'GSI Community User' && userProfile.Name != 'Channel Managers'){
            getRelevantRT = salesOpportunityRT;
        }

        system.debug('### pricingVersion: ' + pricingVersion);
        system.debug('### mondayAcc[0]: ' + mondayAcc[0]);
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
                Expected_Plan_Period__c = cont.Tier__c,
                Expected_Plan_Tier__c = cont.Period__c,
                Pricing_Version__c = pricingVersion,
                Payment_Method__c = paymentMethod,
                Payment_Terms__c = paymentTerms,
                Billing_Entity__c = billingEntity
            );
            system.debug('### newOpp: ' + newOpp);
            insert newOpp;
            system.debug('### newOpp_v1: ' + newOpp);
            return newOpp;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static void updateRelatedRenewalOpportunities(Map<Id, Contract> oldContracts, Map<Id, Contract> newContracts){
        List<Opportunity> opp = [SELECT Id, Name, StageName, Selected_Company_Contract__c, ContractId FROM Opportunity WHERE Selected_Company_Contract__c IN: newContracts.keySet() AND RecordType.DeveloperName = 'CS_Opportunity' AND StageName != 'Closed Won' AND StageName != 'Closed Lost' LIMIT 1];
        System.debug('### opp: ' + opp);

        for(Contract contr : [SELECT Id, Renewal_Manager__c, Primary_Renewal_Owner__c FROM Contract WHERE Id IN: newContracts.keySet()]){
            if(contr.Renewal_Manager__c != oldContracts.get(contr.Id).Renewal_Manager__c || contr.Primary_Renewal_Owner__c != oldContracts.get(contr.Id).Primary_Renewal_Owner__c){
                
            }
            System.debug('### Primary_Renewal_Owner__c: ' + newContracts.get(contr.Id).Primary_Renewal_Owner__c);
            System.debug('### old Primary_Renewal_Owner__c: ' + oldContracts.get(contr.Id).Primary_Renewal_Owner__c);
            if(newContracts.get(contr.Id).Primary_Renewal_Owner__c != oldContracts.get(contr.Id).Primary_Renewal_Owner__c){
                if(!opp.isEmpty()){
                    System.debug('### in error: ');
                    newContracts.get(contr.Id).addError('You cannot change the Primary Renewal Owner due to an open Renewal Opportunity: ' + opp[0].Name);
                    return;
                }
            }
        }
    }

    public static void updateRelatedRecordsFields(Map<Id, Contract> oldContracts, Map<Id, Contract> newContracts){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Opportunity> opp = [SELECT Id, Selected_Company_Contract__c, Original_Contract_ARR__c FROM Opportunity WHERE Selected_Company_Contract__c IN: newContracts.keySet() AND RecordType.DeveloperName = 'CS_Opportunity' AND StageName != 'Closed Won' AND StageName != 'Closed Lost' LIMIT 1];
        System.debug('### opp: ' + opp);
        List<Account> realtedMA = [SELECT Id, Renewal_Manager__c, Renewal_Owner__c, Active_Contract__c FROM Account WHERE Active_Contract__c IN: newContracts.keySet()];
        System.debug('### realtedMA: ' + realtedMA);

        for(Contract contr : [SELECT Id, Renewal_Manager__c, Primary_Renewal_Owner__c, Contract_ARR__c FROM Contract WHERE Id IN: newContracts.keySet()]){
            if(contr.Renewal_Manager__c != oldContracts.get(contr.Id).Renewal_Manager__c || contr.Primary_Renewal_Owner__c != oldContracts.get(contr.Id).Primary_Renewal_Owner__c && !realtedMA.isEmpty()){
                for(Account acc : realtedMA){
                    if(acc.Active_Contract__c == contr.Id){
                        acc.Renewal_Manager__c = contr.Renewal_Manager__c;
                        acc.Renewal_Owner__c  = contr.Primary_Renewal_Owner__c;
                    }
                }
            }
            system.debug('### newContracts.get(contr.Id).Contract_ARR__c: ' + newContracts.get(contr.Id).Contract_ARR__c);
            system.debug('### oldContracts.get(contr.Id).Contract_ARR__c: ' + oldContracts.get(contr.Id).Contract_ARR__c);
            if(newContracts.get(contr.Id).Contract_ARR__c != oldContracts.get(contr.Id).Contract_ARR__c){
                system.debug('### in:');
                if(!opp.isEmpty() && opp[0].Selected_Company_Contract__c == contr.Id){
                    system.debug('### in2:');
                    opp[0].Original_Contract_ARR__c = contr.Contract_ARR__c;
                    oppsToUpdate.add(opp[0]);
                    system.debug('### oppsToUpdate: ' + oppsToUpdate);
                }
            }
        }

        if(!oppsToUpdate.isEmpty()){
            Database.update(oppsToUpdate);
        }
    }
}