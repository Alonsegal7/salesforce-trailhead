public class PartnerCommission_PartnerTransfer_Queue implements System.Queueable {
    private List<Account> mondayAccountsList;     
    private Map<Id,Id> partnersToClosePC;
    private Map<Id,Id> partnersToCreatePC;

    public PartnerCommission_PartnerTransfer_Queue(List<Account> mondayAccountsList, Map<Id,Id> partnersToClosePC, Map<Id,Id> partnersToCreatePC) {
        this.mondayAccountsList = mondayAccountsList;
        this.partnersToClosePC = partnersToClosePC;
        this.partnersToCreatePC = partnersToCreatePC;
    }

    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPartnerCommissionList = new List<Partner_Commission__c>();
        PartnerCommissionService pcService = new PartnerCommissionService();

        Map<Id,Account> mondayAccountsMap = new Map<Id,Account>(mondayAccountsList);
        if(!partnersToClosePC.isEmpty()){   // close all PCs of prev partners
            Set<Id> partnersIds = new Set<Id>(partnersToClosePC.values());
            List<Partner_Commission__c> pcToCloseList = [select Id, Monday_Account__c, Partner_Company__c from Partner_Commission__c where Monday_Account__c IN: partnersToClosePC.keySet() and Partner_Company__c IN: partnersIds and is_Last__c = true and Renewable__c = true];
            for(Partner_Commission__c pc: pcToCloseList){
                if(partnersToClosePC.containsKey(pc.Monday_Account__c) && partnersToClosePC.get(pc.Monday_Account__c) == pc.Partner_Company__c){
                    newPartnerCommissionList.add(new Partner_Commission__c(Id = pc.Id, Renewable__c = false, End_Date__c = mondayAccountsMap.get(pc.Monday_Account__c).Last_ARR_Update_Timestamp__c));
                }
            }
        }
        
        if(!partnersToCreatePC.isEmpty()) {// create PCs for all new partners
            Set<Id> partnerToCreateIds = new Set<Id>(partnersToCreatePC.values());
            List<Partner_Commission__c> existingPcsList = [select Id, Monday_Account__c, Partner_Company__c from Partner_Commission__c where Monday_Account__c IN: partnersToCreatePC.keySet() and Partner_Company__c IN: partnerToCreateIds and is_Last__c = true and Renewable__c = true and (End_Date__c = null or End_Date__c >: Datetime.now())];
            for(Partner_Commission__c pc: existingPcsList){
                if(partnersToCreatePC.containsKey(pc.Monday_Account__c) && partnersToCreatePC.get(pc.Monday_Account__c) == pc.Partner_Company__c){
                    partnersToCreatePC.remove(pc.Monday_Account__c);
                }
            }
            if(!partnersToCreatePC.isEmpty()){
                Map<Id,Account> channelPartnersMap = pcService.getChannelPartnersMap(new Set<Id>(partnersToCreatePC.values()));
                for(Id mondayAccId: partnersToCreatePC.keySet()){
                    if(mondayAccountsMap.containsKey(mondayAccId) && channelPartnersMap.containsKey(partnersToCreatePC.get(mondayAccId))){
                        Partner_Commission__c newPartnerCommission = pcService.createPartnerCommissionRecord(mondayAccountsMap.get(mondayAccId), channelPartnersMap.get(partnersToCreatePC.get(mondayAccId)), null);
                        newPartnerCommissionList.add(newPartnerCommission);
                    }
                }
            }
        }
        if(!newPartnerCommissionList.isEmpty()) Database.upsert(newPartnerCommissionList);
    }
}


