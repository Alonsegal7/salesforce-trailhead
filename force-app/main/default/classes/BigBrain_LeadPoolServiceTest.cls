@isTest
public without sharing class BigBrain_LeadPoolServiceTest {

    @isTest
    static void testPullSignupsBatchSuccess(){
        Datetime timeToPull = Datetime.now().addMinutes(-30);
        bb_signups_controls__c cs = new bb_signups_controls__c(name = 'test', last_success_datetime__c = timeToPull, active__c = true);
        insert cs;
        
        Test.setMock(HttpCalloutMock.class, new mockPullSignupsSuccess());
        Test.startTest();
        Batch_BigBrain_PullSignups batch = new Batch_BigBrain_PullSignups();
        Database.executeBatch(batch,1);
        Test.stopTest();
        
        //success scenario - the main cs should move 15 mins forward, lead should be created, shouldn't create recovery cs
        cs = [SELECT last_success_datetime__c, active__c FROM bb_signups_controls__c WHERE Id =: cs.Id];
        System.assertEquals(timeToPull.addMinutes(15).addSeconds(1), cs.last_success_datetime__c);
        System.assertEquals(true, cs.active__c);
        
        List<Lead> newLeads = [SELECT Id,Email,FirstName,LastName,Enriched_phone__c,signup_cleanup_reason__c,CountryCode,Country,Title,Status,LeadSource,Company,MondayAccountName__c,primary_pulse_account_id__c,BB_Account_Domain__c,NumberOfEmployees,Trial_start__c,Trial_end__c FROM Lead];
        Lead l = newLeads[0];

        System.assertEquals(1, newLeads.size());
        System.assertEquals('test@somedomain123.com', newLeads[0].Email);
        System.assertEquals('0501111111', newLeads[0].Enriched_phone__c);
        System.assertEquals(null, newLeads[0].signup_cleanup_reason__c);
        System.assertEquals('John', newLeads[0].FirstName);
        System.assertEquals('Test', newLeads[0].LastName);
        System.assertEquals('FR', newLeads[0].CountryCode);
        System.assertEquals('France', newLeads[0].Country);
        System.assertEquals('business_owner', newLeads[0].Title);
        System.assertEquals('New', newLeads[0].Status);
        System.assertEquals('Big Brain - Signup', newLeads[0].LeadSource);
        System.assertEquals('test account', newLeads[0].Company);
        System.assertEquals('test account', newLeads[0].MondayAccountName__c);
        System.assertEquals('123456', newLeads[0].primary_pulse_account_id__c);
        System.assertEquals('somedomain123.com', newLeads[0].BB_Account_Domain__c);
        System.assertEquals(100, newLeads[0].NumberOfEmployees);
        System.assertNotEquals(null, newLeads[0].Trial_start__c);
        System.assertEquals(newLeads[0].Trial_start__c.addDays(14), newLeads[0].Trial_End__c);
    }

    @isTest
    static void testPullSignupsBatchHttpError(){
        Datetime timeToPull = Datetime.now().addMinutes(-30);
        bb_signups_controls__c mainCs = new bb_signups_controls__c(name = 'test', last_success_datetime__c = timeToPull, active__c = true);
        insert mainCs;

        Test.setMock(HttpCalloutMock.class, new mockPullSignupsHttpError());
        enableMockUseForBigBrainCallouts();
        
        Test.startTest();
        Batch_BigBrain_PullSignups batch = new Batch_BigBrain_PullSignups();
        Database.executeBatch(batch,1);
        Test.stopTest();

        //http error scenario - the main cs should move 15 mins forward, lead should not be created, should create a single active recovery cs with the last success timestamp of the initial timeToPull
        mainCs = [SELECT last_success_datetime__c, active__c FROM bb_signups_controls__c WHERE Id =: mainCs.Id];
        System.assertEquals(timeToPull.addMinutes(15).addSeconds(1), mainCs.last_success_datetime__c);
        System.assertEquals(true, mainCs.active__c);
        
        List<bb_signups_controls__c> recoveryCs = New List<bb_signups_controls__c>([SELECT name, last_success_datetime__c, exception_subject__c, exception_body__c, notification_sent__c, number_of_failures_in_a_row__c, active__c FROM bb_signups_controls__c WHERE is_recovery__c = TRUE]);
        System.assertEquals(1, recoveryCs.size());
        System.assertEquals(timeToPull, recoveryCs[0].last_success_datetime__c);
        System.assertEquals(true, recoveryCs[0].active__c);
        System.assertEquals(0, recoveryCs[0].number_of_failures_in_a_row__c);
        System.assertEquals('Failed signups pull from '+ string.valueOf(timeToPull.addSeconds(1)) + ' to ' + string.valueOf(timeToPull.addMinutes(15).addSeconds(1)), recoveryCs[0].exception_subject__c);
        System.assertEquals('HTTP request failure. Error code: 500', recoveryCs[0].exception_body__c);
        System.assertEquals('recovery'+string.valueOf(timeToPull), recoveryCs[0].Name);
        
        List<Lead> newLeads = new List<Lead>([SELECT Id FROM Lead]);
        System.assert(newLeads.isEmpty());
    }

    @isTest
    static void testPullSignupsBatchInternalError(){
        Datetime timeToPull = Datetime.now().addMinutes(-30);
        bb_signups_controls__c mainCs = new bb_signups_controls__c(name = 'test', last_success_datetime__c = timeToPull, active__c = true);
        insert mainCs;

        Test.setMock(HttpCalloutMock.class, new mockPullSignupsInternalError());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_PullSignups batch = new Batch_BigBrain_PullSignups();
        Database.executeBatch(batch,1);
        Test.stopTest();

        //internal error scenario - the main cs should move 15 mins forward, lead should not be created, should create a single active recovery cs with the last success timestamp of the initial timeToPull
        mainCs = [SELECT last_success_datetime__c, active__c FROM bb_signups_controls__c WHERE Id =: mainCs.Id];
        System.assertEquals(timeToPull.addMinutes(15).addSeconds(1), mainCs.last_success_datetime__c);
        System.assertEquals(true, mainCs.active__c);
        
        List<bb_signups_controls__c> recoveryCs = New List<bb_signups_controls__c>([SELECT name, last_success_datetime__c, exception_subject__c, exception_body__c, notification_sent__c, number_of_failures_in_a_row__c, active__c FROM bb_signups_controls__c WHERE is_recovery__c = TRUE]);
        System.assertEquals(1, recoveryCs.size());
        System.assertEquals(timeToPull, recoveryCs[0].last_success_datetime__c);
        System.assertEquals(true, recoveryCs[0].active__c);
        System.assertEquals(0, recoveryCs[0].number_of_failures_in_a_row__c);
        System.assertEquals('Failed signups pull from '+ string.valueOf(timeToPull.addSeconds(1)) + ' to ' + string.valueOf(timeToPull.addMinutes(15).addSeconds(1)), recoveryCs[0].exception_subject__c);
        System.assert(recoveryCs[0].exception_body__c.contains('Internal Exception: No content to map to Object due to end of input(System Code)'));
        System.assertEquals('recovery'+string.valueOf(timeToPull), recoveryCs[0].Name);
        
        List<Lead> newLeads = new List<Lead>([SELECT Id FROM Lead]);
        System.assert(newLeads.isEmpty());
    }

    @isTest
    static void testPullSignupsBatchSuccess_recovery(){
        Datetime timeToPull = Datetime.now().addMinutes(-30);
        bb_signups_controls__c recoveryCs = new bb_signups_controls__c(name = 'test', last_success_datetime__c = timeToPull, active__c = true, is_recovery__c = true);
        insert recoveryCs;

        Test.setMock(HttpCalloutMock.class, new mockPullSignupsSuccess());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_PullSignups batch = new Batch_BigBrain_PullSignups();
        Database.executeBatch(batch,1);
        Test.stopTest();

        //success scenario - the recovery cs should be inactive, lead should be created, shouldn't create additional recovery cs
        recoveryCs = [SELECT last_success_datetime__c, active__c FROM bb_signups_controls__c WHERE is_recovery__c = true];
        System.assertEquals(timeToPull, recoveryCs.last_success_datetime__c);
        System.assertEquals(false, recoveryCs.active__c);
        
        List<Lead> newLeads = [SELECT Id FROM Lead];
        System.assertEquals(1, newLeads.size());
    }

    @isTest
    static void testPullSignupsBatchError_recovery(){
        Datetime timeToPull = Datetime.now().addMinutes(-30);
        bb_signups_controls__c recoveryCs = new bb_signups_controls__c(name = 'test', last_success_datetime__c = timeToPull, active__c = true, is_recovery__c = true);
        insert recoveryCs;

        Test.setMock(HttpCalloutMock.class, new mockPullSignupsHttpError());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_PullSignups batch = new Batch_BigBrain_PullSignups();
        Database.executeBatch(batch,1);
        Test.stopTest();

        //failure scenario - the recovery cs should be active, number of attempts should be 1, lead should not be created, shouldn't create additional recovery cs
        recoveryCs = [SELECT last_success_datetime__c, active__c, number_of_failures_in_a_row__c,exception_subject__c, exception_body__c, notification_sent__c FROM bb_signups_controls__c WHERE is_recovery__c = true];
        System.assertEquals(timeToPull, recoveryCs.last_success_datetime__c);
        System.assertEquals(true, recoveryCs.active__c);
        System.assertEquals(1, recoveryCs.number_of_failures_in_a_row__c);        
        List<Lead> newLeads = [SELECT Id FROM Lead];
        System.assert(newLeads.isEmpty());
    }

    @isTest
    static void testPullSignupsBatchError_recoveryFifthAttempt(){
        Datetime timeToPull = Datetime.now().addMinutes(-30);
        bb_signups_controls__c recoveryCs = new bb_signups_controls__c(name = 'test', last_success_datetime__c = timeToPull, active__c = true, is_recovery__c = true, number_of_failures_in_a_row__c = 5);
        insert recoveryCs;

        Test.setMock(HttpCalloutMock.class, new mockPullSignupsHttpError());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_PullSignups batch = new Batch_BigBrain_PullSignups();
        Database.executeBatch(batch,1);
        Test.stopTest();

        //failure scenario - the recovery cs should be inactive, number of attempts should be 5, lead should not be created, shouldn't create additional recovery cs
        recoveryCs = [SELECT last_success_datetime__c, active__c, number_of_failures_in_a_row__c,exception_subject__c, exception_body__c, notification_sent__c FROM bb_signups_controls__c WHERE is_recovery__c = true];
        System.assertEquals(timeToPull, recoveryCs.last_success_datetime__c);
        System.assertEquals(false, recoveryCs.active__c);
        System.assertEquals(5, recoveryCs.number_of_failures_in_a_row__c);        
        List<Lead> newLeads = [SELECT Id FROM Lead];
        System.assert(newLeads.isEmpty());
    }

    @isTest
    static void testPullSignupsSchedule(){
        Test.setMock(HttpCalloutMock.class, new mockPullSignupsSuccess());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_PullSignups p = new Batch_BigBrain_PullSignups();
        String sch = '0 15 * * * ?';
        system.schedule('Pull Signups Test', sch, p);
        Test.stopTest();
    }
    
    @isTest
    static void testRefreshSignupsScoreBatchSuccess(){
        Lead l = new Lead(
            LastName = 'test',
            Email = 'test@test.com',
            RecordTypeId = utilities.preLeadRecordTypeId,
            Status = 'Received',
            LeadSource = 'Big Brain - Signup',
            Company = 'test',
            primary_pulse_account_id__c = '123456',
            Created_From_Pull_Signups_BB__c = true
        );
        insert l;

        Test.setMock(HttpCalloutMock.class, new mockRefreshSignupsSuccess());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_RefreshSignups batch = new Batch_BigBrain_RefreshSignups(false);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        //refresh score success scenario - should update Current_score__c, Engagement__c, NumberOfEmployees and Last_Refresh_Data_From_BB__c
        Lead newLead = [SELECT Id, Current_score__c, Engagement__c, NumberOfEmployees, Last_Refresh_Data_From_BB__c, BB_Account_Domain__c FROM Lead];
        System.assertEquals(50, newLead.Current_score__c);
        System.assertEquals(100, newLead.Engagement__c);
        System.assertEquals(20, newLead.NumberOfEmployees);
        System.assertEquals(Date.today(), newLead.Last_Refresh_Data_From_BB__c.date());
    }
    
    @isTest
    static void testRefreshSignupsDomainBatchSuccess(){
        Lead l = new Lead(
            LastName = 'test',
            Email = 'test@test.com',
            RecordTypeId = utilities.rawSignupRecordTypeId,
            Status = 'Received',
            LeadSource = 'Big Brain - Signup',
            Company = 'test',
            primary_pulse_account_id__c = '123456',
            Signup_Cleanup_Reason__c = 'domain_null',
            Created_From_Pull_Signups_BB__c = true
        );
        insert l;

        Test.setMock(HttpCalloutMock.class, new mockRefreshSignupsSuccess());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_RefreshSignups batch = new Batch_BigBrain_RefreshSignups(true);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        //refresh domain success scenario - should update BB_Account_Domain__c, Signup_Cleanup_Reason__c and Last_Refresh_Data_From_BB__c
        Lead newLead = [SELECT Id, Current_score__c, Engagement__c, NumberOfEmployees, Last_Refresh_Data_From_BB__c, BB_Account_Domain__c, Signup_Cleanup_Reason__c FROM Lead];
        System.assertEquals('somedomain123.com', newLead.BB_Account_Domain__c);
        System.assert(String.isBlank(newLead.Signup_Cleanup_Reason__c));
        System.assertEquals(Date.today(), newLead.Last_Refresh_Data_From_BB__c.date());
        System.assertEquals(null, newLead.Current_score__c);
        System.assertEquals(null, newLead.Engagement__c);
        System.assertEquals(null, newLead.NumberOfEmployees);
    }
    
    @isTest
    static void testRefreshSignupsBatchError(){
        Lead l = new Lead(
            LastName = 'test',
            Email = 'test@test.com',
            RecordTypeId = utilities.preLeadRecordTypeId,
            Status = 'Received',
            LeadSource = 'Big Brain - Signup',
            Company = 'test',
            primary_pulse_account_id__c = '123456',
            Created_From_Pull_Signups_BB__c = true
        );
        insert l;
        Test.setMock(HttpCalloutMock.class, new mockRefreshSignupsError());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_RefreshSignups batch = new Batch_BigBrain_RefreshSignups(false);
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }
    
    @isTest
    static void testRefreshSignupsSchedule(){
        Test.setMock(HttpCalloutMock.class, new mockPullSignupsSuccess());
        enableMockUseForBigBrainCallouts();
        Test.startTest();
        Batch_BigBrain_RefreshSignups p = new Batch_BigBrain_RefreshSignups(false);
        String sch = '0 15 * * * ?';
        system.schedule('Refresh Signups Test', sch, p);
        Test.stopTest();
    }

    //Inner mock classes
    public class mockRefreshSignupsSuccess implements HttpCalloutMock{
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

    public class mockRefreshSignupsError implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Error');
            return res;
        }
    }

    public class mockPullSignupsSuccess implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            BigBrain_LeadPoolService.Signup su = new BigBrain_LeadPoolService.Signup();
            su.user = new BigBrain_LeadPoolService.UserObj();
            su.user.data = new BigBrain_LeadPoolService.UserData();
            su.user.data.enriched_phone = '0501111111';
            su.user.data.email = 'test@somedomain123.com';
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

    public class mockPullSignupsInternalError implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('invalid body');
            return res;
        }   
    }

    public class mockPullSignupsHttpError implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Error');
            return res;
        }   
    }

    static void enableMockUseForBigBrainCallouts() {
        BigBrainAPI.sendBlankHttpResponseForTests = false;
    }

    //add inner mock class for pull failure
    //add inner mock class for refresh failure
    //rename the existing ones to success
    //add asserts
}