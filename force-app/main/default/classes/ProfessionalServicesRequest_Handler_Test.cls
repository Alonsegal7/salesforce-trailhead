@isTest
public class ProfessionalServicesRequest_Handler_Test {
    public static Profile profileId;
    public static User userRecord;
    public static Project__c projectRecord;
    public static Professional_Service_Request__c psRecord;
    
    @isTest static void psTestMethod(){
        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;
        
        System.runAs(userRecord){
            projectRecord = TestUtils.getProject('Test Project', 'Professional Services', 'Open');
            insert projectRecord;
            
            psRecord = new Professional_Service_Request__c();
            insert psRecord;
            
            Project__c projectRecordList = [SELECT Id FROM Project__c WHERE Id =: projectRecord.Id LIMIT 1];
            
            Professional_Service_Request__c psRecordList = [SELECT Id, Project_Id__c FROM Professional_Service_Request__c WHERE Id =: psRecord.Id LIMIT 1];
            psRecordList.Project_Id__c = projectRecordList.Id;
            update psRecordList;
        }
    }
    
    
}