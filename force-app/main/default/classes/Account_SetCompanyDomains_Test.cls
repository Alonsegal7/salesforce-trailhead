@isTest
public class Account_SetCompanyDomains_Test {
    public static Profile profileId;
    public static User userRecord;
    public static Account accRecord;
    
    private static void setupTest(){
        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;
        
        System.runAs(userRecord){
            accRecord = TestObjectCreator.CreateCompany();
            accRecord.Website = 'test1@test1.com';
            accRecord.Account_Domains__c = 'test2@test2.com';
            insert accRecord;
        }
    }
    
    @isTest static void websitePopulation(){
        setupTest();
		System.runAs(userRecord){
            accRecord.Website = 'testv1@testv1.com';
            update accRecord;
            
            Company_Domain__c cmd = [SELECT Id, Domain__c, Company__c FROM Company_Domain__c WHERE Company__c =: accRecord.Id AND Domain__c =: accRecord.Website];
            system.assertEquals(cmd.Company__c, accRecord.Id);
        }
    }
}