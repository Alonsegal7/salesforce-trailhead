public class PartnerCommissionService {

    public static Boolean firstRunOpp = true;
    public static Boolean firstRunAccARR = true;
    public static Boolean firstRunAccTrans = true;
    public static Boolean firstRunAccSource = true;
    public static Boolean firstRunAccMerge = true;
    private static final String CMT_ERROR_EMAIL_CONST = 'Partner_Commission_Error_Email_Recipient';

    public Id mondayRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
    public class partnerCommissionException extends Exception {}

    // create first PC from transition to GB Opps
    public void partnerCommissionFromGbOpp(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap){
        List<Opportunity> relevantOppsList = new List<Opportunity>();
        Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        for(Opportunity opp: newOpps){
            if(opp.RecordTypeId == partnerRecordTypeId && opp.Channel_Partner__c != null && opp.AccountId != null && opp.Transition_to_GB__c && opp.StageName == 'Closed Won' && (oldOppsMap.get(opp.Id).StageName != opp.StageName || !oldOppsMap.get(opp.Id).Transition_to_GB__c)){
                relevantOppsList.add(opp);
            }
        }   
        if(relevantOppsList.isEmpty()) return;
        firstRunOpp = false;
        System.enqueueJob(new PartnerCommission_CreateFromOpp_Queue(relevantOppsList));
    }

    // create or end PC due to ARR change
    public void partnerCommissionFromARR(List<Account> newAccounts, Map<Id,Account> oldAccountsMap){
        List<Account> relevantMondayAccounts = new List<Account>();
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

    //partner transfer
    public void partnerCommissionFromPartnerTransfer(List<Account> newAccounts, Map<Id,Account> oldAccountsMap){
        List<Account> relevantMondayAccounts = new List<Account>();
        Map<Id,Id> partnersToClosePC = new Map<Id,Id>();
        Map<Id,Id> partnersToCreatePc = new Map<Id,Id>();
        
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

    // account source type changed - need to update the percent opn the PC
    public void updatePcOnAccountSourceChange(List<Account> newAccounts, Map<Id,Account> oldAccountsMap){
        Map<Id,String> mondayAccSourceTypeMap = new Map<Id,String>();
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

    //account merge - close PC of old account and create PC for new account
    public void updatePcOnAccountMerge(List<Account> newAccounts, Map<Id,Account> oldAccountsMap){
        List<Account> accountsToUpdatePcs = new List<Account>();
        Map<Id,String> accountsOldBigBrainId = new Map<Id,String>();
        for(Account acc: newAccounts){
            if(acc.RecordTypeId == mondayRecordTypeId 
                && acc.Is_GB_Account_Partners__c 
                && acc.primary_pulse_account_id__c != oldAccountsMap.get(acc.Id).primary_pulse_account_id__c){
                    accountsToUpdatePcs.add(acc);
                    accountsOldBigBrainId.put(acc.Id, oldAccountsMap.get(acc.Id).primary_pulse_account_id__c);
            }
        }
        if(accountsToUpdatePcs.isEmpty()) return;   
        firstRunAccMerge = false;       
        System.enqueueJob(new PartnerCommission_MergeAccounts_Queue(accountsToUpdatePcs, accountsOldBigBrainId));
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

    // Trigger_Valid_From__c if used for BigBrain to know if they should include a PC in their run or not
    // f.e if we run a report for July and we run it in the begining of Aug, let's say Aug 3rd, and on 1st/2nd of Aug some PCs were created we don't want the report to include them
    // so this will be achieved by setting a Trigger_Valid_From__c value for every PC
    // logic is - 1st of month of the creation time, unless we run a script to fix missing triggers with opps and then we put the 1st of month of the opp close date
    public void updatePartnerCommissionTriggerValidFrom(List<Partner_Commission__c> partnerCommissionList){
        for(Partner_Commission__c pc: partnerCommissionList){
            if(pc.Trigger_Valid_From__c == null) pc.Trigger_Valid_From__c = Date.today().toStartOfMonth();
        }
    }

    // set is Last to true when PC created manually
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
            //entry criteria
            if(oldPcMap == null || pc.Start_Date__c != oldPcMap.get(pc.Id).Start_Date__c || pc.End_Date__c != oldPcMap.get(pc.Id).End_Date__c){
                partnerCompanyIds.add(pc.Partner_Company__c);
                mondayAccountIds.add(pc.Monday_Account__c);
            }
        }
        if(partnerCompanyIds.isEmpty()) return; //no pcs found in entry criteria
        //checkDups(newPcList, newPcList); //check dups within the new pcs list
        String dynamicQuery = 'select Pulse_Account_ID__c, Start_Date__c, End_Date__c, Partner_Company__c, Monday_Account__c from Partner_Commission__c where Partner_Company__c IN: partnerCompanyIds and Monday_Account__c IN: mondayAccountIds';
        if(oldPcMap != null) {
            Set<Id> existingPcIds = oldPcMap.keySet();
            dynamicQuery += ' and Id NOT IN: existingPcIds';
        }
        List<Partner_Commission__c> existingPcList = Database.query(dynamicQuery);
        checkDups(newPcList, existingPcList);
    }

    // this method is the core for PC creation, all partner commission logic creates PCs by this method
    public Partner_Commission__c createPartnerCommissionRecord(Account mondayAccount, Account partnerAccount, Opportunity opp, String creationReson){
        Partner_Commission__c tempPartnerCommission = new Partner_Commission__c();
        tempPartnerCommission.Creation_Reason__c = creationReson;
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
        if(newPartnerCommissionList.isEmpty()) return;
        Boolean errorOccured = false;
        List<String> recipientsList;
        String errorsFound = '';
        String currErr = '';

        Database.UpsertResult[] lsr = Database.upsert(newPartnerCommissionList, false); // specify false for second parameter (allOrNone) so that if a record fails, the remainder of the DML operation can still succeed 
        for (Database.UpsertResult sr : lsr) {
            if (sr.isSuccess()) {
                System.debug('Successfully upserted Partner_Commission__c. Partner_Commission__c ID: ' + sr.getId());
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Partner_Commission__c fields that affected this error: ' + err.getFields());
                    currErr = '';
                    if(sr.getId() != null) currErr = 'Partner_Commission__c ID: ' + sr.getId() + ' ';
                    currErr = currErr + err.getStatusCode() + ': ' + err.getMessage();
                    errorsFound += currErr + ', ';
                }
            }
        }
        if(errorsFound != ''){
            recipientsList = [select Value__c from Environment_Variable__mdt where DeveloperName =: CMT_ERROR_EMAIL_CONST limit 1].Value__c.split(';');
            Utilities.sendEmail('Error in upsert PCs from ' + queueName, 'Errors found: ' + errorsFound + ' <br/>PCs List attempted to upsert: ' + JSON.serialize(newPartnerCommissionList) + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), recipientsList);
        }
    }

    public void upsertPcmInQueue(List<Partner_Commission_Model__c> newPcmList, String queueName){
        if(newPcmList.isEmpty()) return;
        Boolean errorOccured = false;
        List<String> recipientsList;
        String errorsFound = '';
        String currErr = '';

        Database.UpsertResult[] lsr = Database.upsert(newPcmList, false); // specify false for second parameter (allOrNone) so that if a record fails, the remainder of the DML operation can still succeed 
        for (Database.UpsertResult sr : lsr) {
            if (sr.isSuccess()) {
                System.debug('Successfully upserted Partner_Commission_Model__c. Partner_Commission_Model__c ID: ' + sr.getId());
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Partner_Commission_Model__c fields that affected this error: ' + err.getFields());
                    currErr = '';
                    if(sr.getId() != null) currErr = 'Partner_Commission_Model__c ID: ' + sr.getId() + ' ';
                    currErr = currErr + err.getStatusCode() + ': ' + err.getMessage();
                    errorsFound += currErr + ', ';
                }
            }
        }
        if(errorsFound != ''){
            recipientsList = [select Value__c from Environment_Variable__mdt where DeveloperName =: CMT_ERROR_EMAIL_CONST limit 1].Value__c.split(';');
            Utilities.sendEmail('Error in upsert PCMs from ' + queueName, 'Errors found: ' + errorsFound + ' <br/>PCMs List attempted to upsert: ' + JSON.serialize(newPcmList) + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), recipientsList);
        }
    }

    public void sendErrorEmail(String className, String body){
        List<String> recipientsList = [select Value__c from Environment_Variable__mdt where DeveloperName =:CMT_ERROR_EMAIL_CONST limit 1].Value__c.split(';');
        Utilities.sendEmail('Error in '+ className +': ', body, recipientsList);
    }

    public Map<String, GB_Threshold__c> getThsMap(){
        List<GB_Threshold__c> gbThresholds = [select Id, Source_Type__c, Min_ARR__c from GB_Threshold__c where Is_Active__c = true and Opportunity_Record_Type__c = 'Partner_Opportunity' and (Source_Type__c = 'Outbound' or Source_Type__c = 'Inbound')];
        Map<String, GB_Threshold__c> gbThresholdsMap = new Map<String, GB_Threshold__c>();
        for(GB_Threshold__c gbt: gbThresholds){
            gbThresholdsMap.put(gbt.Source_Type__c, gbt);
        }
        return gbThresholdsMap;
    }

    public Map<Id,List<Partner_Commission__c>> getLastPcsMap(Set<Id> mondayAccountsIds){
        Map<Id,List<Partner_Commission__c>> mondayAccIdPartnerCommisionMap = new Map<Id,List<Partner_Commission__c>>();
        List<Partner_Commission__c> lastPartnerCommissionList = [select Id, Monday_Account__c, Partner_Company__c, End_Date__c, Counter__c, Previous_Partner_Commission__c, Pulse_Account_Id__c from Partner_Commission__c where Monday_Account__c IN: mondayAccountsIds and is_Last__c = true and Renewable__c = true];
        if(lastPartnerCommissionList.isEmpty()) return mondayAccIdPartnerCommisionMap;
        //build map of MA and it's last PCs list
        for(Partner_Commission__c partnerCom: lastPartnerCommissionList){
            if(mondayAccIdPartnerCommisionMap.containsKey(partnerCom.Monday_Account__c)){
                mondayAccIdPartnerCommisionMap.get(partnerCom.Monday_Account__c).add(partnerCom);
            } else {
                mondayAccIdPartnerCommisionMap.put(partnerCom.Monday_Account__c, new List<Partner_Commission__c>{partnerCom});
            }
        }
        return mondayAccIdPartnerCommisionMap;
    }

    //runs in before insert!
    public void setPcCounterAndPreviousPc(List<Partner_Commission__c> newPcList){
        Set<Id> mondayAccountIds = new Set<Id>();
        for(Partner_Commission__c pc: newPcList){
            mondayAccountIds.add(pc.Monday_Account__c);
            pc.Counter__c = 1;
        }
        Map<Id,List<Partner_Commission__c>> mondayAccIdPartnerCommisionMap = getLastPcsMap(mondayAccountIds);
        if(mondayAccIdPartnerCommisionMap.isEmpty()) return;

        for(Partner_Commission__c newPc: newPcList){
            if(!mondayAccIdPartnerCommisionMap.containsKey(newPc.Monday_Account__c)) continue;
            for(Partner_Commission__c existingPc: mondayAccIdPartnerCommisionMap.get(newPc.Monday_Account__c)){
                if(newPc.Partner_Company__c == existingPc.Partner_Company__c){
                    if(existingPc.Counter__c != null) newPc.Counter__c += existingPc.Counter__c;
                    else newPc.Counter__c = 2;
                    newPc.Previous_Partner_Commission__c = existingPc.Id;
                }
            }
        }
    }

    private String getOverlapKey(Partner_Commission__c pc){
        return String.valueOf(pc.Partner_Company__c) + String.valueOf(pc.Pulse_Account_ID__c) + String.valueOf(pc.Monday_Account__c);
    }

    private void checkDups(List<Partner_Commission__c> newPcsList, List<Partner_Commission__c> existingPcList){
        String key = '';
        String errorMsg = '';
        Map<String,List<Partner_Commission__c>> pcMap = new Map<String,List<Partner_Commission__c>>();
        for(Partner_Commission__c pc: existingPcList){
            key = getOverlapKey(pc);
            if(pcMap.containsKey(key)){
                pcMap.get(key).add(pc);
            } else {
                pcMap.put(key, new list<Partner_Commission__c>{pc});
            }
        }
        //check comparing to existing pcs
        for(Partner_Commission__c newPc : newPcsList){
            key = getOverlapKey(newPc);
            if(pcMap.containsKey(key)){
                for(Partner_Commission__c existingPc: pcMap.get(key)){
                    if((newPc.Start_Date__c >= existingPc.Start_Date__c && (existingPc.End_Date__c == null || newPc.Start_Date__c <= existingPc.End_Date__c)) 
                    || (existingPc.Start_Date__c >= newPc.Start_Date__c && (newPc.End_Date__c == null || existingPc.Start_Date__c <= newPc.End_Date__c))){
                        errorMsg = 'PC DATES_OVERLAP; ';
                        errorMsg += 'Partner_Company__c: '+newPc.Partner_Company__c+'; Monday_Account__c: '+newPc.Monday_Account__c;
                        errorMsg +=  '; existing pc Id: '+existingPc.Id+'; ';
                        if(newPc.Id != null) errorMsg +=  'new pc Id: '+newPc.Id+';';
                        throw new partnerCommissionException(errorMsg);
                    }
                }
            }
        } 
    }
}