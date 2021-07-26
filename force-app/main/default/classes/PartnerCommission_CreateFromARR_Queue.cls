public class PartnerCommission_CreateFromARR_Queue implements System.Queueable {
    private List<Account> mondayAccountsList;     

    public PartnerCommission_CreateFromARR_Queue(List<Account> mondayAccountsList) {
        this.mondayAccountsList = mondayAccountsList;
    }

    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPartnerCommissionList = new List<Partner_Commission__c>();
        PartnerCommissionService pcService = new PartnerCommissionService();
        Map<Id,Account> mondayAccountsMap = new Map<Id,Account>(mondayAccountsList);
        Map<Id,List<Partner_Commission__c>> mondayAccIdPartnerCommisionMap = getLastPcsMap(mondayAccountsMap.keySet());
        if(mondayAccIdPartnerCommisionMap.isEmpty()) return;
        Map<String, GB_Threshold__c> gbThresholdsMap = pcService.getThsMap();
        Set<Id> channelPartnersIds = new Set<Id>();
        Map<Id,Set<Id>> mondayAccountPartnerIdToCreatePC = new Map<Id,Set<Id>>();
        for(Account mondayAccount: mondayAccountsList){
            if(!mondayAccIdPartnerCommisionMap.containsKey(mondayAccount.Id)) continue;
            if(mondayAccount.ARR__c >= gbThresholdsMap.get(mondayAccount.Account_Source_Type__c).Min_ARR__c) { //add pc for accounts that reached TH and have no active pc
                for(Partner_Commission__c partnerCom: mondayAccIdPartnerCommisionMap.get(mondayAccount.Id)) {
                    if(partnerCom.End_Date__c != null && partnerCom.End_Date__c <= mondayAccount.Last_ARR_Update_Timestamp__c){ //create pc
                        channelPartnersIds.add(partnerCom.Partner_Company__c);
                        newPartnerCommissionList.add(new Partner_Commission__c(Id = partnerCom.Id, is_Last__c = false));
                        if(mondayAccountPartnerIdToCreatePC.containsKey(mondayAccount.Id)){
                            mondayAccountPartnerIdToCreatePC.get(mondayAccount.Id).add(partnerCom.Partner_Company__c);
                        } else {
                            mondayAccountPartnerIdToCreatePC.put(mondayAccount.Id, new Set<Id>{partnerCom.Partner_Company__c});
                        }
                    }
                }     
            } else { //set end datetime to now on pc for accounts that got under TH and have active pc
                for(Partner_Commission__c partnerCom: mondayAccIdPartnerCommisionMap.get(mondayAccount.Id)) {
                    if(partnerCom.End_Date__c == null || partnerCom.End_Date__c > mondayAccount.Last_ARR_Update_Timestamp__c){ 
                        newPartnerCommissionList.add(new Partner_Commission__c(Id = partnerCom.Id, End_Date__c = mondayAccount.Last_ARR_Update_Timestamp__c, ARR_Upon_Close__c = mondayAccount.ARR__c));
                    }
                }
            }
        }

        if(!mondayAccountPartnerIdToCreatePC.isEmpty()){
            Map<Id,Account> channelPartnersMap = pcService.getChannelPartnersMap(channelPartnersIds);
            for(Id mondayAccId: mondayAccountPartnerIdToCreatePC.keySet()){
                for(Id partnerId: mondayAccountPartnerIdToCreatePC.get(mondayAccId)){
                    Partner_Commission__c newPartnerCommission = pcService.createPartnerCommissionRecord(mondayAccountsMap.get(mondayAccId), channelPartnersMap.get(partnerId), null);
                    newPartnerCommissionList.add(newPartnerCommission);
                }
            }
        }

        if(!newPartnerCommissionList.isEmpty()) Database.upsert(newPartnerCommissionList);
    }

    private Map<Id,List<Partner_Commission__c>> getLastPcsMap(Set<Id> mondayAccountsIds){
        Map<Id,List<Partner_Commission__c>> mondayAccIdPartnerCommisionMap = new Map<Id,List<Partner_Commission__c>>();
        List<Partner_Commission__c> lastPartnerCommissionList = [select Id, Monday_Account__c, Partner_Company__c, End_Date__c from Partner_Commission__c where Monday_Account__c IN: mondayAccountsIds and is_Last__c = true and Renewable__c = true];
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
}