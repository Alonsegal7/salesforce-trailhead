public class PartnerCommission_CreateFromOpp_Queue implements System.Queueable {
    private List<Opportunity> oppsList;  
    public Boolean isRunningFromScript = false;
    private String createReason = 'GB Opp Closed';
    private static final String CLASS_NAME_CONST = 'PartnerCommission_CreateFromOpp_Queue';

    public PartnerCommission_CreateFromOpp_Queue(List<Opportunity> oppsList) {
        this.oppsList = oppsList;
    }
    
    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPartnerCommissionList = new List<Partner_Commission__c>();
        PartnerCommissionService pcService = new PartnerCommissionService();
        try {
            Map<Id, Account> accountsMap = getAccountsMap(oppsList);
            if(accountsMap.isEmpty()) return;
            if(isRunningFromScript) createReason = 'Fix opps with missing PC';
            Map<Id,Opportunity> partnerCoSellOppsMap = new Map<Id,Opportunity>();
            Set<Id> internalCoSellOpps = new Set<Id>();
            for(Opportunity opp: oppsList){
                if(opp.co_sell_opportunity__c != null) {
                    partnerCoSellOppsMap.put(opp.Id, opp);
                    internalCoSellOpps.add(opp.co_sell_opportunity__c);
                    continue;
                }
                Partner_Commission__c newPartnerCommission = pcService.createPartnerCommissionRecord(accountsMap.get(opp.AccountId), accountsMap.get(opp.Channel_Partner__c), opp, createReason);
                if(isRunningFromScript) newPartnerCommission.Trigger_Valid_From__c = opp.CloseDate.toStartOfMonth();
                newPartnerCommissionList.add(newPartnerCommission);
            }
            if(!partnerCoSellOppsMap.isEmpty()) {
                createReason += ' - Co Sell';
                handleCosellOpps(partnerCoSellOppsMap, internalCoSellOpps, newPartnerCommissionList, accountsMap, pcService);
            }
            pcService.upsertPartnerCommissionInQueue(newPartnerCommissionList, CLASS_NAME_CONST);
        } catch (Exception ex){
            pcService.sendErrorEmail(CLASS_NAME_CONST, ex.getMessage());
            throw ex;
        }
    }

    private Map<Id, Account> getAccountsMap(List<Opportunity> oppsList){
        Set<Id> accountIds = new Set<Id>();
        Map<String, Schema.RecordTypeInfo> accountRecordTypesMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        Id partnerRecordTypeId = accountRecordTypesMap.get('Partner_Company').getRecordTypeId();
        Id mondayRecordTypeId = accountRecordTypesMap.get('Monday_Account').getRecordTypeId();

        for(Opportunity opp: oppsList){
            accountIds.add(opp.Channel_Partner__c);
            accountIds.add(opp.AccountId);
        }
        return new Map<Id, Account>([select Id, ARR__c, Name, Partner_Tier__c, Sign_Up_Date__c, Last_ARR_Update_Timestamp__c, Account_Source_Type__c, Partner_Type__c, primary_pulse_account_id__c, Partner_Commission_Model__c, Partner_Commission_Model__r.Commission_Model__r.Commission_Type__c, Partner_Commission_Model__r.Commission_Model__r.Period__c, Partner_Commission_Model__r.Commission_Model__r.Outbound_Percent__c, Partner_Commission_Model__r.Commission_Model__r.Inbound_Percent__c from Account where Id IN: accountIds and (RecordTypeId =: mondayRecordTypeId or (RecordTypeId =: partnerRecordTypeId and Partner_Commission_Model__c != null))]);
    }

    private void handleCosellOpps(Map<Id,Opportunity> partnerCoSellOppsMap, Set<Id> internalCoSellOpps, List<Partner_Commission__c> newPartnerCommissionList, Map<Id, Account> accountsMap, PartnerCommissionService pcService){
        Map<Id, List<Subscription__c>> oppIdToSubsMap = new Map<Id, List<Subscription__c>>();
        for(Subscription__c sub: [select Id, Activation_Date__c, Claimed_On_Opportunity__c, Claimed_On_Opportunity_Co_Sell__c from Subscription__c where Claimed_On_Opportunity__c IN: partnerCoSellOppsMap.keySet() or Claimed_On_Opportunity_Co_Sell__c IN: partnerCoSellOppsMap.keySet() order by Activation_Date__c ASC]){
            if(sub.Claimed_On_Opportunity__c != null){
                if(oppIdToSubsMap.containsKey(sub.Claimed_On_Opportunity__c)){
                    oppIdToSubsMap.get(sub.Claimed_On_Opportunity__c).add(sub);
                } else {
                    oppIdToSubsMap.put(sub.Claimed_On_Opportunity__c, new List<Subscription__c>{sub});
                }
            }
            if(sub.Claimed_On_Opportunity_Co_Sell__c != null){
                if(oppIdToSubsMap.containsKey(sub.Claimed_On_Opportunity_Co_Sell__c)){
                    oppIdToSubsMap.get(sub.Claimed_On_Opportunity_Co_Sell__c).add(sub);
                } else {
                    oppIdToSubsMap.put(sub.Claimed_On_Opportunity_Co_Sell__c, new List<Subscription__c>{sub});
                }
            }
        }
        Map<Id, Quote> oppIdToQuoteMap = new Map<Id, Quote>();
        for(Quote quote: [select Id, OpportunityId, Contract.StartDate from Quote where (OpportunityId IN: partnerCoSellOppsMap.keySet() or OpportunityId IN: internalCoSellOpps) and IsSyncing = true and DH_Quote_Status__c = 'Won']){
            oppIdToQuoteMap.put(quote.OpportunityId, quote);
        }
        Date startDateForCoSell;
        for(Opportunity opp: partnerCoSellOppsMap.values()){
            startDateForCoSell = null;
            if(oppIdToSubsMap.containsKey(opp.Id)){ //check if sub exists
                startDateForCoSell = oppIdToSubsMap.get(opp.Id).get(0).Activation_Date__c;
            } else if(oppIdToQuoteMap.containsKey(opp.Id)){
                startDateForCoSell = oppIdToQuoteMap.get(opp.Id).Contract.StartDate;
            } else if(oppIdToQuoteMap.containsKey(opp.co_sell_opportunity__c)){
                startDateForCoSell = oppIdToQuoteMap.get(opp.co_sell_opportunity__c).Contract.StartDate;
            }
            if(startDateForCoSell != null){ //create PCs for co-sell opps
                Partner_Commission__c newPartnerCommission = pcService.createPartnerCommissionRecord(accountsMap.get(opp.AccountId), accountsMap.get(opp.Channel_Partner__c), opp, createReason);
                newPartnerCommission.Start_Date__c = startDateForCoSell;
                if(isRunningFromScript) newPartnerCommission.Trigger_Valid_From__c = opp.CloseDate.toStartOfMonth();
                newPartnerCommissionList.add(newPartnerCommission);
            }
        }
    }
}