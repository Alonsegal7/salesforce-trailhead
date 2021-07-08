public class PartnerCommissionService {

    public static Boolean firstRunOpp = true;
    public static Boolean firstRunAccARR = true;
    public static Boolean firstRunAccTrans = true;

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
        String dynamicQuery = 'select Start_Date__c, End_Date__c, Partner_Company__c, Monday_Account__c from Partner_Commission__c where Partner_Company__c IN: partnerCompanyIds and Monday_Account__c IN: mondayAccountIds';
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

    private String getOverlapKey(Partner_Commission__c pc){
        return String.valueOf(pc.Partner_Company__c) + String.valueOf(pc.Monday_Account__c);
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
}