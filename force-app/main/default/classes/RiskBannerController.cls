public with sharing class RiskBannerController {

    @AuraEnabled(cacheable=true)
    public static List<Risk__c> getRisks(Id recordId){
        List<Risk__c> lst = new List<Risk__c>([SELECT Id, Name, Risk_Name__c, Risk_Status__c FROM Risk__c WHERE Monday_Account__c =: recordId]);
        return lst;
    }
}