public with sharing class relatedPopoverHelper {

    public static Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
    public static Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
    public static Id accountsPoolUserId = '0053X00000Bo8ZZQAZ';

    // 
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLeadData(Id leadId){
        try {
            Map <String, Object> resultsMap = new Map <String, Object>();

            Lead lead = [SELECT Parent_Company__r.OwnerId, Related_Company__r.OwnerId, Related_Company__c, Parent_Company__c FROM LEAD WHERE Id = :leadId LIMIT 1][0];
            Id relatedCompany = lead.Related_Company__c;

            List<Lead> relatedLeads = new List<Lead>([SELECT Id, Name, Title, OwnerId, Owner_Name_Live__c, Owner_Name_Text__c, Owner_s_Group__c, Region__c, Status, LastActivityDate, Last_Touch_Date__c, Owner_is_Partner_CPM__c, Owner_Group_Live__c, Owner_s_Manager__c, Owner_s_Manager__r.Name
            FROM Lead WHERE Status != 'Unqualified' AND Id <>: leadId AND Related_Company__c =: relatedCompany ORDER BY LastActivityDate DESC LIMIT 20]);

            List<Opportunity> relatedOpps = new List<Opportunity>([SELECT Id, Company__c, Name, OwnerId, Owner_s_Name__c, Account_Region__c, StageName, LastActivityDate, Owner_Group_Live__c, Owner_s_Manager__c, Owner_s_Manager__r.Name, Owner.Group__c
            FROM Opportunity WHERE Company__c =: relatedCompany AND (StageName <> 'Closed Lost' OR (StageName = 'Closed Lost' and CloseDate = LAST_N_MONTHS:9)) ORDER BY StageName ASC LIMIT 20]);

            List<Account> relatedPayingMAs = new List<Account>([SELECT Id, Name, OwnerId, Owner_Name__c, Owner.Group__c, Region__c, ARR__c, Plan_Seats__c, Owner_s_Manager__r.Name, Owner_is_Partner__c, Owner_s_Group__c 
            FROM Account WHERE Company__c =: relatedCompany AND RecordType.Name = 'Monday Account' AND ARR__c > 0 LIMIT 20]);

            Boolean isRelatedCompanyOwnedByAccountsPool = false;
            if (lead.Related_Company__c != null && lead.Parent_Company__c != null && lead.Related_Company__r.OwnerId == lead.Parent_Company__r.OwnerId && lead.Parent_Company__r.OwnerId == accountsPoolUserId) {
                isRelatedCompanyOwnedByAccountsPool = true;
            }
            resultsMap.put('relatedLeads',relatedLeads);
            resultsMap.put('relatedOpps',relatedOpps);
            resultsMap.put('relatedPayingMAs',relatedPayingMAs);
            resultsMap.put('isRelatedCompanyOwnedByAccountsPool',isRelatedCompanyOwnedByAccountsPool);
            resultsMap.put('relatedCompanyId',lead.Related_Company__c);
            return resultsMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}