public class Batch_PartnerUserTransfer_Accounts implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private Id oldOwnerId;
    private Id newOwnerId;
    private List<String> idsList = new List<String>();

    public Batch_PartnerUserTransfer_Accounts(Id oldOwnerId, Id newOwnerId) {
        this.oldOwnerId = oldOwnerId;
        this.newOwnerId = newOwnerId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            String query = 'select Id, Name, OwnerId, Partner__c from Account where OwnerId = \'' + oldOwnerId + '\' or Partner__c = \'' + oldOwnerId + '\'';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnerUserTransfer_Accounts: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'biztech@monday.com'}); 
            return null;
        }
    }

    public void execute(Database.BatchableContext BC, list<Account> scope){
        try{
            List<Account> accToUpdateList = new List<Account>();
            for(Account accountRec : scope){
                idsList.add(accountRec.Id);
                accountRec.Partner__c = newOwnerId;
                if(accountRec.OwnerId == oldOwnerId) {
                    accountRec.OwnerId = newOwnerId;
                }
                accToUpdateList.add(accountRec);
            }
            Database.update(accToUpdateList);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_PartnerUserTransfer_Accounts: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'biztech@monday.com'}); 
        }
    }

    public void finish(Database.BatchableContext BC){
        Utilities.sendEmail('Transfer Accounts from '+oldOwnerId+' to '+newOwnerId+' is finished!', 'List of Ids updated: ' + idsList.toString(), new List<String>{UserInfo.getUserEmail(),'biztech@monday.com'}); 
    }
}