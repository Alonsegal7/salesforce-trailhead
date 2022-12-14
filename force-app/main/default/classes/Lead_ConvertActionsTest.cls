@isTest
public without sharing class Lead_ConvertActionsTest {
    @testSetup
    static void setup() {
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        Id partnerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        Lead newLead = new Lead(LastName='LeadForTest', Status='Received', LeadSource='Other', Company='LeadForTest', Email='lead@test.for', Related_Company__c = company.Id, recordTypeId=partnerLeadRecordTypeId);
        insert newLead;
        
        FeedItem item = new FeedItem();
        item.ParentId = newLead.Id;
        item.CreatedById = UserInfo.getUserId();
        item.Body = '<p><b>FeedItem</b></p>';
        item.isRichText = true;
        insert item;
        
        FeedComment fc = new FeedComment();
        fc.CommentBody = 'Nice';
        fc.FeedItemId = item.Id;
        insert fc;
    }
    
    @isTest
    static void test() {
        Test.startTest();
        Lead thisLead = [SELECT Id FROM Lead WHERE LastName='LeadForTest' LIMIT 1];
        FeedItem fiOrig = [SELECT Id, ParentId, Body FROM FeedItem WHERE ParentId = :thisLead.Id LIMIT 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(thisLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='LeadForTest' LIMIT 1];
        System.assert(opp != null);
        
        FeedItem fi = [SELECT Id, ParentId, Body FROM FeedItem WHERE ParentId = :opp.Id LIMIT 1];
        System.assertEquals(fiOrig.Body, fi.Body);
        Test.stopTest();
    }
}