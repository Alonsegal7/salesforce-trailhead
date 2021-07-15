public class Batch_PartnerUserTransfer_Accounts implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private Id oldOwnerId;
    private Id newOwnerId;

    public Batch_PartnerUserTransfer_Accounts(Id oldOwnerId, Id newOwnerId) {
        this.oldOwnerId = oldOwnerId;
        this.newOwnerId = newOwnerId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            String query = 'select Id, Name, OwnerId, Partner__c from Account where OwnerId = \'' + oldOwnerId + '\' or Partner__c = \'' + oldOwnerId + '\'';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_PartnerUserTransfer_Accounts: ',e,e.getMessage());   
            return null;
        }
    }

    public void execute(Database.BatchableContext BC, list<Account> scope){
        try{
            List<Account> accToUpdateList = new List<Account>();
            for(Account accountRec : scope){
                accountRec.Partner__c = newOwnerId;
                if(accountRec.OwnerId == oldOwnerId) {
                    accountRec.OwnerId = newOwnerId;
                }
                accToUpdateList.add(accountRec);
            }
            Database.update(accToUpdateList);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_PartnerUserTransfer_Accounts: ',e,e.getMessage());   
        }
    }

    public void finish(Database.BatchableContext BC){
        //send email?
    }
}