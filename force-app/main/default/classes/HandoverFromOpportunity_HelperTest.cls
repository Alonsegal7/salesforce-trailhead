@isTest
public without sharing class HandoverFromOpportunity_HelperTest {
    
    @TestSetup
    static void makeData(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = TestUtils.getUserWithoutRole(profileId);
        user.Office__c = 'Tel Aviv Office';
        insert user;
        
        Account comp = TestObjectCreator.CreateCompany();
        comp.Name = 'testco1';
        comp.OwnerId = user.Id;
        insert comp;

        Account mondayAcc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId(), Name = 'testMOnday', primary_pulse_account_id__c = '12345');
        insert mondayAcc;

        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.Company__c = comp.Id;
        opp.AccountId = mondayAcc.Id;
        opp.Name = 'testopp1';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        insert opp;

        HandoverFromOpportunity_Helper.getObHoursMap(opp.Id);
        HandoverFromOpportunity_Helper.getExistingHandoverOnOpp(opp.Id);
    }
    @isTest
    static void shouldGetPickListValues() {
        List<Object> useCasesPLV = HandoverFromOpportunity_Helper.getUseCasePLV();
        List<Object> complexityPLV = HandoverFromOpportunity_Helper.getComplexityPLV();
        System.assertNotEquals(null, useCasesPLV);
        System.assertNotEquals(null, complexityPLV);
    }
    
    @isTest
    static void shouldGetFieldMapping() {
        
        Opportunity opp = [SELECT Id, Company__c, AccountId FROM Opportunity WHERE Name = 'testopp1'];
        List<Object> fieldsMapping = HandoverFromOpportunity_Helper.getHandoverFieldMapping(opp.Id);
        System.assertNotEquals(null, fieldsMapping);
        HandoverFromOpportunity_Helper.fieldMappingWrapper currentMapping;
        for (Object mapping : fieldsMapping) {
            currentMapping = (HandoverFromOpportunity_Helper.fieldMappingWrapper) mapping;
            if (currentMapping.fieldName == 'Company__c') {
                System.assertEquals(opp.Company__c, currentMapping.fieldValue);
            }
            if (currentMapping.fieldName == 'Monday_Account__c') {
                System.assertEquals(opp.AccountId, currentMapping.fieldValue);
            }
        }
    }

    @isTest
    static void shouldCreateRecords() {

        Account comp = [SELECT Id FROM Account WHERE Name = 'testco1'];
        Handover__c ho = new Handover__c(Company__c = comp?.Id);
        insert ho;        
        Map<String, List<Map<String, Object>>> recordsToCreate = new Map<String, List<Map<String, Object>>>(); 
        List<Map<String, Object>> useCases = new List<Map<String, Object>>();
        Map<String, Object> currentUseCase = new Map<String, Object>();
        currentUseCase.put('name', 'General Project Management');
        currentUseCase.put('complex', '1- Low Effort');
        currentUseCase.put('users', '11');
        currentUseCase.put('desc', 'aa');
        currentUseCase.put('main', true);
        currentUseCase.put('handoverId', ho.Id);
        useCases.add(currentUseCase);
        recordsToCreate.put('use_cases', useCases);
        HandoverFromOpportunity_Helper.createRecords(recordsToCreate);
        List<Use_Case__c> createdUseCases = new List<Use_Case__c>([SELECT Id FROM Use_Case__c]);
        System.assertEquals(1, createdUseCases.size()); 
    }


    @isTest
    static void shouldGetQLIs() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        TestObjectCreator.persistImmediate = true;
        Quote quoteNewCont = TestObjectCreator.CreateNonContractQuote(opp, 'New Contract');
        QuoteLineItem quoteLine = TestObjectCreator.CreateQuoteLineItem(quoteNewCont, 'Onboarding', 10, 1.0);
        List<OpportunityLineItem> opportunityLines = new List<OpportunityLineItem>{ TestObjectCreator.CreateOpportunityProduct(opp, quoteLine) };
        TestObjectCreator.persistImmediate = false;
        OpportunityLineItem oli = [SELECT Id, PS_Hours__c FROM OpportunityLineItem WHERE Product_Type__c = 'Onboarding' LIMIT 1];
        oli.PS_Hours__c = 10;
        oli.Is_Primary__c = true;
        update oli;

        List<QuoteLineItem> qlisList = HandoverFromOpportunity_Helper.getCurrentQuoteLineItems(quoteNewCont.Id);
        System.assertEquals(1, qlisList.size());
        
    }

    @isTest
    static void shouldGetContactName() {
        Account mondayAcc = [SELECT Id FROM Account WHERE primary_pulse_account_id__c = '12345'];
        Contact con = new Contact(Email='demo1@randomdemodomain.com', FirstName = 'test', LastName = 'contact1', AccountId = mondayAcc.Id);
        insert con;
        String name = HandoverFromOpportunity_Helper.getContactNameById(con.Id);
        System.assertEquals('test contact1', name);
    }
}