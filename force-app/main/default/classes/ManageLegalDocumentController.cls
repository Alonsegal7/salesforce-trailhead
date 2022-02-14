public with sharing class ManageLegalDocumentController {

    @AuraEnabled(cacheable=true)
    public static Quote getSalesOrderDetails(String oppId){
        try{
            List<Quote> listOfQuotes = [select id,Legal_Agreement_Type__c,Document_Type__c,Billing_Entity__c,
                                        Opportunity.Name, Opportunity.Company__c, Opportunity.Company__r.Name, Opportunity.IsClosed
                                        from Quote 
                                        where IsSyncing=true AND 
                                        Billing_Entity__c!=null 
                                        AND Document_Type__c='Sales Order' 
                                        AND Opportunity.IsClosed!=true
                                        AND Opportunity.id=:oppId];  
             if (!listOfQuotes.isempty()) {
                return listOfQuotes[0];
             }
             else {
                 return null;
             }                           
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<Legal_Document__c> legalDocExistForCompany(String oppId, string legalDocType){
        try{
            List<Opportunity> opp = [SELECT Company__c from Opportunity where Id=:oppId];
            list<Legal_Document__c> legDocByType = [SELECT Id, Document_type__c, Status__c, CLM_Document_Link__c FROM Legal_Document__c
            WHERE SetVisibleOnComponent__c=true AND Document_type__c =: legalDocType AND Company__c =:opp[0].Company__c];
            if(!legDocByType.isempty()){
                //Get the entire company legal docs 
                list<Legal_Document__c> compLegDocs = [SELECT Id, Document_type__c, Status__c, Last_status_update_date__c, CLM_Document_Link__c FROM Legal_Document__c
                WHERE Company__c =:opp[0].Company__c]; 
                return compLegDocs;
            }else {
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isSandbox(){
        Boolean isSandbox;
        try{
        return isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}