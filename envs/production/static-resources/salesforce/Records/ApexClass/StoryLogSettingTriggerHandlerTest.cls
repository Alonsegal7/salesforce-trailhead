@isTest
public class StoryLogSettingTriggerHandlerTest {

    @testSetup
    static void setup() {
        
    }
    
    @isTest
    static void afterInsertTest() {
        List<StoryLogSetting__c> testSLSList = new List<StoryLogSetting__c>();
        for (Integer i = 0; i < 3; i++) {
            StoryLogSetting__c testSLS = new StoryLogSetting__c(TargetObjectName__c = 'CustomObject__' + i, IsActive__c = true);
            testSLSList.add(testSLS);
        }
        
        Test.startTest();
        insert testSLSList;
        Test.stopTest();
        
        System.assertEquals(3, [SELECT Id FROM StoryLogSetting__c].size());
        
        // Error test
        try{
            insert new StoryLogSetting__c(TargetObjectName__c = 'CustomObject__0', IsActive__c = true);
        } catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.DuplicatedStoryLogSetting));
        }
    }
    
    @isTest
    static void afterUpdateTest() {
        List<StoryLogSetting__c> testSLSList = new List<StoryLogSetting__c>();
        for (Integer i = 0; i < 3; i++) {
            StoryLogSetting__c testSLS = new StoryLogSetting__c(TargetObjectName__c = 'CustomObject__' + i, IsActive__c = false);
            testSLSList.add(testSLS);
        }
        insert testSLSList;
        
		testSLSList[1].IsActive__c = true;
        testSLSList[2].IsActive__c = true;
        
        Test.startTest();
        update testSLSList;
        Test.stopTest();
    }
}