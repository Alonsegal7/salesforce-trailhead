public without sharing class Subscription_ConnectToContract {
    public static void Subscription_ConnectToContract(List<Subscription__c> newSubs, map<Id, Subscription__c> oldMap) {
        map<string,Contract> contractsToCreate= new map<string,Contract>();
        map<Id,Account> accsToUpdate= new map<Id,Account>();
        try{
            set<string> subsPulseIds= new set<string>();
            if(oldMap==null)//insert
                for(Subscription__c sub: newSubs){
                    if(sub.Pulse_Account_Id__c != null) subsPulseIds.add(sub.Pulse_Account_Id__c);
                }
            else{//update
                for(Subscription__c sub: newSubs){
                    if(sub.Manual_Trigger__c!=oldMap.get(sub.id).Manual_Trigger__c&&sub.Manual_Trigger__c=='Create Active Contract' && sub.Pulse_Account_Id__c != null)
                        subsPulseIds.add(sub.Pulse_Account_Id__c);
                }
            }
            if(subsPulseIds.isEmpty())
                return;

            map<string,Account> accountsByPulseId= new map<string,Account>(); 
            for(Account acc: [select id,primary_pulse_account_id__c,Active_Contract__c,Company__c,Active_Contract__r.EndDate from Account where primary_pulse_account_id__c in: subsPulseIds]){
                if(!accountsByPulseId.containsKey(acc.primary_pulse_account_id__c))
                    accountsByPulseId.put(acc.primary_pulse_account_id__c,acc);
            }
            set<String> pulseIdsWithNewContracts= new Set<String>();
            List<Contract> contractsToUpdate= new List<Contract>();
            for(Subscription__c sub: newSubs){
                if(accountsByPulseId.containsKey(sub.Pulse_Account_Id__c)){
                    Account acc=accountsByPulseId.get(sub.Pulse_Account_Id__c);
                    sub.Monday_Account__c=acc.Id;
                    //manual contract creation from Sub
                    if(sub.Manual_Trigger__c=='Create Active Contract'){
                        contractsToCreate.put(sub.Pulse_Account_Id__c,contractDetails(sub,acc,'Manual Creation'));
                        pulseIdsWithNewContracts.add(sub.Pulse_Account_Id__c);
                        sub.Manual_Trigger__c='';
                    }else if(sub.Status__c=='ACTIVE'&&sub.Contract__c==null){//if contract is selected in BB, do not create/connect to another contract
                        if(acc.Active_Contract__c!=null&&sub.Deactivation_Date__c<=acc.Active_Contract__r.EndDate){//connect to existing active contract
                            sub.Contract__c=acc.Active_Contract__c;
                            if(sub.SO_Import_Type__c=='Pro-rated'){//for pro rated deal imported in BB, do not update prices as they are not aligned in BB
                                contractsToUpdate.add(new contract(id=sub.Contract__c, Seats__c=integer.valueof(sub.Seats__c)));
                            }else{
                                contractsToUpdate.add(new contract(id=sub.Contract__c,
                                                                    Seats__c=integer.valueof(sub.Seats__c),
                                                                    List_Price__c=sub.List_Price__c,
                                                                    Unit_Price__c=sub.Unit_Price__c,
                                                                    Discount__c=sub.Discount__c));
                            }
                        }else{//if no contract is connected to the MA, create a new contract and connect it
                            if(!contractsToCreate.containsKey(sub.Pulse_Account_Id__c)){//if multiple sub lines are sent, do not create dup contract 
                                contractsToCreate.put(sub.Pulse_Account_Id__c,contractDetails(sub,acc,'Activation'));
                            }
                            pulseIdsWithNewContracts.add(sub.Pulse_Account_Id__c);
                        }
                    }
                }
            }
            if(!contractsToUpdate.isempty()) Database.update(contractsToUpdate);
            system.debug('Raz Ben Ron SCON contractsToCreate: '+contractsToCreate);
            if(!contractsToCreate.isEmpty()){
                Database.SaveResult[] srList = Database.insert(contractsToCreate.values());
                system.debug(srList);
                integer i=0;
                map<String,Contract> conByPulseId= new map<String,Contract>();
                for (Database.SaveResult sr : srList) {
                    Contract currentContract = contractsToCreate.values()[i];
                    if (sr.isSuccess()) 
                        conByPulseId.put(currentContract.Pulse_Account_Id__c,currentContract);
                    i++;
                }
                system.debug('Raz Ben Ron pulseIdsWithNewContracts: '+pulseIdsWithNewContracts);
                for(Subscription__c sub: newSubs){
                    if(pulseIdsWithNewContracts.contains(sub.Pulse_Account_Id__c)){
                        sub.Contract__c=conByPulseId.get(sub.Pulse_Account_Id__c).Id;//connect subscription to new contract
                        Id currentAccId = accountsByPulseId.get(sub.Pulse_Account_Id__c).Id;
                        if(!accsToUpdate.containsKey(currentAccId)){//connect account to new contract
                            accsToUpdate.put(currentAccId,new Account(Id = currentAccId, Active_Contract__c = conByPulseId.get(sub.Pulse_Account_Id__c).Id));
                        }
                    }
                }
                if(!accsToUpdate.isEmpty()) Database.update(accsToUpdate.values());
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Subscription_ConnectToContract real time',e,e.getMessage()+'Cons To Create'+contractsToCreate);   
            if(e.getMessage().containsIgnoreCase('Record Currently Unavailable')){
                System.enqueueJob(new updateAccounts(accsToUpdate.values()));
            }
        }
    }

    public static Contract contractDetails(Subscription__c sub, Account acc, String source){
        contract Con=new contract(AccountId=acc.Company__c,
                                    Pulse_Account_Id__c=sub.Pulse_Account_Id__c,
                                    Tier__c=sub.Tier__c,
                                    List_Price__c=sub.List_Price__c,
                                    Unit_Price__c=sub.Unit_Price__c,
                                    Paid_Months__c=sub.Paid_Months__c,
                                    Free_Months__c=sub.Free_Months__c, 
                                    Seats__c=integer.valueof(sub.Seats__c),
                                    Discount__c=sub.Discount__c,
                                    StartDate=sub.Activation_Date__c,
                                    EndDate=sub.Deactivation_Date__c,
                                    CurrencyIsoCode=sub.CurrencyIsoCode,
                                    Name=sub.Tier__c+' - '+sub.Seats__c+' '+sub.Period__c+' - '+sub.Activation_Date__c,
                                    Pulse_Contract_Id__c=sub.Pulse_Contract_Id__c,
                                    Period__c=sub.Period__c,
                                    Pricing_Version__c=sub.Pricing_Version__c,
                                    Source__c=source,
                                    Status__c='Active'
                                    );
        return Con;
    }

    public class updateAccounts implements System.Queueable{
        private List<Account> accsToUpdate;
        public updateAccounts(List<Account> accsToUpdate) {
            this.accsToUpdate = accsToUpdate;
        }
        public void execute(System.QueueableContext ctx) {
            try{
                Database.update(accsToUpdate);
            } catch (Exception e){
                Utilities.sendDebugEmail('Error in Subscription_ConnectToContract updateAccounts queueable first attempt',e,e.getMessage());
                if(e.getMessage().containsIgnoreCase('Record Currently Unavailable')){
                    try{
                        Database.update(accsToUpdate);
                    } catch (Exception e2){
                        Utilities.sendDebugEmail('Error in Subscription_ConnectToContract updateAccounts queueable second attempt',e2,e2.getMessage());
                    }
                }
            }
        }
    }
}