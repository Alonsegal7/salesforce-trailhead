public without sharing class Lead_SetPartnerCompany {
    public static Id internalRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Internal_Lead').getRecordTypeId();
    public static Id partnerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();

    public static void Lead_SetPartnerCompany(list<Lead> newLeads, map<Id,Lead> oldLeads){
        try{
            Set<Id> relevantUsers= new Set<Id>();
            List<Lead> relevantLeads= new List<Lead>();
            for(Lead lead: newLeads){
                if(lead.RecordTypeId==partnerRecordTypeId&&
                    (oldLeads==null||lead.OwnerId!=oldLeads.get(lead.Id).OwnerId
                    ||lead.RecordTypeId!=oldLeads.get(lead.Id).RecordTypeId)){
                        relevantUsers.add(lead.OwnerId);
                        relevantLeads.add(lead);
                    }
            }
            if(relevantLeads.isEmpty())
                return;
            map<Id,User> usersWithDetails= new map<Id,User>([select id,Contact.AccountId from User where id in:relevantUsers]);
            for(Lead lead: relevantLeads){
                if(usersWithDetails.containskey(lead.OwnerId)&&usersWithDetails.get(lead.OwnerId).Contact.AccountId!=null)
                    lead.Partner_Company__c=usersWithDetails.get(lead.OwnerId).Contact.AccountId;
                else{
                    lead.Partner_Company__c=null;
                }
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Lead_SetPartnerCompeny',e,e.getMessage());   
        }
    }
}