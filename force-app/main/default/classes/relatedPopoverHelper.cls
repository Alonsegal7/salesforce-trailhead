public with sharing class relatedPopoverHelper {
    
    @AuraEnabled(cacheable=true)
    public static List<Lead> getRelatedLeadOnLead(Id leadId) {
        Id relatedCompany = [SELECT Related_Company__c FROM LEAD WHERE Id = :leadId LIMIT 1][0].Related_Company__c;
        return [SELECT Id, Name, Title, OwnerId, Owner_Name_Live__c, Region__c, Status, LastActivityDate, Owner_is_Partner_CPM__c, Owner_Group_Live__c, Owner_s_Manager__c, Owner_s_Manager__r.Name
        FROM Lead WHERE Status != 'Unqualified' AND Related_Company__c =: relatedCompany ORDER BY LastActivityDate DESC LIMIT 20];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getRelatedOppsOnLead(Id leadId) {
        Id relatedCompany = [SELECT Related_Company__c FROM LEAD WHERE Id = :leadId LIMIT 1][0].Related_Company__c;
        return [SELECT Id, Company__c, Name, OwnerId, Owner_s_Name__c, Account_Region__c, StageName, LastActivityDate, Owner_Group_Live__c, Owner_s_Manager__c, Owner_s_Manager__r.Name, Owner.Group__c
        FROM Opportunity WHERE Company__c =: relatedCompany AND (StageName <> 'Closed Lost' OR (StageName = 'Closed Lost' and CloseDate = LAST_N_MONTHS:9)) ORDER BY LastActivityDate DESC LIMIT 20];
    }
}