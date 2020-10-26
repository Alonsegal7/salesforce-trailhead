public without sharing class ContractService {

    public static void handleQuoteFinalized(Quote quote){
        try{
            Opportunity opportunity = [SELECT Id, AccountId FROM Opportunity WHERE Id = :quote.OpportunityId];
            Account mondayAccount = [SELECT Id, Name, Active_Contract__c, Company__c FROM Account WHERE Id = :opportunity.AccountId];
            QuoteLineItem quoteLicenseLine = [SELECT Id, Tier__c, ListPrice, UnitPrice, Discount, ServiceDate,Quantity,End_Date__c FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Product_Type__c = 'License' limit 1];
            List<OpportunityLineItem> opportunityLines = [SELECT Id, Contract__c FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id for update];
            if(quote.ContractId != null) 
                deactivateContract(quote.ContractId); 
            system.debug('Raz Ben Ron quote.Quote_Type__c: '+quote.Quote_Type__c);
            if(quote.Quote_Type__c =='Pro-rated- Additional Seats'&&!quote.Pro_Rated_Different_Price__c){ //prorated without change of tier
                quote.ContractId=quote.Get_Contract_Id__c;
                system.debug('Raz Ben Ron should connect to get id:' );
            } else if(quote.Quote_Type__c == 'New Contract'||quote.Quote_Type__c == 'Change Tier in the same term'||quote.Pro_Rated_Different_Price__c) {
                Id contractId = createContract(mondayAccount, quote, quoteLicenseLine);
                quote.ContractId = contractId;
                mondayAccount.Active_Contract__c = contractId;
                Database.update(mondayAccount);
            }
            opportunity.ContractId = quote.ContractId;
            //updating the opp in future method, because the action is entiated from the opportunity and eventually updated the opportunity.
            updateOppOnFuture(Json.serialize(opportunity));

            if (!opportunityLines.isEmpty()) {
                for (OpportunityLineItem product: opportunityLines) product.Contract__c = quote.ContractId;
                update opportunityLines;
            }
            system.debug('Raz Ben Ron quote.ContractId: '+quote.ContractId);
            calculateContractSeats(quote.ContractId);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in handleQuoteFinalized ',e,e.getMessage()+quote.id);   
        }
    }
    
   public static void calculateContractSeats(Id contractId) {
        AggregateResult[] groupedResults = [SELECT SUM(Seats__c)sum FROM OpportunityLineItem WHERE Contract__c  = :contractId AND Product_Type__c = 'License'];
		decimal sumAmount = (decimal)groupedResults[0].get('sum');
		Contract contract = [SELECT Id, Seats__c FROM Contract WHERE Id = :contractId for update];
        contract.Seats__c = sumAmount;
        update contract;
    }
    
    private static void deactivateContract(Id contractId) {
        Contract contract = [SELECT Id, Status__c FROM Contract WHERE Id = :contractId];
        contract.Status__c = 'Deactivated';
        update contract;
    }
    
    private static Id createContract(Account mondayAccount, Quote quote, QuoteLineItem quoteLicenseLine){
        Contract contract = new Contract(
            Name = mondayAccount.Name + ' - ' + quoteLicenseLine.Tier__c + ' - ' + quoteLicenseLine.Quantity,
        	AccountId = mondayAccount.Company__c,
            Tier__c = quoteLicenseLine.Tier__c,
            ContractTerm = quote.Duration__c.intValue()>0?quote.Duration__c.intValue():1,
            CurrencyIsoCode = quote.CurrencyIsoCode,
            List_Price__c = quoteLicenseLine.ListPrice,
            Unit_Price__c = quoteLicenseLine.UnitPrice,
            Discount__c = quoteLicenseLine.Discount,
            StartDate = quoteLicenseLine.ServiceDate,
            EndDate = quoteLicenseLine.End_Date__c,
            Source__c='DealHub',
            Status__c='ACTIVE',
            Period__c=quote.DH_Period__c,
            Seats__c = 0
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