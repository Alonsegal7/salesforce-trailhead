public class PartnerCommission_CreateFromOpp_Queue implements System.Queueable {
    private List<Opportunity> oppsList;  
    public Boolean isRunningFromScript = false;
    private String createReason = 'GB Opp Closed';
    private static final String CLASS_NAME_CONST = 'PartnerCommission_CreateFromOpp_Queue';

    public PartnerCommission_CreateFromOpp_Queue() {
    }

    public PartnerCommission_CreateFromOpp_Queue(List<Opportunity> oppsList) {
        this.oppsList = oppsList;
    }
    
    public void execute(System.QueueableContext ctx) {
        createPcs(oppsList);
    }

    public void createPcs(List<Opportunity> opps){
        //move logic to func and call synchroniously in case you are in batch
        PartnerCommissionService pcService = new PartnerCommissionService();
        try {
            List<Partner_Commission__c> newPcList = new List<Partner_Commission__c>();
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity opp: opps){
                accountIds.add(opp.Channel_Partner__c);
                accountIds.add(opp.AccountId);
            }
            Map<Id, Account> accountsMap = pcService.getAccountsMap(accountIds);
            if(accountsMap.isEmpty()) return;
            if(isRunningFromScript) createReason = 'Fix opps with missing PC';
            Map<Id,Opportunity> partnerCoSellOppsMap = new Map<Id,Opportunity>();
            Set<Id> internalCoSellOpps = new Set<Id>();
            for(Opportunity opp: opps){
                if(opp.co_sell_opportunity__c != null) {
                    partnerCoSellOppsMap.put(opp.Id, opp);
                    internalCoSellOpps.add(opp.co_sell_opportunity__c);
                    continue;
                }
                if(!accountsMap.containsKey(opp.AccountId) || !accountsMap.containsKey(opp.Channel_Partner__c)) continue;
                Partner_Commission__c newPc = pcService.createNewPc(accountsMap.get(opp.AccountId), accountsMap.get(opp.Channel_Partner__c), opp, createReason);
                if(isRunningFromScript) newPc.Trigger_Valid_From__c = opp.CloseDate.toStartOfMonth();
                newPcList.add(newPc);
            }
            if(!partnerCoSellOppsMap.isEmpty()) {
                createReason += ' - Co Sell';
                handleCosellOpps(partnerCoSellOppsMap, internalCoSellOpps, newPcList, accountsMap, pcService);
            }
            pcService.upsertPartnerCommissionInQueue(newPcList, CLASS_NAME_CONST);
        } catch (Exception ex){
            pcService.sendErrorEmail(CLASS_NAME_CONST, ex.getMessage());
            throw ex;
        }
    }

    private void handleCosellOpps(Map<Id,Opportunity> partnerCoSellOppsMap, Set<Id> internalCoSellOpps, List<Partner_Commission__c> newPcList, Map<Id, Account> accountsMap, PartnerCommissionService pcService){
        Map<Id, Subscription__c> oppIdToSubsMap = new Map<Id, Subscription__c>();
        for(Subscription__c sub: [select Id, Activation_Date__c, Claimed_On_Opportunity__c, Claimed_On_Opportunity_Co_Sell__c from Subscription__c where Claimed_On_Opportunity__c IN: partnerCoSellOppsMap.keySet() or Claimed_On_Opportunity_Co_Sell__c IN: partnerCoSellOppsMap.keySet() order by Activation_Date__c ASC]){
            //build a map of opp id and claimed subs sorted by activation date DESC
            if(sub.Claimed_On_Opportunity__c != null && !oppIdToSubsMap.containsKey(sub.Claimed_On_Opportunity__c)){
                oppIdToSubsMap.put(sub.Claimed_On_Opportunity__c, sub);
            }
            if(sub.Claimed_On_Opportunity_Co_Sell__c != null && !oppIdToSubsMap.containsKey(sub.Claimed_On_Opportunity_Co_Sell__c)){
                oppIdToSubsMap.put(sub.Claimed_On_Opportunity_Co_Sell__c, sub);
            }
        }
        Map<Id, Quote> oppIdToQuoteMap = new Map<Id, Quote>();
        for(Quote quote: [select Id, OpportunityId, Subscription_Start_date__c from Quote where (OpportunityId IN: partnerCoSellOppsMap.keySet() or OpportunityId IN: internalCoSellOpps) and IsSyncing = true and DH_Quote_Status__c = 'Won']){
            oppIdToQuoteMap.put(quote.OpportunityId, quote);
        }
        Date startDateForCoSell;
        Id subId, quoteId;
        for(Opportunity opp: partnerCoSellOppsMap.values()){
            startDateForCoSell = null;
            subId = null;
	        quoteId = null;
            if(oppIdToSubsMap.containsKey(opp.Id)){ //check if claimed sub exists -> take the activation date
                startDateForCoSell = oppIdToSubsMap.get(opp.Id).Activation_Date__c;
                subId = oppIdToSubsMap.get(opp.Id).Id;
            } else if(oppIdToQuoteMap.containsKey(opp.Id)){ //else check for quote
                startDateForCoSell = oppIdToQuoteMap.get(opp.Id).Subscription_Start_date__c;
                quoteId = oppIdToQuoteMap.get(opp.Id).Id;
            } else if(oppIdToQuoteMap.containsKey(opp.co_sell_opportunity__c)){
                startDateForCoSell = oppIdToQuoteMap.get(opp.co_sell_opportunity__c).Subscription_Start_date__c;
                quoteId = oppIdToQuoteMap.get(opp.co_sell_opportunity__c).Id;
            }
            if(startDateForCoSell != null && accountsMap.containsKey(opp.AccountId) && accountsMap.containsKey(opp.Channel_Partner__c)){ //create PCs for co-sell opps
                Partner_Commission__c newPc = pcService.createNewPc(accountsMap.get(opp.AccountId), accountsMap.get(opp.Channel_Partner__c), opp, createReason);
                newPc.Start_Date__c = startDateForCoSell;
                newPc.subscription_for_start_date__c = subId;
                newPc.quote_for_start_date__c = quoteId;
                if(isRunningFromScript) newPc.Trigger_Valid_From__c = opp.CloseDate.toStartOfMonth();
                newPcList.add(newPc);
            }
        }
    }
}