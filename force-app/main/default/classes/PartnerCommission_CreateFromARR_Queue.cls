public class PartnerCommission_CreateFromARR_Queue implements System.Queueable {
    private List<Account> mondayAccountsList;     
    private static final String CLASS_NAME_CONST = 'PartnerCommission_CreateFromARR_Queue';

    public PartnerCommission_CreateFromARR_Queue(List<Account> mondayAccountsList) {
        this.mondayAccountsList = mondayAccountsList;
    }

    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPartnerCommissionList = new List<Partner_Commission__c>();
        PartnerCommissionService pcService = new PartnerCommissionService();
        try {
            Map<Id,Account> mondayAccountsMap = new Map<Id,Account>(mondayAccountsList);
            Map<Id,List<Partner_Commission__c>> mondayAccIdPartnerCommisionMap = pcService.getLastPcsMap(mondayAccountsMap.keySet());
            if(mondayAccIdPartnerCommisionMap.isEmpty()) return;
            Map<String, GB_Threshold__c> gbThresholdsMap = pcService.getThsMap();
            Set<Id> accountIdsForGetAccountsMap = new Set<Id>();
            Map<Id,Set<Id>> mondayAccountPartnerIdToCreatePC = new Map<Id,Set<Id>>();
            for(Account mondayAccount: mondayAccountsList){
                if(!mondayAccIdPartnerCommisionMap.containsKey(mondayAccount.Id)) continue; //monday account has no pcs
                //ARR above TH
                if(mondayAccount.ARR__c >= gbThresholdsMap.get(mondayAccount.Account_Source_Type__c).Min_ARR__c) { //add pc for accounts that reached TH and have no active pc
                    for(Partner_Commission__c pc: mondayAccIdPartnerCommisionMap.get(mondayAccount.Id)) {
                        if(pc.End_Date__c != null && pc.End_Date__c <= mondayAccount.Last_ARR_Update_Timestamp__c){ //create pc
                            accountIdsForGetAccountsMap.add(mondayAccount.Id);
                            accountIdsForGetAccountsMap.add(pc.Partner_Company__c);
                            newPartnerCommissionList.add(new Partner_Commission__c(Id = pc.Id, is_Last__c = false));
                            if(mondayAccountPartnerIdToCreatePC.containsKey(mondayAccount.Id)){
                                mondayAccountPartnerIdToCreatePC.get(mondayAccount.Id).add(pc.Partner_Company__c);
                            } else {
                                mondayAccountPartnerIdToCreatePC.put(mondayAccount.Id, new Set<Id>{pc.Partner_Company__c});
                            }
                        }
                    }     
                } //ARR below TH
                else if(!mondayAccount.Outbound_TH_Excluded__c){ // we exclude account that were marked with Outbound_TH_Excluded__c=true. This was done because we had outbound TH = 0, then it changed to 3K. SO we wanted to keep all pcs created by the old th open.
                    //set end datetime to Last_ARR_Update_Timestamp__c on pc for accounts that got under TH and have active pc. Outbound_TH_Excluded__c - All the marked accounts should not be part of the logic to close PC b/c of ARR below new TH (3K). Those accounts should stay valid for commission.
                    for(Partner_Commission__c pc: mondayAccIdPartnerCommisionMap.get(mondayAccount.Id)) {
                        if(pc.End_Date__c == null || pc.End_Date__c > mondayAccount.Last_ARR_Update_Timestamp__c){ 
                            if(pc.Is_Future_Payment__c){ //when arr drops to zero on a monthly plan we set percentage to 0
                                if(mondayAccount.ARR__c == 0) newPartnerCommissionList.add(new Partner_Commission__c(Id = pc.Id, Percentage__c = 0));
                            } else {
                                newPartnerCommissionList.add(new Partner_Commission__c(Id = pc.Id, End_Date__c = mondayAccount.Last_ARR_Update_Timestamp__c.addSeconds(-1), ARR_Upon_Close__c = mondayAccount.ARR__c, Close_Reason__c = 'ARR below TH'));
                            }
                        }
                    }
                }
            }

            if(!mondayAccountPartnerIdToCreatePC.isEmpty()){
                Map<Id,Account> accountsMap = pcService.getAccountsMap(accountIdsForGetAccountsMap);
                for(Id mondayAccId: mondayAccountPartnerIdToCreatePC.keySet()){
                    for(Id partnerId: mondayAccountPartnerIdToCreatePC.get(mondayAccId)){
                        Partner_Commission__c newPartnerCommission = pcService.createNewPc(accountsMap.get(mondayAccId), accountsMap.get(partnerId), null, 'ARR above TH');
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