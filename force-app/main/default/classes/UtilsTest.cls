@isTest
public class UtilsTest {

    @testSetup
    static void setup() {
        StoryLogSetting__c logSetting = new StoryLogSetting__c(TargetObjectName__c = 'Opportunity', IsActive__c = true);
        insert logSetting;
        
        StoryLogItemSetting__c logItemSetting = new StoryLogItemSetting__c(StoryLogSetting__c = logSetting.Id, IsActive__c = true,
                                                                           FieldSetName__c = 'Next_Strategy');
        insert logItemSetting;
        
        Account testAcc = new Account(Name = 'Test Acc');
        insert testAcc;
        
        List<Opportunity> oppList = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            Opportunity testOpp = new Opportunity(Name = 'Test Opp ' + i, StageName = 'Open', CloseDate = Date.today().addDays(5), AccountId = testAcc.Id,
                                                  NextStep = 'Test Step ' + i);
            oppList.add(testOpp);
        }
        insert oppList;
    }
    
    @isTest
    static void getChangedObjectsTest() {
        List<Opportunity> oppList = [SELECT StageName FROM Opportunity],
            			  oppListToCompare = oppList.deepClone(true);
        System.debug(oppList);
        System.debug(oppListToCompare);
        
        oppListToCompare[1].StageName = 'Closed Won';
        oppListToCompare[2].StageName = 'Closed Lost';
        
        List<Opportunity> changedOppsToCheck = Utils.getChangedObjects(new List<Schema.SObjectField>{Schema.Opportunity.StageName},
                                                                       oppListToCompare, new Map<Id, Opportunity>(oppList));
        System.assertNotEquals(oppList[0].Id, changedOppsToCheck[0].Id);
        System.assertEquals(oppList[1].Id, changedOppsToCheck[0].Id);
        System.assertEquals(oppList[2].Id, changedOppsToCheck[1].Id);
    }
    
    @isTest
    static void fetchFieldsFromFieldSetTest() {
        Schema.FieldSet oppFieldSet = Opportunity.getSObjectType().getDescribe().fieldSets.getMap().get('Next_Strategy');
        
        List<Schema.SObjectField> oppFieldSetFieldList = Utils.fetchFieldsFromFieldSet(oppFieldSet);
        
        System.assertEquals('NextStep', oppFieldSetFieldList[0].getDescribe().getName());
    }
    
    @isTest
    static void updateRecursiveOldMapTest() {
        Utils.updateRecursiveOldMap(new Map<Id, SObject>([SELECT Id FROM Opportunity]));
    }
    
    @isTest
    static void obtainNameFieldTest() {
        System.assertEquals('Name', Utils.obtainNameField(Opportunity.getSobjectType()));
    }
    
    @isTest
    static void getAllObjectFieldsApiNamesTest() {
        System.assertEquals(true, Utils.getAllObjectFieldsApiNames('Opportunity').size() > 0);
    }
    
    @isTest
    static void generateRandomStringTest() {
        System.assertEquals(5, Utils.generateRandomString(5).length());
    }

    @IsTest
    static void buildPickListOptionsBySchemaTest(){
        List<Utils.PicklistValue> picklistValuesList = Utils.buildPickListOptionsBySchema(Contact.getSObjectType(), Contact.Role_in_Monday_Account__c.getDescribe().getSobjectField(), true);
        List<PicklistEntry> picklistValueInfos = Contact.Role_in_Monday_Account__c.getDescribe().picklistValues;
        System.assertEquals(picklistValueInfos.size()+1, picklistValuesList.size());
    }
}