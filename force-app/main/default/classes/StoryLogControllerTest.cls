@isTest
public class StoryLogControllerTest {/*

    @testSetup
    static void setup() {
        Account testAcc = new Account(Name = 'Test Acc');
        insert testAcc;
        
        StoryLogSetting__c testSetting = new StoryLogSetting__c(Name = 'Test Log Setting', TargetObjectName__c = 'Opportunity', IsActive__c = true);
        insert testSetting;
        
        List<StoryLogItemSetting__c> itemSettingList = new List<StoryLogItemSetting__c>();
        for (Integer i = 0; i < 2; i++) {
            StoryLogItemSetting__c testItemSetting = new StoryLogItemSetting__c(
                StoryLogSetting__c = testSetting.Id,
                SourceLabel__c = 'Test Source Lable',
                SourceAPIName__c = 'Event',
                IconName__c = 'action:follow',
                IsActive__c = true,
                RecordTypeId = Schema.SObjectType.StoryLogItemSetting__c.getRecordTypeInfosByDeveloperName().get('FieldUpdate').getRecordTypeId(),
                GroupLogs__c = true
            );
            itemSettingList.add(testItemSetting);
        }
        itemSettingList[1].IsActive__c = false;
        insert itemSettingList;
                
        Opportunity testOpp = new Opportunity(Name = 'Test Opp', StageName = 'Open', CloseDate = Date.today().addDays(5), AccountId = testAcc.Id);
        insert testOpp;
        
        List<StoryLogSnapshot__c> testSnapList = new List<StoryLogSnapshot__c>();
        for (Integer i = 0; i < itemSettingList.size(); i++) {
            for (Integer j = 0; j < 3; j++) {
                StoryLogSnapshot__c testSnap = new StoryLogSnapshot__c(
                    StoryLogItemSetting__c = itemSettingList[i].Id,
                    FieldLabel__c = 'Test Field Lable',
                    RecordName__c = 'Test Record Name',
                    Type__c = 'FieldUpdate',
                    DateTime__c = DateTime.now().addDays(0),
                    User__c = UserInfo.getUserId(),
                    ShortDescription__c = 'Test short description ' + i + j,
                    ParentRecordId__c = testOpp.Id,
                    IsGrouped__c = (j == 0) ? false : true
                );                
                testSnapList.add(testSnap);
            }
        }
        insert testSnapList;
        
        testSnapList[2].ParentSnapshot__c = testSnapList[0].Id;
        testSnapList[5].ParentSnapshot__c = testSnapList[3].Id;
        update testSnapList;
    }
    
    @isTest
    static void obtainInitDataTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
            
        Map<String, Object> params = new Map<String, Object>{
            'actionName' => 'obtainInitData',
            'recordId' => testOpp.Id,
            'objectType' => 'Opportunity',
            'monthsBackFromToday' => 10
        };
        
        Test.startTest();
        Response response = new StoryLogController().executeAction(params);
        Test.stopTest();
            
        System.assertEquals(true, response.isSuccess);
        
        Map<String, Object> responseObjects = (Map<String, Object>) response.responseObj;
        List<StoryLogController.Snapshot> logSnapshotListToCheck = (List<StoryLogController.Snapshot>) responseObjects.get('snapshotList');
        System.assertEquals(2, logSnapshotListToCheck.size());
        for (StoryLogController.Snapshot snap_i : logSnapshotListToCheck) {
            System.assertEquals('Test Source Lable', snap_i.sourceLabel);
        }
    }
    
    @isTest
    static void obtainSnaphotsByFilterTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Map<String, Object> criteriaMap = new Map<String, Object>{
            'sourceTypes' => null,
            'sourceTypeValues' => '[]',
            'dateFrom' => Date.today().addMonths(-6),
            'dateTo' => Date.today()
        };
            
        Map<String, Object> params = new Map<String, Object>{
            'actionName' => 'obtainSnaphotsByFilter',
            'objectType' => 'Opportunity',
            'recordId' => testOpp.Id,
            'criteriaMap' => JSON.serialize(criteriaMap)
        };
        
        Test.startTest();
        Response response = new StoryLogController().executeAction(params);
        Test.stopTest();
            
        System.assertEquals(true, response.isSuccess);
    }
    
    @isTest
    static void invalidActionTest() {
        Map<String, Object> params = new Map<String, Object>{
            'actionName' => 'INVALID'
        };
        String error = '';
        
        Test.startTest();
        try {
            new StoryLogController().executeAction(params);
        } catch(Exception ex) {
            error = ex.getMessage();
        }
        Test.stopTest();
            
        System.assertEquals('INVALID_ACTION: INVALID', error);
    }*/
}