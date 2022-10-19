public with sharing class LeadContextComponentHelper {

        @AuraEnabled(cacheable = true)
        public static List<User> getUserId(String userName){
            List<User> currentUser = [SELECT Id, Full_Name__c FROM USER WHERE Name = :userName LIMIT 1];
            return currentUser;
        }
    
}
