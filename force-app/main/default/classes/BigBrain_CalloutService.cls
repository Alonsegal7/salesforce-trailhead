public without sharing class BigBrain_CalloutService implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {

    /*link to design chart: https://lucid.app/lucidchart/5803c1f3-1ee7-4e05-b364-15c1d6212b89/edit?invitationId=inv_dd4cd748-7d62-4dd2-acb2-03e46696a2db */
    private static final Integer BATCH_SIZE = 10;
    private string sObjectType_forBatch = 'Opportunity';

    /*public BigBrain_CalloutService(String sObjectType){
        this.sObjectType_forBatch = sObjectType;
    }*/

    // map of CMT data - key = Object Name, value = BigBrain_Callout_Control__mdt record
    public static map<string,BigBrain_Callout_Control__mdt> bigBrainCalloutControl_cmt {
        get {
            if (bigBrainCalloutControl_cmt == null) {
                bigBrainCalloutControl_cmt = new map<string,BigBrain_Callout_Control__mdt>();
                for(BigBrain_Callout_Control__mdt cmt: [select id,DELETE__c,INSERT__c,UPDATE__c,Field_Set_Name__c,masterlabel from BigBrain_Callout_Control__mdt]){
                    bigBrainCalloutControl_cmt.put(cmt.masterlabel.tolowercase(), cmt);
                }
            }
            return bigBrainCalloutControl_cmt;
        }
        set;
    }

    // webhook key - stored in CMT
    public static String webhook_Key {
        get {
            if (webhook_Key == null) {
                webhook_Key = [select id, Key__c from Webhook_Key__mdt where DeveloperName = 'Big_Brain' limit 1].Key__c;
            }
            return webhook_Key;
        }
        set;
    }

    //scheduler to call batches per object (currently only opportunity)
    public void execute(SchedulableContext SC) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this, BATCH_SIZE);
        } catch(Exception e){
            Utilities.sendEmail('Error in BigBrain_CalloutService execute schedule: ',e.getMessage()+ ' ' + e.getStackTraceString(), new list<string>{'kseniasm@monday.com'});   
        }
    }
    
    //batch to send callouts. called from the scheduler
    //we query only 200 records per run, ordered by last modified ASC
    public Database.QueryLocator start(Database.BatchableContext BC){
        try {
            // we use global describe to get all the fields for the query
            List<String> fields = new List<String>(Schema.getGlobalDescribe().get(sObjectType_forBatch).getDescribe().fields.getMap().keySet());
            String query = 'SELECT ' + String.join(fields, ',') + ' FROM Opportunity where Need_Sync_to_BB__c = true order by LastModifiedDate ASC limit 200';
            System.debug('BigBrain_CalloutService batch start query: ' + query);
            return Database.getQueryLocator(query);
        } catch(Exception e){
            Utilities.sendEmail('Error in BigBrain_CalloutService start: ',e.getMessage()+ ' ' + e.getStackTraceString(), new list<string>{'kseniasm@monday.com'});   
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<sobject> scope){
        try {
            System.debug('BigBrain_CalloutService batch execute scope: ' + scope);
            sendUpdateCalloutToBB(scope);
            setNeedSyncToBB(scope, false, true); //update need sync to bb to false with DML
        } catch (Exception e) {
            Utilities.sendEmail('Error in BigBrain_CalloutService execute: ',e.getMessage()+ ' ' + e.getStackTraceString(), new list<string>{'kseniasm@monday.com'});   
        }
    }

    public void finish(Database.BatchableContext BC){}
    //end of batch

    //method to send the callout to BB - called by the batch 
    public static void sendUpdateCalloutToBB(List<sObject> objects) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String url = ConfigManager.getBigBrainWebhookUrl();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', webhook_Key);
        request.setBody(JSON.serialize(objects));
        request.setTimeout(120000);
        if (!Test.isRunningTest()){
            HttpResponse response = http.send(request); 
            System.debug('BigBrain_CalloutService batch execute sendUpdateCalloutToBB response status code: ' + response.getStatusCode() + ' ; body: '+ response.getBody());   
        }
    }

    // method to update the field Need_Sync_to_BB__c and optionally run an update DML 
    public static void setNeedSyncToBB(list<sobject> sobjList, Boolean value, Boolean runUpdateDML){
        if(!runUpdateDML){
            for(sobject rec: sobjList){
                rec.put('Need_Sync_to_BB__c', value);
            }
            System.debug('BigBrain_CalloutService batch execute setNeedSyncToBB sobjList: ' + sobjList);
        } else {
            list<sobject> sobjectsToUpdate = new list<sobject>();
            for(sobject rec: sobjList){
                String rec_json = '{"attributes":{"type":"'+string.valueof(rec.getSObjectType())+'"},"Id":"'+string.valueOf(rec.get('Id'))+'","Need_Sync_to_BB__c":"'+string.valueOf(value)+'"}';
                System.debug('BigBrain_CalloutService batch execute setNeedSyncToBB rec_json: ' + rec_json);
                sobjectsToUpdate.add((sobject)JSON.deserialize(rec_json, sobject.class));
            }
            System.debug('BigBrain_CalloutService batch execute setNeedSyncToBB sobjectsToUpdate: ' + sobjectsToUpdate);
            Database.update(sobjectsToUpdate);
        }
    }

    //this method can optionally be referenced from trigger to allow inoking queueable to send callout to BB
    public static void manualSync(list <sobject> sobject_list){
        list <sobject> recordsToSendCallout_list = new list <sobject>();
        for (sobject rec : sobject_list){
            if(rec.get('Manual_Trigger__c') == 'Sync to BB'){
                rec.put('Need_Sync_to_BB__c', false);
                rec.put('Manual_Trigger__c', '');
                recordsToSendCallout_list.add(rec);
            }
        }
        System.debug('BigBrain_CalloutService manualSync recordsToSendCallout_list: ' + recordsToSendCallout_list);
        System.enqueueJob(new sendCalloutToBBQueue(recordsToSendCallout_list));
    }

    // queueable class that sends a callout to BB of input records list 
    private class sendCalloutToBBQueue implements System.Queueable, Database.AllowsCallouts {
        private list <sobject> recordsList; 
        public sendCalloutToBBQueue(list <sobject> recordsList) {
            this.recordsList = recordsList;
        }
        public void execute(System.QueueableContext ctx) {
            sendUpdateCalloutToBB(recordsList);
        }
    }
    
    // method that handles the real-time logic to mark records that need to be synced to BB
    // it does not run an update DML if called from before trigger
    // it runs an update DML if called from after trigger
    public static list <sobject> markRecordsToSync(list <sobject> sobject_list, map <id,sobject> sobject_oldmap, Boolean runUpdateDML){
        list <sobject> recordsToUpdate_list = new list <sobject>();
        for (sobject rec : sobject_list){
            if(rec.get('Need_Sync_to_BB__c') == true || rec.get('Need_Sync_to_BB__c') == 'true') continue;
            string sobjectType = string.valueof(rec.getSObjectType());
            BigBrain_Callout_Control__mdt cmt = null;
            if (sobjectType!=null && bigBrainCalloutControl_cmt.containsKey(sobjectType.tolowercase())){
                cmt = bigBrainCalloutControl_cmt.get(sobjectType.tolowercase());  
            } else {
                continue;
            }
            if (cmt.INSERT__c && sobject_oldmap==null){ //insert
                recordsToUpdate_list.add(rec); 
            }
            if (cmt.UPDATE__c && sobject_oldmap!=null && cmt.Field_Set_Name__c==null){ //update w/o fieldsSet
                recordsToUpdate_list.add(rec); 
            }
            if (cmt.UPDATE__c && sobject_oldmap!=null && cmt.Field_Set_Name__c!=null && sobject_oldmap!=null && sobject_oldmap.containsKey(rec.id) && isChangedByFieldSet(rec, sobjectType, sobject_oldmap.get(rec.id), cmt)) { //update with fieldSet
                recordsToUpdate_list.add(rec); 
            }
        }
        if(!recordsToUpdate_list.isEmpty()){
            setNeedSyncToBB(recordsToUpdate_list, true, runUpdateDML); // runUpdateDML = Trigger.isAfter
        }
        System.debug('BigBrain_CalloutService markRecordsToSync recordsToUpdate_list: ' + recordsToUpdate_list);
        return recordsToUpdate_list;
    }

    //method to check if the fields from fieldsSet were updated
    //field set name is taken from Field_Set_Name__c field on BigBrain_Callout_Control__mdt CMT by the sobject type
    private static boolean isChangedByFieldSet(sobject rec, string sobjectType, sobject oldRec, BigBrain_Callout_Control__mdt cmt){
        boolean res = false;
        if (rec==null || sobjectType==null || oldRec==null) return res;
        string fsname = null;
        if (cmt!=null && cmt.Field_Set_Name__c!=null) fsname = cmt.Field_Set_Name__c;
        else return res;
        
        SObjectType sobjectGlobalDescribe = Schema.getGlobalDescribe().get(sobjectType);
        if(sobjectGlobalDescribe == null) return res;
        Schema.FieldSet fs = sobjectGlobalDescribe.getDescribe().fieldSets.getMap().get(fsname);

        if(fs != null){ //check if field from fieldSet was updated
            for(Schema.FieldSetMember fsm : fs.getFields()){
                if (rec.get(fsm.getFieldPath()) != oldRec.get(fsm.getFieldPath())) { 
                    res = true; 
                }  
            } 
        }
        return res;
    }
}
