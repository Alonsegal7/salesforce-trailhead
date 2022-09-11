@isTest
public without sharing class BigBrain_LeadPoolServiceTest {
    static testmethod void testPullSignupsBatch(){
        bb_signups_controls__c cs = new bb_signups_controls__c(
            name = 'test',
            last_success_datetime__c = Datetime.now().addMinutes(-15),
            active__c = true
        );
        insert cs;
        Test.setMock(HttpCalloutMock.class, new mockPullSignups());
        Test.startTest();
        Batch_BigBrain_PullSignups batch = new Batch_BigBrain_PullSignups();
        Database.executeBatch(batch,1);
        Test.stopTest();
    }

    static testmethod void testPullSignupsBatch_recovery(){
        bb_signups_controls__c cs = new bb_signups_controls__c(
            name = 'test',
            last_success_datetime__c = Datetime.now().addMinutes(-15),
            active__c = true,
            is_recovery__c = true
        );
        insert cs;
        Test.setMock(HttpCalloutMock.class, new mockPullSignups());
        Test.startTest();
        Batch_BigBrain_PullSignups batch = new Batch_BigBrain_PullSignups();
        Database.executeBatch(batch,1);
        Test.stopTest();
    }

    static testmethod void testPullSignupsSchedule(){
        Test.setMock(HttpCalloutMock.class, new mockPullSignups());
        Test.startTest();
        Batch_BigBrain_PullSignups p = new Batch_BigBrain_PullSignups();
        String sch = '0 15 * * * ?';
        system.schedule('Pull Signups Test', sch, p);
        Test.stopTest();
    }
    
    static testmethod void testRefreshSignupsBatch(){
        Lead l = new Lead(
            LastName = 'test',
            Email = 'test@test.com',
            RecordTypeId = utilities.preLeadRecordTypeId,
            Status = 'Received',
            LeadSource = 'Big Brain - Signup',
            Company = 'test',
            primary_pulse_account_id__c = '123456'
        );
        insert l;
        Test.setMock(HttpCalloutMock.class, new mockRefreshSignups());
        Test.startTest();
        Batch_BigBrain_RefreshSignups batch = new Batch_BigBrain_RefreshSignups(false);
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }
    
    static testmethod void testRefreshSignupsSchedule(){
        Test.setMock(HttpCalloutMock.class, new mockPullSignups());
        Test.startTest();
        Batch_BigBrain_RefreshSignups p = new Batch_BigBrain_RefreshSignups(false);
        String sch = '0 15 * * * ?';
        system.schedule('Refresh Signups Test', sch, p);
        Test.stopTest();
    }

    public class mockRefreshSignups implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            BigBrain_LeadPoolService.RefreshSignupData refData = new BigBrain_LeadPoolService.RefreshSignupData();
            refData.pulse_account_id = '123456';
            refData.domain = 'somedomain123.com';
            refData.engagements = 100;
            refData.score = 50;
            refData.score_params = new BigBrain_LeadPoolService.ScoreParams();
            refData.score_params.company_size = 20;
            list<BigBrain_LeadPoolService.RefreshSignupData> l = new list<BigBrain_LeadPoolService.RefreshSignupData>{refData};
            String str = JSON.serialize(l);
            res.setBody(str);
            res.setStatusCode(200);
            return res;
        }
    }

    public class mockPullSignups implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            BigBrain_LeadPoolService.Signup su = new BigBrain_LeadPoolService.Signup();
            su.user = new BigBrain_LeadPoolService.UserObj();
            su.user.data = new BigBrain_LeadPoolService.UserData();
            su.user.data.email = 'test@somedomain123.com';
            su.user.data.enriched_phone = '0501111111';
            su.user.data.is_gmail = false;
            su.user.data.name = 'John Test';
            su.user.data.xi_country = 'FR';
            su.user.data.computed_title = 'business_owner';
            su.user.enrichments = new BigBrain_LeadPoolService.Enrichment();
            su.account = new BigBrain_LeadPoolService.AccountObj();
            su.account.plan = new BigBrain_LeadPoolService.AccountPlan();
            su.account.partner_utm = new BigBrain_LeadPoolService.PartnerUTM();
            su.account.clearbit_enrichment = new BigBrain_LeadPoolService.ClearbitEnrichment();
            su.account.enrichments = new BigBrain_LeadPoolService.Enrichment();
            su.account.enrichments.last_enrichments = new list<BigBrain_LeadPoolService.LastEnrichment>();
            su.account.enrichments.last_enrichments_decisions = new list<BigBrain_LeadPoolService.EnrichmentDecision>();
            su.account.data = new BigBrain_LeadPoolService.AccountData();
            su.account.data.account_name = 'test account';
            su.account.data.pulse_account_id = '123456';
            su.account.data.domain = 'somedomain123.com';
            su.account.data.company_size = '100';
            su.account.data.is_blocked = false;
            su.account.data.is_student = false;
            su.account.data.standalone_products_only = false;
            su.account.data.purpose = 'Work';
            su.account.data.trial_start = Datetime.now().addMinutes(-15);
            su.account.data.created_at = Datetime.now().addMinutes(-15);
            su.account.data.extra_data = new BigBrain_LeadPoolService.AccountExtraData();

            String s = '[{';
            s += '"user":{"data":{"name":"test lead","email":"test@monday.com"}}';
            s += ',"account":{"data":{"account_name":"testcompany","is_blocked":false,"is_student":false,"standalone_products_only":false,"domain":"testbigbrainmonday.com","trial_start":"2022-08-02T11:33:13.444Z"}}';
            s += '}]';
            List<BigBrain_LeadPoolService.Signup> l = new list<BigBrain_LeadPoolService.Signup>{su};
            String str = JSON.serialize(l);
            res.setBody(str);
            res.setStatusCode(200);
            return res;
        }   
    }
}
