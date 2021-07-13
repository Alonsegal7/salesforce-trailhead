public without sharing class ContractService {

    public static void ConditionOnContractCreation(Quote oldQuote, Quote newQuote) {
        if ((oldQuote.Is_Finalized__c == false && newQuote.Is_Finalized__c == true) || (oldQuote.Manual_Trigger__c != newQuote.Manual_Trigger__c && newQuote.Manual_Trigger__c == 'Create Active Contract')) {
             ContractService.handleQuoteFinalized(newQuote); }   
        }
    public static void handleQuoteFinalized(Quote quote){

        try{
            if (quote.ContractId == null || quote.Manual_Trigger__c == 'Create Active Contract') {       
                
                Opportunity opportunity = [SELECT Id, AccountId FROM Opportunity WHERE Id = :quote.OpportunityId];
                Account mondayAccount = [SELECT Id, Name, Active_Contract__c, Company__c FROM Account WHERE Id = :opportunity.AccountId];
                QuoteLineItem quoteLicenseLine = [SELECT Id, Tier__c, ListPrice, UnitPrice, Discount, ServiceDate,Quantity,End_Date__c,List_Price__c,Net_Per_Unit__c,Renewal_Unit_Price__c FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Product_Type__c = 'License' limit 1];
                List<OpportunityLineItem> opportunityLines = [SELECT Id, Contract__c FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id for update];
                
                //Contract creation and replacment will be only for new contracts deals
                if(quote.Manual_Trigger__c == 'Create Active Contract' && quote.ContractId != null && quote.Quote_Type__c == 'New Contract') {
                    deactivateContract(quote.ContractId); 
                }

                if(quote.Quote_Type__c =='Pro-rated- Additional Seats' && quote.Get_Contract_Id__c != null){
                    quote.ContractId=quote.Get_Contract_Id__c;
                    update new contract(id=quote.ContractId,Seats__c=quote.Total_Seats__c);
                    
                } else if(quote.Quote_Type__c == 'New Contract' || quote.Quote_Type__c == 'Change Tier in the same term' || quote.Manual_Trigger__c == 'Create Active Contract'){
                    Id contractId = createContract(mondayAccount, quote, quoteLicenseLine,quote.Manual_Trigger__c =='Create Active Contract'?'Manual Creation':'Dealhub');
                    quote.ContractId = contractId;
                    quote.Manual_Trigger__c = '';
                    mondayAccount.Active_Contract__c = contractId;
                    Database.update(mondayAccount);
                } 

                opportunity.ContractId = quote.ContractId;
                //updating the opp in future method, because the action is entiated from the opportunity and eventually updated the opportunity.
                updateOppOnFuture(Json.serialize(opportunity));

                if (!opportunityLines.isEmpty()) {
                    for (OpportunityLineItem product: opportunityLines) 
                        product.Contract__c = quote.ContractId;
                    update opportunityLines;
                }
                //calculateContractSeats(quote.ContractId);
            }
        }catch(Exception e){
                Utilities.sendDebugEmail('Error in handleQuoteFinalized ',e,e.getMessage()+quote.id);   
            }
        }
    
   /*public static void calculateContractSeats(Id contractId) {
        AggregateResult[] groupedResults = [SELECT SUM(Seats__c)sum FROM OpportunityLineItem WHERE Contract__c  = :contractId AND Product_Type__c = 'License'];
		decimal sumAmount = (decimal)groupedResults[0].get('sum');
		Contract contract = [SELECT Id, Seats__c FROM Contract WHERE Id = :contractId for update];
        contract.Seats__c = sumAmount;
        update contract;
    }
        */
    private static void deactivateContract(Id contractId) {
        Contract contract = [SELECT Id, Status__c FROM Contract WHERE Id = :contractId];
        contract.Status__c = 'Deactivated';
        update contract;
    }
    
    private static Id createContract(Account mondayAccount, Quote quote, QuoteLineItem quoteLicenseLine, string source){
        string conName=mondayAccount.Name + ' - ' + quoteLicenseLine.Tier__c + ' - ' + quoteLicenseLine.Quantity;
        Contract contract = new Contract(
            Name = conName.left(80),
        	AccountId = mondayAccount.Company__c,
            Tier__c = quoteLicenseLine.Tier__c,
            ContractTerm = quote.Duration__c.intValue()>0?quote.Duration__c.intValue():1,
            CurrencyIsoCode = quote.CurrencyIsoCode,
            List_Price__c = quoteLicenseLine.List_Price__c,
            Unit_Price__c = quoteLicenseLine.Net_Per_Unit__c,
            Discount__c = quoteLicenseLine.Discount,
            StartDate = quoteLicenseLine.ServiceDate,
            EndDate = quoteLicenseLine.End_Date__c,
            Source__c=source,
            Status__c='ACTIVE',
            Period__c=quote.DH_Period__c,
            Seats__c =quote.Total_Seats__c,
            Renewal_Unit_Price__c=quoteLicenseLine.Renewal_Unit_Price__c,
            Deal_Structure__c=quote.Deal_Structure__c,
            Rollout_Plan__c=quote.Rollout_Plan__c,
            Auto_Renewal__c=quote.Auto_Renewal__c
        );
        system.debug('Raz Ben Ron contract: '+contract);
        insert contract;
        return contract.Id;
    }
    @future
    public static void updateOppOnFuture(String oppJson){
        Opportunity opp = (Opportunity) JSON.deserialize(oppJson, Opportunity.class);
        update opp;
    }

}