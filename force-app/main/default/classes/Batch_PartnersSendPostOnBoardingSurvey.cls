public class Batch_PartnersSendPostOnBoardingSurvey implements Database.Batchable<sObject>,Schedulable{

    public Date threeMonthsAgo = Date.today().addDays(-90);

    public Batch_PartnersSendPostOnBoardingSurvey(){
    }

    public Batch_PartnersSendPostOnBoardingSurvey(Date selectedDate){
        this.threeMonthsAgo = selectedDate;
    }

    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this, 30);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_PartnersSendPostOnBoardingSurvey ', e, e.getMessage());   
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select Id, AccountId, Expected_Plan_Period__c, Expected_Plan_Tier__c, Expected_Plan_Seats__c from Opportunity where Expected_Plan_Period__c != \'Monthly\' and Expected_Plan_Tier__c = \'Enterprise\' and Account.Low_Touch_CS__c = null and StageName = \'Closed Won\' and Expected_Plan_Seats__c >= 20 and Account.CSM__c = null and RecordType.DeveloperName = \'Partner_Opportunity\' and CloseDate =: threeMonthsAgo and Account.Plan_Period__c != \'Monthly\'';
        return Database.getQueryLocator(query);
     }

    public void execute(Database.BatchableContext BC, list<Opportunity> scope){
        //run over the opps and save each opp to the map A of accountid to opp list
        Map<Id,List<Opportunity>> accountIdToOppMap = new Map<Id,List<Opportunity>>();
        Set<Id> oppsIds = new Set<Id>();
        for(Opportunity opp : scope){
            accountIdToOppMap.put(opp.AccountId, new List<Opportunity>{opp});
            oppsIds.add(opp.Id);
        }

        //query all prev opps per account and save to map A of accountid to opp list
        for(Account acc: [select Id, (select Id, Expected_Plan_Tier__c, Expected_Plan_Seats__c, RecordType.DeveloperName from Opportunities where Id not in: oppsIds and Co_Sell_Opportunity__c not in: oppsIds and StageName = 'Closed Won' and Expected_Plan_Tier__c = 'Enterprise' and CloseDate <=: threeMonthsAgo order by CloseDate DESC limit 2) from Account where Id IN: accountIdToOppMap.keySet()]){
            if(acc.Opportunities.isEmpty()) continue;
            accountIdToOppMap.get(acc.Id).add(acc.Opportunities.get(0));
        }
        
        //compare last opp vs prev opp (if exists) to decide if need to send survey to this account, if not remove the account key value pair from map A
        for(Id accountId: accountIdToOppMap.keySet()){
            if(accountIdToOppMap.get(accountId).size() == 1) continue; //if no prev opp - new business - always send survey
            Opportunity currentOpp = accountIdToOppMap.get(accountId).get(0);
            Opportunity prevOpp =  accountIdToOppMap.get(accountId).get(1);
            Decimal deltaSeats = currentOpp.Expected_Plan_Seats__c - prevOpp.Expected_Plan_Seats__c;
            if(deltaSeats < 100){ //check if need to remove this account from survey
                if(prevOpp.RecordType.DeveloperName == 'Internal_Opportunity' && deltaSeats == 0){ // potentially co-sell, need to check prev prev opp (if exists)
                    if(accountIdToOppMap.get(accountId).size() == 3){ //check if there is another opp before the co-sell opp
                        prevOpp = accountIdToOppMap.get(accountId).get(2);
                        deltaSeats = currentOpp.Expected_Plan_Seats__c - prevOpp.Expected_Plan_Seats__c;
                        if(deltaSeats < 100){
                            accountIdToOppMap.remove(accountId);
                        }
                    }
                } else {
                    accountIdToOppMap.remove(accountId);
                }
            }
        }

        //query contacts related to accounts of map A and put them to map C of contact id to account id
        List<Contact> contactsList = [select Id, AccountId, Last_Opportunity_For_Survey__c, Of_Post_Onboarding_Surveys__c from Contact where AccountId IN: accountIdToOppMap.keySet()];
        List<Contact> contactsToUpdate = new List<Contact>();
        
        //for all of them check if account last opp id from map A is different from contact.Last_Opportunity_For_Survey__c if yes increase Of_Post_Onboarding_Surveys__c by 1
        for(Contact con: contactsList){
            String idOfCurrentOpp = String.valueOf(accountIdToOppMap.get(con.AccountId).get(0).Id);
            if(con.Last_Opportunity_For_Survey__c != idOfCurrentOpp) {
                Decimal numOfSurveys = con.Of_Post_Onboarding_Surveys__c;
                contactsToUpdate.add(new Contact(Id = con.Id, Partners_Post_Onboarding_Survey_Date__c = Date.today(), Last_Opportunity_For_Survey__c = idOfCurrentOpp, Of_Post_Onboarding_Surveys__c = numOfSurveys + 1));
            }
        }
        if(!contactsToUpdate.isEmpty()) Database.update(contactsToUpdate);
    }
    
    public void finish(Database.BatchableContext BC){
    }
}