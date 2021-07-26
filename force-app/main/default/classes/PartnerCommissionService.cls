public class PartnerCommissionService {

    public static Boolean firstRunOpp = true;
    public static Boolean firstRunAccARR = true;
    public static Boolean firstRunAccTrans = true;
    public static Boolean firstRunAccSource = true;

    public class partnerCommissionException extends Exception {}

    public void partnerCommissionFromGbOpp(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap){
        List<Opportunity> relevantOppsList = new List<Opportunity>();
        Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        for(Opportunity opp: newOpps){
            if(opp.RecordTypeId == partnerRecordTypeId && opp.Channel_Partner__c != null && opp.AccountId != null && opp.Transition_to_GB__c && opp.StageName == 'Closed Won' && oldOppsMap.get(opp.Id).StageName != opp.StageName){
                relevantOppsList.add(opp);
            }
        }   
        if(relevantOppsList.isEmpty()) return;
        firstRunOpp = false;
        System.enqueueJob(new PartnerCommission_CreateFromOpp_Queue(relevantOppsList));
    }

    public void partnerCommissionFromARR(List<Account> newAccounts, Map<Id,Account> oldAccountsMap){
        List<Account> relevantMondayAccounts = new List<Account>();
        Id mondayRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        for(Account acc: newAccounts){
            if(acc.RecordTypeId == mondayRecordTypeId 
                && acc.Is_GB_Account_Partners__c 
                && acc.ARR__c != oldAccountsMap.get(acc.Id).ARR__c){
                relevantMondayAccounts.add(acc);
            }
        }
        if(relevantMondayAccounts.isEmpty()) return;         
        firstRunAccARR = false; 
        System.enqueueJob(new PartnerCommission_CreateFromARR_Queue(relevantMondayAccounts));
    }

    public void partnerCommissionFromPartnerTransfer(List<Account> newAccounts, Map<Id,Account> oldAccountsMap){
        List<Account> relevantMondayAccounts = new List<Account>();
        Map<Id,Id> partnersToClosePC = new Map<Id,Id>();
        Map<Id,Id> partnersToCreatePc = new Map<Id,Id>();
        
        Id mondayRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        for(Account acc: newAccounts){
            if(acc.RecordTypeId == mondayRecordTypeId 
                && acc.Is_GB_Account_Partners__c 
                && acc.Channel_Partner__c != oldAccountsMap.get(acc.Id).Channel_Partner__c){
                relevantMondayAccounts.add(acc);
                if(oldAccountsMap.get(acc.Id).Channel_Partner__c != null) partnersToClosePC.put(acc.Id, oldAccountsMap.get(acc.Id).Channel_Partner__c);
                if(acc.Channel_Partner__c != null) partnersToCreatePc.put(acc.Id, acc.Channel_Partner__c);
            }
        }
        if(relevantMondayAccounts.isEmpty()) return;   
        firstRunAccTrans = false;       
        System.enqueueJob(new PartnerCommission_PartnerTransfer_Queue(relevantMondayAccounts, partnersToClosePC, partnersToCreatePc));
    }

    public void updatePcOnAccountSourceChange(List<Account> newAccounts, Map<Id,Account> oldAccountsMap){
        Map<Id,String> mondayAccSourceTypeMap = new Map<Id,String>();
        Id mondayRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        for(Account acc: newAccounts){
            if(acc.RecordTypeId == mondayRecordTypeId 
                && acc.Is_GB_Account_Partners__c 
                && acc.Account_Source_Type__c != oldAccountsMap.get(acc.Id).Account_Source_Type__c){
                    mondayAccSourceTypeMap.put(acc.Id, acc.Account_Source_Type__c);
            }
        }
        if(mondayAccSourceTypeMap.isEmpty()) return;   
        firstRunAccSource = false;       
        System.enqueueJob(new PartnerCommission_AccountSource_Queue(mondayAccSourceTypeMap));
    }

    public void updatePartnerCommissionVersion(List<Partner_Commission__c> partnerCommissionList, Map<Id, Partner_Commission__c> oldPartnerCommissionMap){
        //running in before trigger!!!
        if(oldPartnerCommissionMap == null){
            for(Partner_Commission__c pc: partnerCommissionList){
                pc.Version__c = 1;
            }
        } else {
            for(Partner_Commission__c pc: partnerCommissionList){
                if(pc.Percentage__c != oldPartnerCommissionMap.get(pc.Id).Percentage__c 
                    || pc.Start_Date__c != oldPartnerCommissionMap.get(pc.Id).Start_Date__c 
                    || pc.End_Date__c != oldPartnerCommissionMap.get(pc.Id).End_Date__c){
                    pc.Version__c += 1;
                }
            }
        }
    }

    public void updatePartnerCommissionTriggerValidFrom(List<Partner_Commission__c> partnerCommissionList){
        for(Partner_Commission__c pc: partnerCommissionList){
            pc.Trigger_Valid_From__c = Date.today().toStartOfMonth();
        }
    }

    public void setIsLastFalseForManual(List<Partner_Commission__c> partnerCommissionList){
        Set<Id> partnerIds = new Set<Id>();
        Set<Id> mondayAccIds = new Set<Id>();
        Set<String> relevantMondayAccPartnerPairs = new Set<String>();
        String key = '';
        for(Partner_Commission__c pc: partnerCommissionList){
            if(pc.Created_From__c == 'Manual') {
                partnerIds.add(pc.Partner_Company__c);
                mondayAccIds.add(pc.Monday_Account__c);
                key = getOverlapKey(pc);
                relevantMondayAccPartnerPairs.add(key);
            }
        }
        if(relevantMondayAccPartnerPairs.isEmpty()) return;
        Map<Id,Partner_Commission__c> partnerCommissionMap = new Map<Id,Partner_Commission__c>(partnerCommissionList);
        List<Partner_Commission__c> oldPcList = [select Id, Partner_Company__c, Monday_Account__c, Pulse_Account_ID__c from Partner_Commission__c where Is_Last__c = true and Monday_Account__c IN: mondayAccIds and Partner_Company__c IN: partnerIds and Id NOT IN: partnerCommissionMap.keySet()];
        List<Partner_Commission__c> oldPcsToUpdate = new List<Partner_Commission__c>();
        for(Partner_Commission__c pc: oldPcList){
            key = getOverlapKey(pc);
            if(relevantMondayAccPartnerPairs.contains(key)){
                oldPcsToUpdate.add(new Partner_Commission__c(Id = pc.Id, Is_Last__c = false));
            }
        }
        if(!oldPcsToUpdate.isEmpty()) Database.update(oldPcsToUpdate);
    }

    public void updateEndDateOnRenewableFalse(List<Partner_Commission__c> partnerCommissionList, Map<Id, Partner_Commission__c> oldPartnerCommissionMap){
        for(Partner_Commission__c pc: partnerCommissionList){
            if(!pc.Renewable__c && pc.Renewable__c != oldPartnerCommissionMap.get(pc.Id).Renewable__c && (pc.End_Date__c == null || pc.End_Date__c > Datetime.now())){
                pc.End_Date__c = Datetime.now();
            }
        }
    }

    public void checkIfExistingPcDatesOverlap(List<Partner_Commission__c> newPcList, Map<Id,Partner_Commission__c> oldPcMap){
        Set<Id> partnerCompanyIds = new Set<Id>();
        Set<Id> mondayAccountIds = new Set<Id>();
        for(Partner_Commission__c pc : newPcList){
            if(oldPcMap == null || pc.Start_Date__c != oldPcMap.get(pc.Id).Start_Date__c || pc.End_Date__c != oldPcMap.get(pc.Id).End_Date__c){
                partnerCompanyIds.add(pc.Partner_Company__c);
                mondayAccountIds.add(pc.Monday_Account__c);
            }
        }
        if(partnerCompanyIds.isEmpty()) return;
        String dynamicQuery = 'select Pulse_Account_ID__c, Start_Date__c, End_Date__c, Partner_Company__c, Monday_Account__c from Partner_Commission__c where Partner_Company__c IN: partnerCompanyIds and Monday_Account__c IN: mondayAccountIds';
        if(oldPcMap != null) {
            Set<Id> existingPcIds = oldPcMap.keySet();
            dynamicQuery += ' and Id NOT IN: existingPcIds';
        }
        List<Partner_Commission__c> existingPcList = Database.query(dynamicQuery);
        String key = '';
        Map<String,List<Partner_Commission__c>> pcMap = new Map<String,List<Partner_Commission__c>>();
        for(Partner_Commission__c pc: existingPcList){
            key = getOverlapKey(pc);
            if(pcMap.containsKey(key)){
                pcMap.get(key).add(pc);
            } else {
                pcMap.put(key, new list<Partner_Commission__c>{pc});
            }
        }
        for(Partner_Commission__c newPc : newPcList){
            key = getOverlapKey(newPc);
            if(pcMap.containsKey(key)){
                for(Partner_Commission__c existingPc: pcMap.get(key)){
                    if((newPc.Start_Date__c >= existingPc.Start_Date__c && (existingPc.End_Date__c == null || newPc.Start_Date__c <= existingPc.End_Date__c)) 
                    || (existingPc.Start_Date__c >= newPc.Start_Date__c && (newPc.End_Date__c == null || existingPc.Start_Date__c <= newPc.End_Date__c))){
                        throw new partnerCommissionException('Partner Commission dates overlap detected. Partner Commission Id: '+newPc.Id+';partnerId: '+newPc.Partner_Company__c+'; mondayAccountId: '+newPc.Monday_Account__c);
                    }
                }
            }
        }
    }

    public Partner_Commission__c createPartnerCommissionRecord(Account mondayAccount, Account partnerAccount, Opportunity opp){
        Partner_Commission__c tempPartnerCommission = new Partner_Commission__c();
        tempPartnerCommission.Name = mondayAccount.primary_pulse_account_id__c + ' - ' + partnerAccount.Name + ' - ' + partnerAccount.Partner_Tier__c;
        tempPartnerCommission.Partner_Commission_Model__c = partnerAccount.Partner_Commission_Model__c;
        tempPartnerCommission.Partner_Company__c = partnerAccount.Id;
        tempPartnerCommission.Partner_ID__c = partnerAccount.Id;
        tempPartnerCommission.Partner_Type__c = partnerAccount.Partner_Type__c;
        tempPartnerCommission.Type__c = partnerAccount.Partner_Commission_Model__r.Commission_Model__r.Commission_Type__c;
        tempPartnerCommission.Monday_Account__c = mondayAccount.Id;
        tempPartnerCommission.Pulse_Account_ID__c = mondayAccount.primary_pulse_account_id__c;
        tempPartnerCommission.Account_Source__c = mondayAccount.Account_Source_Type__c;
        tempPartnerCommission.Created_From__c = 'Code';
        tempPartnerCommission.ARR_Upon_Create__c = mondayAccount.ARR__c;
        if(opp != null) {
            tempPartnerCommission.Opportunity__c = opp.Id;
            if(opp.Is_Migrated_Commission__c) tempPartnerCommission.Start_Date__c = Datetime.now().addDays(-5);
            else tempPartnerCommission.Start_Date__c = mondayAccount.Sign_Up_Date__c;
        } else {
            tempPartnerCommission.Start_Date__c = mondayAccount.Last_ARR_Update_Timestamp__c;
        }
        if(partnerAccount.Partner_Commission_Model__r.Commission_Model__r.Period__c != null) {
            tempPartnerCommission.End_Date__c = tempPartnerCommission.Start_Date__c.addMonths(Integer.valueOf(partnerAccount.Partner_Commission_Model__r.Commission_Model__r.Period__c));
        }
        if(mondayAccount.Account_Source_Type__c == 'Inbound'){
            tempPartnerCommission.Percentage__c = partnerAccount.Partner_Commission_Model__r.Commission_Model__r.Inbound_Percent__c;
        } else if(mondayAccount.Account_Source_Type__c == 'Outbound'){
            tempPartnerCommission.Percentage__c = partnerAccount.Partner_Commission_Model__r.Commission_Model__r.Outbound_Percent__c;
        }
        return tempPartnerCommission;
    }

    public Map<Id,Account> getChannelPartnersMap(Set<Id> channelPartnersIds){
        Map<Id,Account> channelPartnersMap = new Map<Id,Account>([select Id, Name, Partner_Tier__c, Partner_Type__c, Partner_Commission_Model__c, Partner_Commission_Model__r.Commission_Model__r.Commission_Type__c, Partner_Commission_Model__r.Commission_Model__r.Period__c, Partner_Commission_Model__r.Commission_Model__r.Outbound_Percent__c, Partner_Commission_Model__r.Commission_Model__r.Inbound_Percent__c from Account where Id IN: channelPartnersIds]);
        return channelPartnersMap;
    }

    public void upsertPartnerCommissionInQueue(List<Partner_Commission__c> newPartnerCommissionList, String queueName){
        if(!newPartnerCommissionList.isEmpty()) {
            Database.SaveResult[] lsr = Database.insert(newPartnerCommissionList, false);
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    System.debug('Successfully upserted Partner_Commission__c. Partner_Commission__c ID: ' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Partner_Commission__c fields that affected this error: ' + err.getFields());
                        String body = '';
                        if(sr.getId() != null) body = 'Partner_Commission__c ID: ' + sr.getId() + ' ';
                        body = body + err.getStatusCode() + ': ' + err.getMessage();
                        Utilities.sendEmail('Error in '+queueName, body, new list<String>{label.SystemNotificationsDL});
                    }
                }
            }
        }
    }

    public Map<String, GB_Threshold__c> getThsMap(){
        List<GB_Threshold__c> gbThresholds = [select Id, Source_Type__c, Min_ARR__c from GB_Threshold__c where Is_Active__c = true and Opportunity_Record_Type__c = 'Partner_Opportunity' and (Source_Type__c = 'Outbound' or Source_Type__c = 'Inbound')];
        Map<String, GB_Threshold__c> gbThresholdsMap = new Map<String, GB_Threshold__c>();
        for(GB_Threshold__c gbt: gbThresholds){
            gbThresholdsMap.put(gbt.Source_Type__c, gbt);
        }
        return gbThresholdsMap;
    }

    public void connectNewReportsToCollectionsCommitments(List<Commission_Report__c> newReports){
        Map<String,Id> reportNumberToReportIdMap = new Map<String,Id>();
        for(Commission_Report__c report: newReports){
            reportNumberToReportIdMap.put(report.Big_Brain_Id__c, report.Id);
        }
        String query;
        for(String reportNum: reportNumberToReportIdMap.keySet()){
            query = 'select Id from Commission_Commitment__c where report_id__c = \''+reportNum+'\'';
            Batch_SearchAndReplace commitments = new Batch_SearchAndReplace(query, 'Commission_Report__c', reportNumberToReportIdMap.get(reportNum));
            query = 'select Id from Commission_Collection__c where report_id__c = \''+reportNum+'\'';
            Batch_SearchAndReplace collections = new Batch_SearchAndReplace(query, 'Commission_Report__c', reportNumberToReportIdMap.get(reportNum));
            Utilities.cleanFlexQueue();
            Database.executeBatch(commitments,100);
            Database.executeBatch(collections,100);
        }
    }

    public void setReportName(List<Commission_Report__c> newReports){
        for(Commission_Report__c report: newReports){
            report.name = 'report-'+report.Big_Brain_Id__c;
        }
    }

    private String getOverlapKey(Partner_Commission__c pc){
        return String.valueOf(pc.Partner_Company__c) + String.valueOf(pc.Pulse_Account_ID__c) + String.valueOf(pc.Monday_Account__c);
    }
}