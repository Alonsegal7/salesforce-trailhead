public without sharing class CloneOpportunityController {
    
    @AuraEnabled
    public static String cloneOpportunityWithContent(Opportunity opp, String sourceOppRecordId) {
        try{
            system.debug('raz Ben Ron CO opp: '+opp);
            Opportunity clonedOpp = cloneCurrentOpportunity(opp, sourceOppRecordId);
            cloneContactRoles(clonedOpp.Id, sourceOppRecordId);
            moveTasks(clonedOpp.Id, sourceOppRecordId);
            
            return clonedOpp.Id;
        } 
        catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber() + ' : ' + e.getMessage());
        }
    }  
    
    public static void cloneContactRoles(String clonedOppId, String oldOppId){
     	OpportunityContactRole[] roles = [select ContactId, OpportunityId, IsPrimary, Role 
                                              from OpportunityContactRole where OpportunityId=:oldOppId];
         for(OpportunityContactRole role : roles){
             OpportunityContactRole clonedRole = new OpportunityContactRole(OpportunityId=clonedOppId, Role=role.Role, ContactId=role.ContactId, IsPrimary=role.IsPrimary);
             insert clonedRole;
         }   
    }
    
    public static Opportunity cloneCurrentOpportunity(Opportunity opp, String sourceOppRecordId){
       	Opportunity sourceOpp = [select StageName, AccountId, CloseDate, OwnerId, Name, primary_pulse_account_id__c, pulse_account_ids__c, 
                                 time_zone_offset__c, LeadSource, Monday_Account__c, Company__c, Pricing_Version__c, Main_Point_of_Contacts__c,
                                 Core_Business__c, Use_cases__c, Current_tools__c, Pains__c, Workflow__c, Departments_AE__c,Opportunity_Attribution__c,
                                 Sub_Attribution__c
                                 from Opportunity where Id=:sourceOppRecordId];
        Opportunity clonedOpp = sourceOpp.clone( false, true, false, false );
        clonedOpp.OwnerId = UserInfo.getUserId();
        clonedOpp.Type = 'Expansion';
        clonedOpp.StageName = 'Qualified';
        Set<String> whiteList = new Set<String>(new String[]{'StageName', 'AccountId', 'CloseDate', 'Name','Opportunity_Attribution__c','Sub_Attribution__c'});
        
        Map<String, Object> oppFieldsToValue = opp.getPopulatedFieldsAsMap();
        for(String fieldApiName : oppFieldsToValue.keySet()){
            if(whiteList.contains(fieldApiName)){
                clonedOpp.put(fieldApiName, oppFieldsToValue.get(fieldApiName));  
            }
        }
        
        insert clonedOpp;
        return clonedOpp;
    }
    
    public static void moveTasks(String clonedOppId, String oldOppId){
        Task[] tasks = [select Id, WhatId, Opportunity__c from Task where WhatId=:oldOppId];
        for(Task task : tasks){
            if(task.Opportunity__c == null){
	            task.Opportunity__c = task.WhatId;
            }
            task.WhatId = clonedOppId; 
        }
        update tasks;
    }
}