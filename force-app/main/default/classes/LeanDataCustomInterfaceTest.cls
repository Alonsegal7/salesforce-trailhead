@isTest
private class LeanDataCustomInterfaceTest {
    static testMethod void testMiscMethods(){
        Test.startTest();
        LeanDataCustomInterface testInterface = new LeanDataCustomInterface();
        testInterface.getCustomLeadFields();
        testInterface.getMapOfCustomInterfaceNodeNamesToEdges();
        Test.stopTest();
    }
    static testMethod void testSetSpecificAvailability(){
        Test.startTest();
        LeanDataCustomInterface testInterface = new LeanDataCustomInterface();
        Map<String, SObject> chosenSObjects = new Map<String, SObject>();

        Id userId = UserInfo.getUserId();

        User u = [SELECT Id, Office__c From USER WHERE Id = :userId];
        u.Office__c = 'London Office';

        Database.update(u);

        Account company = TestObjectCreator.CreateCompany();
        insert company;
        Id partnerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        Lead newLead = new Lead(OwnerId = u.Id, LastName='LeadForTest', Status='Received', LeadSource='Other', Company='LeadForTest', Email='lead@test.for', Related_Company__c = company.Id, recordTypeId=partnerLeadRecordTypeId, Country = 'France');
        insert newLead;

        Partner_Country_Quota__c pcq = new Partner_Country_Quota__c(Country__c = 'FR', Country_Daily_Quota__c = 2, Quota_Type__c = 'Daily Quota');
        insert pcq;

        Partner_Region__c pr = new Partner_Region__c(Name = 'France', Country__c = 'FR', Main_User__c = u.Id, Daily_Leads_Quota__c = 2, Current_Daily_Leads_Quota__c = 0, Partner_Company__c = company.Id, Partner_Country_Quota__c = pcq.Id);
        insert pr;

        Lead_Quota__c lq = new Lead_Quota__c(Current_Sign_Up_Quota__c = 0, Sign_Up_Daily_Quota__c = 5, User__c = u.Id);

        LeanData__Round_Robin_Pool__c rrpool = new LeanData__Round_Robin_Pool__c();
        rrpool.LeanData__Grouping_Name__c = 'S&P-FR-Test';
        rrpool.LeanData__Object_Type__c = 'Lead';
        insert rrpool;

        LeanData__Round_Robin_Pool__c rrpool2 = new LeanData__Round_Robin_Pool__c();
        rrpool2.LeanData__Grouping_Name__c = 'Partners-FR-Test';
        rrpool2.LeanData__Object_Type__c = 'Lead';
        insert rrpool2;

        LeanData__Round_Robin_Setting__c rrs = new LeanData__Round_Robin_Setting__c();
        rrs.LeanData__OwnerId__c = u.Id;
        rrs.LeanData__User_Owner__c = u.Id;
        rrs.LeanData__Pool__c = rrpool.Id;
        rrs.Set_Current_Day_Timestamp__c = System.Now().addDays(-5);
        insert rrs;

        LeanData__Round_Robin_Setting__c rrs2 = new LeanData__Round_Robin_Setting__c();
        rrs2.LeanData__OwnerId__c = u.Id;
        rrs2.LeanData__User_Owner__c = u.Id;
        rrs2.LeanData__Pool__c = rrpool2.Id;
        rrs2.Set_Current_Day_Timestamp__c = System.Now().addDays(-5);
        insert rrs2;

        String result;
    
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Set Specific Availability - Custom Capping', null);
        System.assertEquals(result, 'Next Node');
        System.assertEquals(pr.Current_Daily_Leads_Quota__c, 0);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        System.assertEquals(pr.Current_Daily_Leads_Quota__c, 0);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        System.assertEquals(result, 'Next Node');
        u.Office__c = 'NY Office';
        Database.update(u);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Set Specific Availability - Custom Capping', null);
        System.assertEquals(pr.Current_Daily_Leads_Quota__c, 0);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        System.assertEquals(pr.Current_Daily_Leads_Quota__c, 0);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        u.Office__c = 'Sydney Office';
        Database.update(u);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Set Specific Availability - Custom Capping', null);
        System.assertEquals(pr.Current_Daily_Leads_Quota__c, 0);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        System.assertEquals(pr.Current_Daily_Leads_Quota__c, 0);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Update Capping Totals', null);
        result = testInterface.customRoutingRule(newLead, chosenSObjects, 'Bad Param', null);
        System.assertEquals(result, 'Invalid Parameter');
        Test.stopTest();
    }
}