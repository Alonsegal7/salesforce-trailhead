@isTest
public without sharing class Target_StampUserDataTest {
    
    @TestSetup
    static void makeData(){
        Account company = new Account(Name='test company');
        insert company;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User manager = new User(Alias = 'manager',Country='United Kingdom',Email='manager@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = admin.Id,TimeZoneSidKey='America/Los_Angeles', UserName='manager@monday.com');
		insert manager;
        
        User user = TestUtils.getUserWithoutRole(p);
        user.LastName = 'test1';
        user.ManagerId = manager.Id;
        user.Office__c = 'Tel Aviv Office';
        user.Outbound__c = true; 
        user.Start_Date__c = date.today(); 
        user.Function__c = 'Enterprise AM';
        user.Group__c = 'Sales';
        user.Business_Role__c = 'AM';
        user.Segment__c = 'Enterprise';
        user.Seniority__c = 'Rep';
        user.Team__c = 'Ben';
        insert user;
    }

    @isTest
    static void shouldStampUserDataOnTargetCreation(){

        User u = [SELECT Id, Outbound__c, Department, Tenure_Months__c,  Function__c, Group__c, Business_Role__c, Segment__c, Seniority__c, Quota_Carrying__c, Team__c, Office__c, Office_Region__c FROM User WHERE LastName = 'test1'];
        Target__c target = new Target__c(
            User__c=u.Id, 
            Amount__c = 0,
            RecordTypeId = Utilities.personalTargetRT, 
            Target_Date__c=Date.newInstance(2023, 12, 1)
        );
        Test.startTest();
        insert target;
        Test.stopTest();
        target = [SELECT id, Tenure__c, Outbound_Rep__c, Department__c, Function__c, User_Group__c, User_Business_Role__c, User_Segment__c, User_Seniority__c, User_Quota_Carrying__c, Team__c, User_Office__c, User_Office_Region__c, Ramp_Up_Stage__c FROM Target__c LIMIT 1];
        System.assertEquals(u.Tenure_Months__c, target.Tenure__c);
        System.assertEquals(u.Outbound__c, target.Outbound_Rep__c);
        System.assertEquals(u.Department, target.Department__c);
        System.assertEquals(u.Function__c, target.Function__c);
        System.assertEquals(u.Group__c, target.User_Group__c);
        System.assertEquals(u.Business_Role__c, target.User_Business_Role__c);
        System.assertEquals(u.Segment__c, target.User_Segment__c);
        System.assertEquals(u.Seniority__c, target.User_Seniority__c);
        System.assertEquals(u.Quota_Carrying__c, target.User_Quota_Carrying__c);
        System.assertEquals(u.Team__c, target.Team__c);
        System.assertEquals(u.Office__c, target.User_Office__c);
        System.assertEquals(u.Office_Region__c, target.User_Office_Region__c);
        System.assertEquals('Onboarding', target.Ramp_Up_Stage__c);
    }
}
