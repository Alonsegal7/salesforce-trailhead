public class PartnerCommission_AccPlanPeriod_Queue implements System.Queueable {
    private List<Account> mondayAccountsList;     
    private static final String CLASS_NAME_CONST = 'PartnerCommission_AccPlanPeriod_Queue';

    public PartnerCommission_AccPlanPeriod_Queue(List<Account> mondayAccountsList) {
        this.mondayAccountsList = mondayAccountsList;
    }

    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPartnerCommissionList = new List<Partner_Commission__c>();
        PartnerCommissionService pcService = new PartnerCommissionService();
        try {
            Map<Id,Account> mondayAccountsMap = new Map<Id,Account>(mondayAccountsList);
            Map<Id,List<Partner_Commission__c>> mondayAccIdPartnerCommisionMap = pcService.getLastPcsMap(mondayAccountsMap.keySet());
            if(mondayAccIdPartnerCommisionMap.isEmpty()) return;
            Set<Id> activeContractsIds = new Set<Id>();
            for(Account acc: mondayAccountsList){
                if(acc.Active_Contract__c != null) activeContractsIds.add(acc.Active_Contract__c);
            }
            Map<Id,Contract> activeContractsMap = new Map<Id,Contract>([select Id, StartDate, EndDate, Period__c from Contract where Id in: activeContractsIds]);
            Set<Id> accountIdsForGetAccountsMap = new Set<Id>();
            Map<Id,Set<Id>> mondayAccountPartnerIdToCreatePC = new Map<Id,Set<Id>>();

            for(Account mondayAccount: mondayAccountsList){
                Contract activeCon = activeContractsMap.get(mondayAccount.Active_Contract__c);
                if(!mondayAccIdPartnerCommisionMap.containsKey(mondayAccount.Id)) continue; //monday account has no pcs
                if(activeCon == null || mondayAccount.Plan_Period__c != activeCon.Period__c) continue; //if the active contract period matches the account plan period - if not we do nothing
                String closeReason = '';
                if(mondayAccount.Plan_Period__c.containsIgnoreCase('monthly')) closeReason = 'Yearly to Monthly Transfer';
                else if(mondayAccount.Plan_Period__c.containsIgnoreCase('yearly')) closeReason = 'Monthly to Yearly Transfer';
                //set end date from active contract to last pcs and prepare new pcs
                for(Partner_Commission__c pc: mondayAccIdPartnerCommisionMap.get(mondayAccount.Id)) {
                    if(pc.End_Date__c == null || pc.End_Date__c > Date.today()){
                        accountIdsForGetAccountsMap.add(mondayAccount.Id);
                        accountIdsForGetAccountsMap.add(pc.Partner_Company__c);
                        newPartnerCommissionList.add(new Partner_Commission__c(
                            Id = pc.Id, 
                            is_Last__c = false, 
                            End_Date__c = activeCon.StartDate.addDays(-1),
                            Close_Reason__c = closeReason
                        ));
                        if(mondayAccountPartnerIdToCreatePC.containsKey(mondayAccount.Id)){
                            mondayAccountPartnerIdToCreatePC.get(mondayAccount.Id).add(pc.Partner_Company__c);
                        } else {
                            mondayAccountPartnerIdToCreatePC.put(mondayAccount.Id, new Set<Id>{pc.Partner_Company__c});
                        }
                    }
                }
            }

            if(!newPartnerCommissionList.isEmpty()) {
                pcService.upsertPartnerCommissionInQueue(newPartnerCommissionList, CLASS_NAME_CONST);
                newPartnerCommissionList.clear();
            }

            if(!mondayAccountPartnerIdToCreatePC.isEmpty()){
                Map<Id,Account> accountsMap = pcService.getAccountsMap(accountIdsForGetAccountsMap);
                for(Id mondayAccId: mondayAccountPartnerIdToCreatePC.keySet()){
                    Account mondayAcc = mondayAccountsMap.get(mondayAccId);
                    String openReason = '';
                    if(mondayAcc.Plan_Period__c.containsIgnoreCase('monthly')) openReason = 'Yearly to Monthly Transfer';
                    else if(mondayAcc.Plan_Period__c.containsIgnoreCase('yearly')) openReason = 'Monthly to Yearly Transfer';
                    Contract activeCon = activeContractsMap.get(mondayAcc.Active_Contract__c);
                    //TBD - need to exclude yearly <-> two-yearly 
                    for(Id partnerId: mondayAccountPartnerIdToCreatePC.get(mondayAccId)){
                        Partner_Commission__c newPartnerCommission = pcService.createNewPc(accountsMap.get(mondayAccId), accountsMap.get(partnerId), null, openReason);
                        newPartnerCommission.Start_Date__c = activeCon.StartDate;
                        if(activeCon.Period__c.containsIgnoreCase('monthly')){
                            newPartnerCommission.End_Date__c = activeCon.StartDate.addYears(1);
                            newPartnerCommission.Is_Future_Payment__c = true;
                        }
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