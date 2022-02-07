public class Batch_PartnersSendPostOnBoardingSurvey implements Database.Batchable<sObject>,Schedulable,Database.Stateful{

    private List<String> emailRecepients = new List<String>{'kseniasm@monday.com','avivc@monday.com'};
    private Date targetDate = Date.today().addDays(-90);
    private map<Id,list<string>> res = new map<Id,list<string>>();
    private integer totalCons = 0;
    private string debugString = '';
    private Boolean dryRun = false;

    public Batch_PartnersSendPostOnBoardingSurvey(){
    }

    public Batch_PartnersSendPostOnBoardingSurvey(Date selectedDate){
        this.targetDate = selectedDate;
    }

    public Batch_PartnersSendPostOnBoardingSurvey(Boolean isDryRun, Date selectedDate){
        //dry run only counts how many accounts match the survey conditions since the selected date
        this.dryRun = isDryRun;
        this.targetDate = selectedDate;
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
        //get all opportunities with 
        //Expected_Plan_Period__c not Monthly and 
        //Expected_Plan_Tier__c is Enterprise and
        //Account.Low_Touch_CS__c = null and 
        //StageName = Closed Won and 
        //Expected_Plan_Seats__c >= 20 and 
        //Account.CSM__c = null and 
        //RecordType.DeveloperName = Partner_Opportunity and 
        //CloseDate is 90 days ago and 
        //Account.Plan_Period__c != Monthly
        try{
            String query = 'select Id, Name, AccountId, Account.Name, Expected_Plan_Period__c, Expected_Plan_Tier__c, Expected_Plan_Seats__c from Opportunity where Expected_Plan_Period__c != \'Monthly\' and Expected_Plan_Tier__c = \'Enterprise\' and Account.Low_Touch_CS__c = null and StageName = \'Closed Won\' and Expected_Plan_Seats__c >= 20 and Account.CSM__c = null and RecordType.DeveloperName = \'Partner_Opportunity\' and Account.Plan_Period__c != \'Monthly\'';
            if(dryRun){
                query += ' and CloseDate >=: targetDate and CloseDate < LAST_N_DAYS:90';
            }else {
                query += ' and CloseDate =: targetDate';
            }
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnersSendPostOnBoardingSurvey start: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Opportunity> scope){
        try{
            System.debug('Batch_PartnersSendPostOnBoardingSurvey scope: ' + scope);
            System.debug('Batch_PartnersSendPostOnBoardingSurvey targetDate: ' + targetDate);
            if(!dryRun) debugString += '<br/> opportunities that passed entry condition:';
            //run over the opps and save each opp to the map A of accountid to opp list
            Map<Id,List<Opportunity>> accountIdToOppMap = new Map<Id,List<Opportunity>>();
            Set<Id> oppsIds = new Set<Id>();
            for(Opportunity opp : scope){
                accountIdToOppMap.put(opp.AccountId, new List<Opportunity>{opp});
                oppsIds.add(opp.Id);
                if(!dryRun) debugString += '<br/><a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view">'+opp.Name+'</a>';
            }
            System.debug('Batch_PartnersSendPostOnBoardingSurvey accountIdToOppMap: ' + accountIdToOppMap);
            System.debug('Batch_PartnersSendPostOnBoardingSurvey oppsIds: ' + oppsIds);

            // query per account the other 2 prev opps (if existing)
            // co-sell is excluded
            // with StageName = 'Closed Won' and 
            // Expected_Plan_Tier__c = 'Enterprise'
            // and save to map A of accountid to opp list
            Date dateForPrevOpps;
            if(dryRun) dateForPrevOpps = Date.today().addDays(-90);
            else dateForPrevOpps = targetDate;
            Map<Id,Account> accountsMap = new Map<Id,Account>([select Id, Name, (select Id, Name, CloseDate, Expected_Plan_Tier__c, Expected_Plan_Seats__c, RecordType.DeveloperName from Opportunities where Id not in: oppsIds and Co_Sell_Opportunity__c not in: oppsIds and StageName = 'Closed Won' and Expected_Plan_Tier__c = 'Enterprise' and CloseDate <=: dateForPrevOpps order by CloseDate DESC limit 2) from Account where Id IN: accountIdToOppMap.keySet()]);
            for(Account acc: accountsMap.values()){
                System.debug('Batch_PartnersSendPostOnBoardingSurvey accId: ' + acc.Id);
                System.debug('Batch_PartnersSendPostOnBoardingSurvey acc.Opportunities: ' + acc.Opportunities);
                if(!acc.Opportunities.isEmpty()) {
                    if(dryRun){
                        Opportunity currentOpp = accountIdToOppMap.get(acc.Id).get(0);
                        for(Opportunity prevOpp: acc.Opportunities){
                            if(prevOpp.CloseDate <= currentOpp.CloseDate){
                                accountIdToOppMap.get(acc.Id).add(prevOpp);
                            }
                        }
                    } else {
                        accountIdToOppMap.get(acc.Id).addAll(acc.Opportunities);
                    }
                }
            }
            System.debug('Batch_PartnersSendPostOnBoardingSurvey accountIdToOppMap: ' + accountIdToOppMap);

            if(!dryRun) debugString += '<br/><br/> Prev opps comparison results: ';
            //compare last opp vs prev opp (if exists) to decide if need to send survey to this account, if not remove the account key value pair from map A
            for(Id accountId: accountIdToOppMap.keySet()){
                if(!dryRun) debugString += '<br/> account: <a href="https://monday.lightning.force.com/lightning/r/Account/'+accountId+'/view">'+accountsMap.get(accountId).Name+'</a>';
                if(accountIdToOppMap.get(accountId).size() == 1) {
                    if(!dryRun) debugString += '<br/> Result: account has no relevant prev opps for comparison.';
                    continue; //if no prev opp - new business - always send survey
                }
                Opportunity currentOpp = accountIdToOppMap.get(accountId).get(0);
                Opportunity prevOpp =  accountIdToOppMap.get(accountId).get(1);
                Decimal deltaSeats = currentOpp.Expected_Plan_Seats__c - prevOpp.Expected_Plan_Seats__c;
                if(!dryRun) debugString += '<br/>current opp: <a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+currentOpp.Id+'/view">'+currentOpp.Name+'</a>';
                if(!dryRun) debugString += '<br/>prev opp: <a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+prevOpp.Id+'/view">'+prevOpp.Name+'</a>';
                if(!dryRun) debugString += '<br/>delta seats: ' + String.valueOf(deltaSeats);
                if(deltaSeats < 100){ //check if need to remove this account from survey
                    if(prevOpp.RecordType.DeveloperName == 'Internal_Opportunity' && deltaSeats == 0){ // potentially co-sell, need to check prev prev opp (if exists)
                        if(!dryRun) debugString += '<br/>potentially co-sell. checking prev prev opp.';
                        if(accountIdToOppMap.get(accountId).size() == 3){ //check if there is another opp before the co-sell opp
                            prevOpp = accountIdToOppMap.get(accountId).get(2);
                            deltaSeats = currentOpp.Expected_Plan_Seats__c - prevOpp.Expected_Plan_Seats__c;
                            if(!dryRun) debugString += '<br/>prev opp: <a href="https://monday.lightning.force.com/lightning/r/Opportunity/'+prevOpp.Id+'/view">'+prevOpp.Name+'</a>';
                            if(!dryRun) debugString += '<br/>delta seats: ' + String.valueOf(deltaSeats);
                            if(deltaSeats < 100){ //
                                accountIdToOppMap.remove(accountId);
                                System.debug('Batch_PartnersSendPostOnBoardingSurvey remove account: ' + accountId);
                                if(!dryRun) debugString += '<br/>Result: <b>REMOVED ACCOUNT</b>: found prev prev opp causing delta seats to be less than 100';
                            } else {
                                if(!dryRun) debugString += '<br/>Result: current opp and prev prev opp match conditions.';
                            }
                        } else {
                            if(!dryRun) debugString += '<br/>Result: current opp and prev opp match conditions (prev opp is co-sell and no prev prev opp found).';
                        }
                    } else {
                        accountIdToOppMap.remove(accountId);
                        System.debug('Batch_PartnersSendPostOnBoardingSurvey remove account: ' + accountId);
                        if(!dryRun) debugString += '<br/> Result: <b>REMOVED ACCOUNT</b>: found prev opp causing delta seats to be less than 100';
                    }
                } else {
                    if(!dryRun) debugString += '<br/>Result: current opp and prev opp match conditions (delta seats is greater or equal to 100).';
                }
            }
            if(accountIdToOppMap.isEmpty()) {
                System.debug('Batch_PartnersSendPostOnBoardingSurvey no matching accounts. exiting...');
                if(!dryRun) debugString += '<br/> <b>NO MATCHING ACCOUNTS LEFT. exiting...</b>';
                return;
            }
            System.debug('Batch_PartnersSendPostOnBoardingSurvey matching accounts: ' + accountIdToOppMap.keySet());
            //query contacts related to accounts of map A and put them to map C of contact id to account id
            
            List<Contact> contactsList = [select Id, Name, AccountId, Account.Name, Last_Opportunity_For_Survey__c, Of_Post_Onboarding_Surveys__c from Contact where AccountId IN: accountIdToOppMap.keySet()];
            List<Contact> contactsToUpdate = new List<Contact>();

            System.debug('Batch_PartnersSendPostOnBoardingSurvey contactsList: ' + contactsList);
            if(!dryRun) debugString += '<br/><br/> Searching contacts for accounts:';
            if(!contactsList.isEmpty()) {
                if(!dryRun) debugString += '<br/>Processing contacts...';
            } else {
                if(!dryRun) debugString += '<br/>no contacts found.';
                return;
            }

            //for all of them check if account last opp id from map A is different from contact.Last_Opportunity_For_Survey__c if yes increase Of_Post_Onboarding_Surveys__c by 1
            for(Contact con: contactsList){
                String idOfCurrentOpp = String.valueOf(accountIdToOppMap.get(con.AccountId).get(0).Id);
                if(con.Last_Opportunity_For_Survey__c != idOfCurrentOpp) {
                    Decimal numOfSurveys = con.Of_Post_Onboarding_Surveys__c;
                    contactsToUpdate.add(new Contact(Id = con.Id, Partners_Post_Onboarding_Survey_Date__c = Date.today(), Last_Opportunity_For_Survey__c = idOfCurrentOpp, Of_Post_Onboarding_Surveys__c = numOfSurveys + 1));
                    if(res.containsKey(con.AccountId)) res.get(con.AccountId).add(con.Name);
                    else res.put(con.AccountId, new list<string>{con.Name});
                    if(!dryRun) debugString += '<br/><a href="https://monday.lightning.force.com/lightning/r/Contact/'+con.Id+'/view">'+con.Name+'</a> ('+con.account.name+') will recieve survey.';
                } else {
                    System.debug('Batch_PartnersSendPostOnBoardingSurvey excluded contact: ' + con.Id);
                    if(!dryRun) debugString += '<br/> <b>REMOVED CONTACT: </b> <a href="https://monday.lightning.force.com/lightning/r/Contact/'+con.Id+'/view">'+con.Name+'</a> ('+con.account.name+') - contact already recieved survey from the current opportunity';
                }
            }
            System.debug('Batch_PartnersSendPostOnBoardingSurvey contactsToUpdate: ' + contactsToUpdate);

            if(!contactsToUpdate.isEmpty()) {
                totalCons += contactsToUpdate.size();
                if(!dryRun) Database.update(contactsToUpdate);
            } else {
                if(!dryRun) debugString += '<br/> <b>NO MATCHING CONTACTS LEFT. exiting...</b>';
            }
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnersSendPostOnBoardingSurvey execute: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
        }
    }
    
    public void finish(Database.BatchableContext BC){
        String emailTitle = 'Finished Partners Survey Batch for ' + string.valueOf(targetDate) + ';';
        string emailBody = '';
        if(res.isEmpty()){
            emailTitle += ' total accounts: 0; total contacts: 0';
            emailBody += 'No surveys sent on ' + string.valueOf(targetDate) + '<br/>' + debugString;
        } else {
            emailTitle += ' total accounts: ' + res.size() + '; total contacts: '+ totalCons;
            emailBody += 'Surveys were sent on ' + string.valueOf(targetDate) + ' to ' + string.valueOf(res.size()) + ' accounts. <br/>' + debugString;
        }
        if(dryRun) emailBody = 'DRY RUN: ' + emailBody;
        Utilities.sendEmail(emailTitle, emailBody, emailRecepients); 
    }
}