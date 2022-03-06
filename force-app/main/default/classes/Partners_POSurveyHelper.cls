public without sharing class Partners_POSurveyHelper {

    private string debugString = '';
    private Map<Id,Opportunity> scope;
    private Boolean dryRun = false;

    public Partners_POSurveyHelper(List<Opportunity> opps, Boolean dryRun){
        this.scope = new Map<Id,Opportunity>(opps);
        this.dryRun = dryRun;
    }

    public static string baseQuery(){
        String query = 'select Id, Name, AccountId, Account.Name, Expected_Plan_Period__c, Expected_Plan_Tier__c, Expected_Plan_Seats__c, CloseDate, Account.Next_PO_Survey_Date__c';
        query += ' from Opportunity';
        query += ' where Expected_Plan_Period__c != \'Monthly\'';
        query += ' and Expected_Plan_Tier__c = \'Enterprise\'';
        query += ' and Account.Low_Touch_CS__c = null';
        query += ' and StageName = \'Closed Won\'';
        query += ' and Expected_Plan_Seats__c >= 20';
        query += ' and Account.CSM__c = null';
        query += ' and RecordType.DeveloperName = \'Partner_Opportunity\'';
        query += ' and Account.Plan_Period__c != \'Monthly\'';
        query += ' and CloseDate >= LAST_N_DAYS:90';
        query += ' and (Account.Next_PO_Survey_Date__c = null or Account.Next_PO_Survey_Date__c < TODAY)'; //exclude opp with account that is already expected to get a survey
        return query;
    }

    public string checkSurveyConditions(Set<Id> res){
        debugString += '<br/><b>new scope</b>';
        debugOppsPassEntry();
        debugString += '<br/><br/> Checking survey conditions per account:';
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp: scope.values()){
            accountIds.add(opp.AccountId);
        }
        List<Account> accountsToExamine = [select Id, 
                                                Name, 
                                                (select Id, 
                                                        Name, 
                                                        CloseDate, 
                                                        Expected_Plan_Tier__c, 
                                                        Expected_Plan_Seats__c, 
                                                        RecordType.DeveloperName 
                                                    from Opportunities 
                                                    where StageName = 'Closed Won' 
                                                    and Expected_Plan_Tier__c = 'Enterprise' 
                                                    order by CloseDate ASC) 
                                            from Account 
                                            where Id IN: accountIds];
        Opportunity currOpp, prevOpp, prev2Opp;
        List<Account> accountsToUpdate = new List<Account>();
        for(Account acc: accountsToExamine){
            currOpp = null;
            prevOpp = null;
            prev2Opp = null;
            debugString += '<br/><br/> account: <a href="https://monday.lightning.force.com/lightning/r/Account/'+acc.Id+'/view">'+acc.Name+'</a>';
            if(acc.Opportunities.size() == 1){ //no prev opp - new business - always send survey
                currOpp = acc.Opportunities[0];
                addAccountForUpdate(accountsToUpdate, currOpp, acc.Id);
                debugString += '<br/> Result: account has one opp only - good for survey!';
                continue;
            }
            //start from oldest opp looking for opps that participate in scope list
            //once found - check prev & prevprev opps for delta seats/co-sell
            for(Integer i=0;i<acc.Opportunities.size();i++){
                currOpp = acc.Opportunities[i];
                if(!scope.containsKey(currOpp.Id)) continue; //if opp is not part of the entry criteria opps - continue.
                //prev opp
                if(i>0) {
                    prevOpp = acc.Opportunities[i-1];
                } else {
                    addAccountForUpdate(accountsToUpdate, currOpp, acc.Id);
                    debugString += '<br/> Result: account has no relevant prev opps for comparison - good for survey!';
                    break;
                }
                //prevprev opp
                if(i>1) prev2Opp = acc.Opportunities[i-2];
                //compare to prev opps
                if(comparePrevOpps(currOpp, prevOpp, prev2Opp)){
                    addAccountForUpdate(accountsToUpdate, currOpp, acc.Id);
                    break;
                }
            }
        }
        system.debug('accountsToUpdate: ' + accountsToUpdate);
        if(accountsToUpdate.isEmpty()) {
            debugString += '<br/> <b>NO MATCHING ACCOUNTS LEFT. exiting...</b>';
        } else if(!dryRun){ 
            Database.update(accountsToUpdate);
            Map<Id,Account> accMap = new Map<Id,Account>(accountsToUpdate);
            res.addAll(accMap.keySet());
        }
        return debugString;
    }

    private void addAccountForUpdate(List<Account> accountsToUpdate, Opportunity currOpp, Id accId){
        accountsToUpdate.add(new Account(
            Id = accId,
            Last_PO_Survey_Opportunity__c = String.valueOf(currOpp.Id),
            Next_PO_Survey_Date__c = currOpp.CloseDate.addDays(90)
        ));
    }

    private void debugOppsPassEntry(){
        debugString += '<br/> opportunities that passed entry condition:';
        for(Opportunity opp: scope.values()){
            debugString += '<br/><a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view">'+opp.Name+'</a>';
        }
    }

    private Boolean comparePrevOpps(Opportunity currentOpp, Opportunity prevOpp, Opportunity prev2Opp){
        Boolean res = true;
        debugString += '<br/>Prev opps comparison results: ';
        //compare last opp vs prev opp (if exists) to decide if need to send survey to this account, if not remove the account key value pair from map A
        Decimal deltaSeats = currentOpp.Expected_Plan_Seats__c - prevOpp.Expected_Plan_Seats__c;
        debugString += '<br/>current opp: <a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+currentOpp.Id+'/view">'+currentOpp.Name+'</a>';
        debugString += '<br/>prev opp: <a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+prevOpp.Id+'/view">'+prevOpp.Name+'</a>';
        debugString += '<br/>delta seats: ' + String.valueOf(deltaSeats);
        if(deltaSeats < 50){ //check if need to remove this account from survey
            if(prevOpp.RecordType.DeveloperName == 'Internal_Opportunity' && deltaSeats == 0){ // potentially co-sell, need to check prev prev opp (if exists)
                debugString += '<br/>potentially co-sell. checking prev prev opp.';
                if(prev2Opp != null){ //check if there is another opp before the co-sell opp
                    deltaSeats = currentOpp.Expected_Plan_Seats__c - prev2Opp.Expected_Plan_Seats__c;
                    debugString += '<br/>prev opp: <a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+prev2Opp.Id+'/view">'+prev2Opp.Name+'</a>';
                    debugString += '<br/>delta seats: ' + String.valueOf(deltaSeats);
                    if(deltaSeats < 50){ //
                        res = false;
                        debugString += '<br/>Result: <b>REMOVED ACCOUNT</b>: found prev prev opp causing delta seats to be less than 50';
                    } else {
                        debugString += '<br/>Result: current opp and prev prev opp match conditions.';
                    }
                } else {
                    debugString += '<br/>Result: current opp and prev opp match conditions (prev opp is co-sell and no prev prev opp found).';
                }
            } else {
                res = false;
                debugString += '<br/> Result: <b>REMOVED ACCOUNT</b>: found prev opp causing delta seats to be less than 50';
            }
        } else {
            debugString += '<br/>Result: current opp and prev opp match conditions (delta seats is greater or equal to 50).';
        }
        return res;
    }
}