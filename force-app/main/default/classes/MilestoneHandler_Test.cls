@isTest
public class MilestoneHandler_Test {

    @isTest public static void updateProjectStatus(){
        Id milestoneRT = Schema.SObjectType.Milestone__c.getRecordTypeInfosByDeveloperName().get('Session').getRecordTypeId();
        Id kickoffMilestoneRT = Schema.SObjectType.Milestone__c.getRecordTypeInfosByDeveloperName().get('Kickoff').getRecordTypeId();
        
        Project__c projectRecord = new Project__c();
        projectRecord.Name = 'Test Project';
        projectRecord.Project_Type__c = 'Onboarding';
        projectRecord.Project_Status__c = 'Pending Project Start';
        projectRecord.Kickoff_Date__c = System.today() + 5;
        insert projectRecord;
        
        Project__c p = [SELECT Id FROM Project__c WHERE Id =: projectRecord.Id LIMIT 1];
        
        Milestone__c mileRecord = new Milestone__c();
        mileRecord.Name = 'Test Milestone';
        mileRecord.RecordTypeId = milestoneRT;
        mileRecord.Project__c = projectRecord.Id;
        mileRecord.Milestone_type__c = 'Advanced Training';
        mileRecord.Session_Due_Date__c = System.today();
        mileRecord.Status__c = 'Open';
        insert mileRecord;
        
        Project__c proj = [SELECT Id, Project_Status__c FROM Project__c WHERE Id =: projectRecord.Id LIMIT 1];
        System.assertEquals(proj.Project_Status__c, 'Open');
        
        Milestone__c mileRecordKick = new Milestone__c();
        mileRecordKick.Name = 'Test Kickoff';
        mileRecordKick.RecordTypeId = kickoffMilestoneRT;
        mileRecordKick.Project__c = projectRecord.Id;
        mileRecordKick.Kickoff_meeting_date__c = System.today() - 10;
        mileRecordKick.Status__c = 'Open';
        insert mileRecordKick;
        
        mileRecordKick.Kickoff_meeting_date__c = System.today() - 15;
        update mileRecordKick;
    }
}