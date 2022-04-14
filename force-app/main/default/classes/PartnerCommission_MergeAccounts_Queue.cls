public with sharing class PartnerCommission_MergeAccounts_Queue implements System.Queueable {
    private List<Account> accountsToUpdatePcs;
    private Map<Id,String> accountsOldBigBrainId;
    private static final String CLASS_NAME_CONST = 'PartnerCommission_MergeAccounts_Queue';

    public PartnerCommission_MergeAccounts_Queue(List<Account> accountsToUpdatePcs, Map<Id,String> accountsOldBigBrainId) {
        this.accountsToUpdatePcs = accountsToUpdatePcs;
        this.accountsOldBigBrainId = accountsOldBigBrainId;
    }

    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPartnerCommissionList = new List<Partner_Commission__c>();
        Map<Id,Account> mondayAccountsMap = new Map<Id,Account>(accountsToUpdatePcs);
        PartnerCommissionService pcService = new PartnerCommissionService();
        try {
            Map<Id,List<Partner_Commission__c>> mondayAccIdPartnerCommisionMap = pcService.getLastPcsMap(mondayAccountsMap.keySet());
            if(mondayAccIdPartnerCommisionMap.isEmpty()) return;
            Set<Id> channelPartnersIds = new Set<Id>();
            Map<Id,Set<Id>> mondayAccountPartnerIdToCreatePC = new Map<Id,Set<Id>>();
            for(Account mondayAccount: accountsToUpdatePcs){
                if(!mondayAccIdPartnerCommisionMap.containsKey(mondayAccount.Id)) continue; //no old pcs
                for(Partner_Commission__c partnerCom: mondayAccIdPartnerCommisionMap.get(mondayAccount.Id)) {
                    //active pcs matching the old big brain id - need to set end date to now
                    if(partnerCom.Pulse_Account_ID__c == accountsOldBigBrainId.get(mondayAccount.Id) && (partnerCom.End_Date__c == null || partnerCom.End_Date__c > Datetime.now())){ //create pc
                        newPartnerCommissionList.add(new Partner_Commission__c(Id = partnerCom.Id, End_Date__c = Datetime.now(), Close_Reason__c = 'Merge Accounts', is_Last__c = false));
                        channelPartnersIds.add(partnerCom.Partner_Company__c);
                        if(mondayAccountPartnerIdToCreatePC.containsKey(mondayAccount.Id)){
                            mondayAccountPartnerIdToCreatePC.get(mondayAccount.Id).add(partnerCom.Partner_Company__c);
                        } else {
                            mondayAccountPartnerIdToCreatePC.put(mondayAccount.Id, new Set<Id>{partnerCom.Partner_Company__c});
                        }
                    }
                }     
            }
            if(!newPartnerCommissionList.isEmpty()) {
                pcService.upsertPartnerCommissionInQueue(newPartnerCommissionList, CLASS_NAME_CONST);
                newPartnerCommissionList.clear();
            }

            if(!mondayAccountPartnerIdToCreatePC.isEmpty()){
                Map<Id,Account> channelPartnersMap = pcService.getChannelPartnersMap(channelPartnersIds);
                for(Id mondayAccId: mondayAccountPartnerIdToCreatePC.keySet()){
                    for(Id partnerId: mondayAccountPartnerIdToCreatePC.get(mondayAccId)){
                        Partner_Commission__c newPartnerCommission = pcService.createPartnerCommissionRecord(mondayAccountsMap.get(mondayAccId), channelPartnersMap.get(partnerId), null, 'Merge Accounts');
                        newPartnerCommission.Start_Date__c = Datetime.now().addSeconds(1);
                        newPartnerCommissionList.add(newPartnerCommission);
                    }
                }
            }

            if(!newPartnerCommissionList.isEmpty()) {
                pcService.upsertPartnerCommissionInQueue(newPartnerCommissionList, CLASS_NAME_CONST);
            }
        } catch (Exception ex){
            pcService.sendErrorEmail(CLASS_NAME_CONST, ex.getMessage());
            throw ex;
        }
    }
}