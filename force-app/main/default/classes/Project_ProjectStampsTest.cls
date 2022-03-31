@isTest
public with sharing class Project_ProjectStampsTest {
    @TestSetup
    static void makeData(){
        Account accountRecord = TestObjectCreator.CreateAccount();
        insert accountRecord;
        accountRecord.Health_Score__c = 10;
        update accountRecord; 
        Project__c prj = new Project__c(
            Name='Test Project',
            Project_type__c='Advanced Onboarding',
            monday_Account__c= accountRecord.Id
        );
        insert prj;
    }
    @isTest
    static void testScheduledLogic() {
        Account acc= [select Id,Health_Score__c from Account where Health_Score__c = 10 limit 1];
        Project__c prj=[select Id,Health_Score_30_Days_Stamp__c,monday_Account__c from Project__c limit 1];
        prj.Project_Status__c='Closed';
        update prj;
        prj.Project_Closed_Date__c=Date.today().addDays(-30);
        update prj;
        Test.startTest();
        Batch_UpdateProjectHealthScoreStamp p = new Batch_UpdateProjectHealthScoreStamp();
        String sch = '0 0 * * * ?';
        system.schedule('TestHealthScoreStamp', sch, p);
        Test.stopTest();
        prj=[select Health_Score_30_Days_Stamp__c from Project__c limit 1];
        system.assertEquals(prj.Health_Score_30_Days_Stamp__c, acc.Health_Score__c);
    }
}    