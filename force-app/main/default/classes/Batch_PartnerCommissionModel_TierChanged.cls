public without sharing class Batch_PartnerCommissionModel_TierChanged implements Database.Batchable<sObject>, Database.Stateful {
    
    private Date startFrom; // user input
    private set<id> accountsToExclude_set; //user optional input - set of ids of account we do not want to include in this batch scope, they are excluded from the query in start
    private Id partnerAccountId; //user optional input - account to run the script on
    private Datetime startDT;
    private Datetime endDT;
    private string reason = 'Partner New Tier';

    public Batch_PartnerCommissionModel_TierChanged(Date startFrom) {
        this.startFrom = startFrom;
        setStartEndDatetimes();
    }

    public Batch_PartnerCommissionModel_TierChanged(Date startFrom, set<id> accountsToExclude) {
        this.startFrom = startFrom;
        setStartEndDatetimes();
        this.accountsToExclude_set = accountsToExclude_set;
    }

    public Batch_PartnerCommissionModel_TierChanged(Date startFrom, Id partnerAccountId) {
        this.startFrom = startFrom;
        setStartEndDatetimes();
        this.partnerAccountId = partnerAccountId;
    }

    private void setStartEndDatetimes(){
        this.startDT = this.startFrom.toStartOfMonth(); // start datetime of new PCMs and PCs will be the 1st of month of the starting from at 00:00:00
        this.endDT = this.startDT.addSeconds(-1); // end time of old PCMs and PCs will be the end of prev month at 23:59:59
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
            system.debug('Batch_PartnerCommissionModel_TierChanged entered start');
            system.debug('Batch_PartnerCommissionModel_TierChanged startDT: '+startDT);
            system.debug('Batch_PartnerCommissionModel_TierChanged endDT: '+endDT);

            String query = 'select Id, Name, Partner_Tier__c, Partner_Commission_Model__c, Partner_Commission_Model__r.Commission_Model__r.Partner_Tier__c, Partner_Commission_Model__r.Start_Date__c, Partner_Commission_Model__r.End_Date__c';
            query += ' from Account where';
            query += ' RecordType.DeveloperName = \'Partner_Company\'';     //partner accounts only
            query += ' and Partner_Tier__c != null';                        //with tier not blank
            query += ' and Partner_Commission_Model__c != null';            //with active PCM
            query += ' and (Partner_Commission_Model__r.End_Date__c = null or Partner_Commission_Model__r.End_Date__c > TODAY)'; 
            if(accountsToExclude_set != null && !accountsToExclude_set.isEmpty()) query += ' and Id not in: accountsToExclude_set'; //excluded accounts from batch input param
            else if(partnerAccountId != null) query += ' and Id =: partnerAccountId'; //target account from batch input param
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
            List<Partner_Commission_Model__c> pcmsToDeleteList = new List<Partner_Commission_Model__c>();

            for(Account acc: scope){
                if(acc.Partner_Tier__c != acc.Partner_Commission_Model__r.Commission_Model__r.Partner_Tier__c){
                    if(acc.Partner_Commission_Model__r.Start_Date__c >= startFrom.toStartOfMonth()){ //pcms created during or after startFrom month with wrong tier will be deleted and replaced with new pcms with correct tier
                        pcmsToDeleteList.add(new Partner_Commission_Model__c(
                            Id = acc.Partner_Commission_Model__c
                        ));
                    } else { //pcms with Start_Date__c before the startFrom date will be canceled and replaced with new pcms with correct tier
                        pcmsToCloseList.add(new Partner_Commission_Model__c(
                            Id = acc.Partner_Commission_Model__c, 
                            End_Date__c = endDT
                        ));
                    }
                    pcmsToOpenList.add(new Partner_Commission_Model__c( //new pcms with correct tier
                        Name = acc.Name + ' - ' + acc.Partner_Tier__c, 
                        Partner_Company__c = acc.Id, 
                        Commission_Model__c = commissionModelMap.get(acc.Partner_Tier__c).Id, 
                        Start_Date__c = startDT
                    ));
                    relevantAccounts_set.add(acc.Id); // all accounts with tier change are relevant
                }
            }
            if(relevantAccounts_set.isEmpty()) return;
            PartnerCommissionService service = new PartnerCommissionService();
            if(!pcmsToDeleteList.isEmpty()) Database.delete(pcmsToDeleteList);
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
                                                            Start_Date__c, 
                                                            End_Date__c, 
                                                            Percentage__c,
                                                            Trigger_Valid_From__c
                                                            from Partner_Commission__c 
                                                            where is_Last__c = true 
                                                            and Renewable__c = true 
                                                            and Partner_Company__c IN: relevantAccounts_set
                                                            and (End_Date__c = null or End_Date__c >=: startDT)]; 

            if(existingPcs.isEmpty()) return;
            system.debug('existingPcs: '+ existingPcs);

            List<Partner_Commission__c> pcsToInsert = new List<Partner_Commission__c>();
            List<Partner_Commission__c> pcsToUpdate = new List<Partner_Commission__c>();
            for(Partner_Commission__c pc: existingPcs){
                Commission_Model__c matchingCm = commissionModelMap.get(pc.Partner_Company__r.Partner_Tier__c);
                if(pc.Trigger_Valid_From__c >= startFrom.toStartOfMonth() || pc.Start_Date__c >= startFrom.toStartOfMonth()){ //PCs valid from the startFrom month (Trigger_Valid_From__c) will not be updated with enddate but only updated with new PCM and percent.
                    pc = updatePCbyCM(pc, matchingCm);
                    pc.Partner_Commission_Model__c = partnerAccToPcmMap.get(pc.Partner_Company__c);
                    pcsToUpdate.add(pc);
                    continue;
                }
                Partner_Commission__c newPc = pc.clone(false, true, false, false);
                newPc.Trigger_Valid_From__c = null;
                newPc.Start_Date__c = startDT;
                newPc.End_Date__c = null;
                newPc = updatePCbyCM(newPc, matchingCm);
                newPc.Previous_Partner_Commission__c = pc.Id;
                newPc.Partner_Commission_Model__c = partnerAccToPcmMap.get(pc.Partner_Company__c);
                newPc.Created_From__c = 'Code';
                newPc.Creation_Reason__c = reason;
                newPc.Name = pc.Pulse_Account_ID__c + ' - ' + pc.Partner_Company__r.Name + ' - ' + matchingCm.Partner_Tier__c;
                pcsToInsert.add(newPc);
                pcsToUpdate.add(new Partner_Commission__c(Id = pc.Id, End_Date__c = endDT, Close_Reason__c = reason, is_Last__c = false));
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

    private Partner_Commission__c updatePCbyCM(Partner_Commission__c pc, Commission_Model__c matchingCm){
        if(matchingCm.Period__c != null) {
            pc.End_Date__c = pc.Start_Date__c.addMonths(Integer.valueOf(matchingCm.Period__c));
        }
        if(pc.Account_Source__c == 'Inbound'){
            pc.Percentage__c = matchingCm.Inbound_Percent__c;
        } else if(pc.Account_Source__c == 'Outbound'){
            pc.Percentage__c = matchingCm.Outbound_Percent__c;
        }
        pc.Type__c = matchingCm.Commission_Type__c;
        return pc;
    }
}