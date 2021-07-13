public without sharing class Leads_Cap_CallBatch implements Schedulable{
    public static Id internalRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Internal_Lead').getRecordTypeId();
    public static Id partnerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
    
    public void execute(SchedulableContext sc) {
        Leads_Cap_CallBatch lccb = new Leads_Cap_CallBatch();
    }
    public Leads_Cap_CallBatch() {
        map<Id,Leads_Cap__c> lcByOwner= new  map<Id,Leads_Cap__c>();
        map<Id,Leads_Cap__c> lcByPC= new  map<Id,Leads_Cap__c>();
        for(Leads_Cap__c lc: [select id,User__c,Channel_Partner__c,Open_Leads_Actual__c,Open_Leads_Limit__c,Available_for_Distribution__c
                                from Leads_Cap__c 
                                where (User__c != null and User__r.IsActive=true and User__r.should_get_leads_from_BigBrain__c=true) or 
                                    (Channel_Partner__c != null and (Channel_Partner__r.Partner_Company_Status__c='Signed' or Channel_Partner__r.Partner_Signed_Timestamp__c!=null ))]){
            if(lc.User__c!=null){
                lcByOwner.put(lc.User__c,lc);
            }else if(lc.Channel_Partner__c!=null){
                lcByPC.put(lc.Channel_Partner__c,lc);
            }
        } 
        Lead_Cap_CalcOpenLeads internalBatch = new Lead_Cap_CalcOpenLeads('ownerId',internalRecordTypeId,lcByOwner);
        Lead_Cap_CalcOpenLeads partnersBatch = new Lead_Cap_CalcOpenLeads('Partner_Company__c',partnerRecordTypeId,lcByPC);
        
        Utilities.cleanFlexQueue();
        Database.executeBatch(internalBatch,20);
        Database.executeBatch(partnersBatch,20);
    }
}