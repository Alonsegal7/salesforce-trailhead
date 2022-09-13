public with sharing class Account_CreatePodAssignmentPartners {
    public static void Account_CreatePodAssignmentPartners(List<Account> newAccounts, Map<Id,Account> oldAccountsMap){
        //try{
            list<Account> relevantAccounts= new list<Account>();
            set<Id> relevantAccountsIds= new set<Id>();
            Id PartnerCompneyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
            for(Account acc: newAccounts){
                //1. Partner Compeny has been created on signed status 2. Partner Compeny has been updated to be a signed partner compney 
                if((oldAccountsMap==null && acc.RecordTypeId==PartnerCompneyRecordTypeId && acc.Partner_Company_Status__c=='Signed')||
                (oldAccountsMap != null && acc.RecordTypeId==PartnerCompneyRecordTypeId  && 
                acc.Partner_Company_Status__c!=oldAccountsMap.get(acc.id).Partner_Company_Status__c && acc.Partner_Company_Status__c=='Signed'))
                {
                    relevantAccounts.add(acc);
                    //for partner company that has been updated, make sure for duplications (Pod assignemnt already has been created)
                    if(acc.Id!=null)
                    relevantAccountsIds.add(acc.Id);
                }
            }
            if(relevantAccounts.isEmpty())
                return;

            //look for existing Pods Assignemnt in order to prevent duplications
            map<id,Pod_Assignment__c> existingPodAssignment= new map<id,Pod_Assignment__c>();
            for(Pod_Assignment__c Pod: [select id,Partner_Pod_Lead_Partner_Company__c from Pod_Assignment__c where Partner_Pod_Lead_Partner_Company__c in: relevantAccountsIds AND Status__c!='Inactive']){               
                existingPodAssignment.put(Pod.Partner_Pod_Lead_Partner_Company__c,Pod);
            }  
            list<Pod_Assignment__c> podsAssignmentToCreate= new list<Pod_Assignment__c>();
            for(Account accForPodCreation:relevantAccounts){
                if(accForPodCreation.Id==null||!existingPodAssignment.containskey(accForPodCreation.Id))
                podsAssignmentToCreate.add(new Pod_Assignment__c(Partner_Pod_Lead_Partner_Company__c=accForPodCreation.Id,
                                                    Pod_Lead_Manager__c=accForPodCreation.OwnerId,
                                                    Pod_Type__c='Partners',
                                                    Status__c='Pending Assignment'));
            }
            if(!podsAssignmentToCreate.isEmpty())
                insert podsAssignmentToCreate;
    }
}


