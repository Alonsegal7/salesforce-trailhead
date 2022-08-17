public class PartnerCommission_AccPlanPeriod_Queue implements System.Queueable {
    private List<Account> mondayAccountsList;     
    private static final String CLASS_NAME_CONST = 'PartnerCommission_AccPlanPeriod_Queue';

    public PartnerCommission_AccPlanPeriod_Queue(List<Account> mondayAccountsList) {
        this.mondayAccountsList = mondayAccountsList;
    }

    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPC_list = new List<Partner_Commission__c>();
        PartnerCommissionService pcService = new PartnerCommissionService();
        try {
            Map<Id,Account> mondayAccountsMap = new Map<Id,Account>(mondayAccountsList);
            Map<Id,List<Partner_Commission__c>> maPcs_map = pcService.getLastPcsMap(mondayAccountsMap.keySet());
            //remove the pcs that are not active or are monthly with is_future_payment__c = false (old monthly pcs)
            for(Id maId: maPcs_map.keySet()){
                list<Partner_Commission__c> curr_pc_list = maPcs_map.get(maId);
                for(Integer i=0;i<curr_pc_list.size();i++){
                    Partner_Commission__c curr_pc = curr_pc_list[i];
                    if(!curr_pc.Is_Active__c || //not active
                        (!curr_pc.Is_Future_Payment__c && mondayAccountsMap.get(maId).Plan_Period__c == 'yearly')){ //or old monthly (is_future_payment__c = false) changed to yearly
                        curr_pc_list.remove(i);
                    }
                }
                if(curr_pc_list.isEmpty()) maPcs_map.remove(maId);
            }
            if(maPcs_map.isEmpty()) return;

            Set<Id> activeContractsIds = new Set<Id>();
            for(Account acc: mondayAccountsList){
                if(acc.Active_Contract__c != null) activeContractsIds.add(acc.Active_Contract__c);
            }
            Map<Id,Contract> activeContractsMap = new Map<Id,Contract>([select Id, StartDate, EndDate, Period__c from Contract where Id in: activeContractsIds]);
            Set<Id> accountIdsForGetAccountsMap = new Set<Id>();
            Map<Id,Set<Id>> maToPartnerComp_map = new Map<Id,Set<Id>>();

            for(Account mondayAccount: mondayAccountsList){
                if(!maPcs_map.containsKey(mondayAccount.Id)) continue; // monday account has no pcs
                Contract activeCon = activeContractsMap.get(mondayAccount.Active_Contract__c);
                if(activeCon == null || mondayAccount.Plan_Period__c != activeCon.Period__c) continue;  // active contract is null 
                                                                                                        // or active contract period does not match the ma new plan period
                String closeReason = '';
                if(mondayAccount.Plan_Period__c.containsIgnoreCase('monthly')) closeReason = 'Yearly to Monthly Transfer';
                else if(mondayAccount.Plan_Period__c.containsIgnoreCase('yearly')) closeReason = 'Monthly to Yearly Transfer';

                for(Partner_Commission__c pc: maPcs_map.get(mondayAccount.Id)) {
                    if(pc.End_Date__c == null || pc.End_Date__c > Date.today()){
                        accountIdsForGetAccountsMap.add(mondayAccount.Id);
                        accountIdsForGetAccountsMap.add(pc.Partner_Company__c);
                        newPC_list.add(new Partner_Commission__c(
                            Id = pc.Id, 
                            is_Last__c = false, 
                            End_Date__c = activeCon.StartDate.addDays(-1),
                            Close_Reason__c = closeReason
                        ));
                        if(maToPartnerComp_map.containsKey(mondayAccount.Id)){
                            maToPartnerComp_map.get(mondayAccount.Id).add(pc.Partner_Company__c);
                        } else {
                            maToPartnerComp_map.put(mondayAccount.Id, new Set<Id>{pc.Partner_Company__c});
                        }
                    }
                }
            }

            if(!newPC_list.isEmpty()) {
                pcService.upsertPartnerCommissionInQueue(newPC_list, CLASS_NAME_CONST);
                newPC_list.clear();
            }

            if(!maToPartnerComp_map.isEmpty()){
                Map<Id,Account> accountsMap = pcService.getAccountsMap(accountIdsForGetAccountsMap);
                for(Id mondayAccId: maToPartnerComp_map.keySet()){
                    Account mondayAcc = mondayAccountsMap.get(mondayAccId);
                    String openReason = '';
                    if(mondayAcc.Plan_Period__c.containsIgnoreCase('monthly')) openReason = 'Yearly to Monthly Transfer';
                    else if(mondayAcc.Plan_Period__c.containsIgnoreCase('yearly')) openReason = 'Monthly to Yearly Transfer';
                    for(Id partnerId: maToPartnerComp_map.get(mondayAccId)){
                        newPC_list.add(pcService.createNewPc(accountsMap.get(mondayAccId), accountsMap.get(partnerId), null, openReason));
                    }
                }
            }

            if(!newPC_list.isEmpty()) {
                pcService.upsertPartnerCommissionInQueue(newPC_list, CLASS_NAME_CONST);
            }
        } catch (Exception ex){
            pcService.sendErrorEmail(CLASS_NAME_CONST, ex.getMessage());
            throw ex;
        }
    }
}