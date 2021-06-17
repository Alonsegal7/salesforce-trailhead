public with sharing class projectWidget {

    @AuraEnabled(cacheable=true)
    public static List<Milestone__c> projectWidget(String accountId) {
        Id projId = getProjectHelper(accountId).Id;
        return [SELECT Id, Name FROM Milestone__c WHERE Project__c =: projId ORDER BY createdDate asc];
    }

    @AuraEnabled(cacheable=true)
    public static Project__c getLatestProject(String accountId) {
        return getProjectHelper(accountId);
    }

    @AuraEnabled(cacheable=true)
    public static Milestone__c getCurrentStep(string accountId) {
        Id projId = getProjectHelper(accountId).Id;
        List<Milestone__c> milestones = [SELECT Id, Name 
                                    FROM Milestone__c 
                                    WHERE Project__c =: projId AND Status__c = 'Open' 
                                    ORDER BY createdDate asc];
        
        Milestone__c currentMS = new Milestone__c();                      
        if(!milestones.isempty())
            currentMS = milestones[0];
        else{//if no Open MSs, markt he last MS as the current one.
            currentMS=[SELECT Id, Name 
                        FROM Milestone__c 
                        WHERE Project__c =: projId 
                        ORDER BY createdDate desc][0];
        }      
        system.debug('Raz Ben Ron currentMS:'+currentMS);
        return currentMS;
    }
    
    public static Project__c getProjectHelper(String accountId) {
        return [SELECT Id, Name FROM Project__c 
                WHERE Monday_Account__c =: accountId AND (Project_Type__c = 'Onboarding' OR Project_Type__c = 'Expansion') ORDER BY createdDate desc][0];
    }
}