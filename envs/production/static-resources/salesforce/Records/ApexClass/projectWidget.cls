public with sharing class projectWidget {
    @AuraEnabled(cacheable=true)
    public static list<Milestone__c> projectWidget(string accountId) {
        Id projId=getProjectHelper(accountId).Id;
        return [select id,Name from Milestone__c where Project__c=:projId order by createddate asc];
    }
    @AuraEnabled(cacheable=true)
    public static Project__c getLatestProject(string accountId) {
        return getProjectHelper(accountId);
        }
    @AuraEnabled(cacheable=true)
    public static Milestone__c getCurrentStep(string accountId) {
        Id projId=getProjectHelper(accountId).Id;
        list<Milestone__c> milestones= [select id,Name 
                                    from Milestone__c 
                                    where Project__c=:projId and Status__c='Open' 
                                    order by createddate asc];
        
        Milestone__c currentMS = new Milestone__c();                      
        if(!milestones.isempty())
            currentMS = milestones[0];
        else{//if no Open MSs, markt he last MS as the current one.
            currentMS=[select id,Name 
                        from Milestone__c 
                        where Project__c=:projId 
                        order by createddate desc][0];
        }      
        system.debug('Raz Ben Ron currentMS:'+currentMS);
        return currentMS;
    }
    public static Project__c getProjectHelper(string accountId) {
        return [select id,Name from Project__c 
                where Monday_Account__c=:accountId order by createddate asc][0];
    }
}