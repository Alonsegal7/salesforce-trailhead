public class Batch_TargetsStampUserData implements Database.Batchable<sObject>,Schedulable {

    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this,30);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_TargetsStampUserData ', e, e.getMessage());   
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Date firstOfTodayMonth = Date.today().toStartOfMonth();
        String query = 'select Id, User__c, Target_Date__c from Target__c where Target_Date__c >=: firstOfTodayMonth';
        return Database.getQueryLocator(query);
     }

    public void execute(Database.BatchableContext BC, list<Target__c> scope){
        Target_StampUserData helper = new Target_StampUserData();
        List<Target__c> updatedTargetsList = helper.stampUserData(scope, null);
        if(!updatedTargetsList.isEmpty()) Database.update(updatedTargetsList);
    }
    
    public void finish(Database.BatchableContext BC){
    }
}