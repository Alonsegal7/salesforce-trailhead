public without sharing class Batch_PartnerCommissionModel_TierChanged implements Database.Batchable<sObject>, Database.Stateful {
    
    private Datetime startingFrom; //this datetime param will be the end date of the existing PCs & PCMs, start date of the new ones will be startingFrom + 1 minute.
    private set<id> accountsToExclude_set; //set of ids of account we do not want to include in this batch scope, they are excluded from the query in start

    public Batch_PartnerCommissionModel_TierChanged(Datetime startingFromDT, set<id> accountsToExclude) {
        this.startingFrom = startingFromDT;
        this.accountsToExclude_set = accountsToExclude_set;
    }

    private static Map<String,Commission_Model__c> commissionModelMap {
        get {
             if (commissionModelMap == null) {
                commissionModelMap = new Map<String,Commission_Model__c>();
                for(Commission_Model__c cm: [select Id, Name, Inbound_Percent__c, Outbound_Percent__c, Commission_Type__c, Period__c, Is_Active__c, Effective_Start_Date__c, Effective_End_Date__c, Partner_Tier__c from Commission_Model__c]){
                    commissionModelMap.put(cm.Partner_Tier__c, cm);
                }
            }
            return commissionModelMap;
        }
        set;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            String query = 'select Id, Name, Partner_Tier__c, Partner_Commission_Model__c, Partner_Commission_Model__r.Commission_Model__r.Partner_Tier__c, Partner_Commission_Model__r.End_Date__c';
            query += ' from Account where';
            query += ' RecordType.DeveloperName = \'Partner_Company\'';     //partner accounts only
            query += ' and Partner_Tier__c != null';                        //with tier not blank
            query += ' and Partner_Commission_Model__c != null';            //with active PCM
            query += ' and (Partner_Commission_Model__r.End_Date__c = null or Partner_Commission_Model__r.End_Date__c > TODAY)'; 
            //query += ' and Id = \'0011t00000sKAIcAAO\'';     //test account id
            if(accountsToExclude_set != null && !accountsToExclude_set.isEmpty()) query += ' and Id not in: accountsToExclude_set';               //excluded accounts from batch input param
            system.debug('Batch_PartnerCommissionModel_TierChanged start query: ' + query);
            return Database.getQueryLocator(query);
        }catch(Exception e){
            system.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            //Utilities.sendEmail('Error in Apex Job Batch_PartnerCommissionModel_TierChanged: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'kseniasm@monday.com'}); 
            return null;
        }
    }

    public void execute(Database.BatchableContext BC, list<Account> scope){
        try{
            system.debug('Batch_PartnerCommissionModel_TierChanged entered execute');
            system.debug('Batch_PartnerCommissionModel_TierChanged commissionModelMap: ' + commissionModelMap);

            Set<Id> relevantAccounts_set = new Set<Id>();
            List<Partner_Commission_Model__c> pcmsToCloseList = new List<Partner_Commission_Model__c>();
            List<Partner_Commission_Model__c> pcmsToOpenList = new List<Partner_Commission_Model__c>();

            for(Account acc: scope){
                if(acc.Partner_Tier__c != acc.Partner_Commission_Model__r.Commission_Model__r.Partner_Tier__c){
                    relevantAccounts_set.add(acc.Id);
                    pcmsToCloseList.add(new Partner_Commission_Model__c(Id = acc.Partner_Commission_Model__c, End_Date__c = startingFrom));
                    system.debug('startingFrom: ' + startingFrom);
                    pcmsToOpenList.add(new Partner_Commission_Model__c(Name = acc.Name + ' - ' + acc.Partner_Tier__c, Partner_Company__c = acc.Id, Commission_Model__c = commissionModelMap.get(acc.Partner_Tier__c).Id, Start_Date__c = startingFrom.addMinutes(1)));
                }
            }
            if(relevantAccounts_set.isEmpty()) return;
            PartnerCommissionService service = new PartnerCommissionService();
            if(!pcmsToCloseList.isEmpty()) service.upsertPcmInQueue(pcmsToCloseList, 'PartnerCommissionModel_PartnerTierChanged close PCMs');
            if(!pcmsToOpenList.isEmpty()) service.upsertPcmInQueue(pcmsToOpenList, 'PartnerCommissionModel_PartnerTierChanged new PCMs');

            system.debug('Batch_PartnerCommissionModel_TierChanged pcmsToCloseList: ' + pcmsToCloseList);
            system.debug('Batch_PartnerCommissionModel_TierChanged pcmsToOpenList: ' + pcmsToOpenList);

            Map<Id,Id> partnerAccToPcmMap = new Map<Id,Id>();
            for(Partner_Commission_Model__c newPcm: pcmsToOpenList){
                partnerAccToPcmMap.put(newPcm.Partner_Company__c, newPcm.Id);
            }
            system.debug('partnerAccToPcmMap: '+ partnerAccToPcmMap);

            List<Partner_Commission__c> existingPcs = [select Id, 
                                                            Creation_Reason__c, 
                                                            Name, 
                                                            Partner_Commission_Model__c, 
                                                            Partner_Company__c, 
                                                            Partner_Company__r.Name, 
                                                            Partner_Company__r.Partner_Tier__c, 
                                                            Partner_ID__c, 
                                                            Partner_Type__c, 
                                                            Type__c, 
                                                            Monday_Account__c, 
                                                            Pulse_Account_ID__c, 
                                                            Account_Source__c, 
                                                            Created_From__c, 
                                                            ARR_Upon_Create__c, 
                                                            Opportunity__c, 
                                                            Start_Date__c, 
                                                            End_Date__c, 
                                                            Percentage__c from Partner_Commission__c 
                                                            where is_Last__c = true and Renewable__c = true and Partner_Company__c IN: relevantAccounts_set];

            if(existingPcs.isEmpty()) return;
            system.debug('existingPcs: '+ existingPcs);

            List<Partner_Commission__c> pcsToInsert = new List<Partner_Commission__c>();
            List<Partner_Commission__c> pcsToUpdate = new List<Partner_Commission__c>();
            for(Partner_Commission__c pc: existingPcs){
                Partner_Commission__c newPc = pc.clone(false, true, false, false);
                newPc.Start_Date__c = startingFrom.addMinutes(1);
                newPc.End_Date__c = null;
                Commission_Model__c matchingCm = commissionModelMap.get(pc.Partner_Company__r.Partner_Tier__c);
                if(matchingCm.Period__c != null) {
                    newPc.End_Date__c = newPc.Start_Date__c.addMonths(Integer.valueOf(matchingCm.Period__c));
                }
                if(newPc.Account_Source__c == 'Inbound'){
                    newPc.Percentage__c = matchingCm.Inbound_Percent__c;
                } else if(newPc.Account_Source__c == 'Outbound'){
                    newPc.Percentage__c = matchingCm.Outbound_Percent__c;
                }
                newPc.Partner_Commission_Model__c = partnerAccToPcmMap.get(pc.Partner_Company__c);
                newPc.Created_From__c = 'Code';
                newPc.Type__c = matchingCm.Commission_Type__c;
                newPc.Creation_Reason__c = 'Account Tier Changed';
                newPc.Name = pc.Pulse_Account_ID__c + ' - ' + pc.Partner_Company__r.Name + ' - ' + matchingCm.Partner_Tier__c;
                pcsToInsert.add(newPc);
                pcsToUpdate.add(new Partner_Commission__c(Id = pc.Id, End_Date__c = startingFrom, Close_Reason__c = 'Account Tier Changed', is_Last__c = false));
            }

            if(!pcsToUpdate.isEmpty()) {
                service.upsertPartnerCommissionInQueue(pcsToUpdate, 'PartnerCommissionModel_PartnerTierChanged close PCs');
            }
            system.debug('pcsToUpdate: '+ pcsToUpdate);
            if(!pcsToInsert.isEmpty()) {
                service.upsertPartnerCommissionInQueue(pcsToInsert, 'PartnerCommissionModel_PartnerTierChanged new PCs');
            }
            system.debug('pcsToInsert: '+ pcsToInsert);
        }catch(Exception e){
            system.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
            //Utilities.sendEmail('Error in Apex Job Batch_PartnerCommissionModel_TierChanged: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'kseniasm@monday.com'}); 
        }
    }

    public void finish(Database.BatchableContext BC){

    }
}