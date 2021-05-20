@isTest
public class ProjectHandler_Test {
    public static Profile profileId;
    public static User userRecord;
    public static Project__c projectRecord;
    public static Project__c projectRecordStatus;
    
    private static void setupTest(){
        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;
        
        System.runAs(userRecord){
            projectRecord = TestUtils.getProject('Test Project', 'Onboarding', 'Open');
            insert projectRecord;

            projectRecordStatus = TestUtils.getProject('Test Project', 'Onboarding', 'Postponed');
            insert projectRecordStatus;
        }
    }
    
    @isTest static void updateProjectFields(){
        setupTest();
		System.runAs(userRecord){
            Project__c proj = [SELECT Id, Postponed_Counter__c FROM Project__c WHERE Id =: projectRecord.Id];
            system.assertEquals(proj.Postponed_Counter__c, 0);
            
            projectRecordStatus.Postponed_Start_Date__c = System.now() - 2;
            update projectRecordStatus;
            
            projectRecordStatus.Project_Status__c = 'Open';
            update projectRecordStatus;

            projectRecord.Project_Status__c = 'Postponed';
            projectRecord.Postponed_Cancel_reasson__c = 'No Response';
            update projectRecord;
            
            Project__c proj2nd = [SELECT Id, Postponed_Age__c FROM Project__c WHERE Id =: projectRecord.Id];
            system.assertEquals(proj2nd.Postponed_Age__c, 0);
            
            projectRecord.Project_Status__c = 'Open';
            update projectRecord;
            
            Project__c proj3rd = [SELECT Id, Postponed_Age__c, Postponed_End_Date__c FROM Project__c WHERE Id =: projectRecord.Id];
            system.assertEquals(proj3rd.Postponed_Age__c, 0);
        }
    }
}