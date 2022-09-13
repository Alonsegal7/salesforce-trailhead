@isTest
public without sharing class UtilitiesTest {
    @TestSetup
    static void makeData(){
        Id mart = Utilities.MARecordTypeId;
        Id comprt = Utilities.CompanyRecordTypeId;
        Id acui = Utilities.AccountsPoolUserId;
        Id ptrt = Utilities.personalTargetRT;
        Id preLeadRtId = Utilities.preLeadRecordTypeId;
        Id potentialPartnerLeadRtId = Utilities.potentialPartnerLeadRecordTypeId;
        string templateText = '<messaging:emailTemplate subject="{!relatedTo.Name}" recipientType="User" relatedToType="Lead"><messaging:htmlEmailBody ><ul><li>test content</li></ul></messaging:htmlEmailBody></messaging:emailTemplate>';
        EmailTemplate t = new EmailTemplate(DeveloperName = 'TestTemplateUtilitiesTest', TemplateType= 'Visualforce', FolderId = UserInfo.getUserId(),
        Name = 'TestEmailVFTemplate',
        IsActive = true);
    
        t.Markup = templateText;
        insert t;

        Utilities.updateAndRetry(new List<EmailTemplate>{t});
        System.enqueueJob(new Utilities.updatesObjectsQueueable(new List<EmailTemplate>{t}));
    }

    static testmethod void test_createOLIfromSubscription () { 
        TestObjectCreator.persistImmediate = true;
        Account comp = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        Opportunity opp = TestObjectCreator.CreateOpp(ma);
        Subscription__c sub = TestObjectCreator.CreateSubscription();
        TestObjectCreator.persistImmediate = false;
        Pricebook2 pb2 = TestObjectCreator.CreatePricebook();
        pb2.name='testpricebook';
        pb2.isactive=true;
        pb2.Is_Main__c=true;
        insert pb2;

        Product2 prod = TestObjectCreator.CreateProduct();
        insert prod;

        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 20,
            UseStandardPrice = false,
            IsActive = true
        );
        insert standardPBE;

        Utilities.createOLIfromSubscription(opp.Id, sub, standardPBE, false);
    }
    static testmethod void testSendEmail () { 

        Account company = TestObjectCreator.CreateCompany();
        insert company;

        Id partnerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
        Lead newLead = new Lead(LastName='LeadForTest', Status='Received', LeadSource='Other', Company='LeadForTest', Email='lead@test.for', Related_Company__c = company.Id, recordTypeId=partnerLeadRecordTypeId);
        insert newLead;

        Utilities.sendEmailRequest sendEmailReq = new Utilities.sendEmailRequest();
        sendEmailReq.toAddress = new list<string>{'kseniasm@monday.com'};
        sendEmailReq.emailTempUniqName = 'TestTemplateUtilitiesTest';
        sendEmailReq.whoId = newLead.Id;
        sendEmailReq.senderDisplayName = 'test';
        List<Utilities.sendEmailRequest> sendEmailReq_list = new List<Utilities.sendEmailRequest>();
        sendEmailReq_list.add(sendEmailReq);
        Test.startTest();
        Utilities.sendEmail(sendEmailReq_list);
        Test.stopTest();
    }

    static testmethod void test_getRegionMapping() { 
        Utilities.getRegionMapping();
    }

    static testmethod void test_getAllTHs() { 
        Utilities.getAllTHs();
    }

    static testmethod void test_getAllChannelMapping() { 
        Utilities.getChannelMapping();
    }

    static testmethod void test_capitalizeString() { 
        Utilities.capitalizeString('blabla');
    }

    static testmethod void test_cleanFlexQueue() { 
        Utilities.cleanFlexQueue();
    }

    static testmethod void test_getMainPB() { 
        Utilities.getMainPB();
    }

    static testmethod void test_setPlanName() { 
        Utilities.setPlanName('test','test','test');
    }

    static testmethod void test_sendEmail() { 
        Utilities.sendEmail('subject', 'body', new List<String>{UserInfo.getUserEmail()});
        Utilities.sendEmail('subject', 'body', new List<String>{UserInfo.getUserEmail()},new List<String>{UserInfo.getUserEmail()});
    }

    static testmethod void test_convertDatetimeToDate() { 
        Utilities.convertDatetimeToDate(Datetime.now());
    }

    @isTest
    static void getCompanySize() {
        system.assertEquals('50-99', Utilities.getCompanySizeRange(65));
    }

    @isTest
    static void getCountriesAndStates() {
        system.assert(Utilities.allCountries().size()>0);
        system.assert(Utilities.allStates().size()>0);
    }
}