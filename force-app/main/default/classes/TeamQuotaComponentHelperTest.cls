@isTest
public with sharing class TeamQuotaComponentHelperTest {

    @isTest
    static void getMyTeamQuoatsTest(){
        Test.startTest();
        User tm = [select Id from User where IsActive = true limit 1];

        User testUser = new User(
            FirstName = 'User T1',
            LastName = 'ACME',
            Email = 'usert1@acme.com',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true,
            Username = 'usert1@acme.com',
            Alias = 'UACME',
            Country = 'Israel',
            LanguageLocaleKey = UserInfo.getLanguage(),
            LocaleSidKey = UserInfo.getLocale(),
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Argentina/Buenos_Aires',
            CurrencyIsoCode = 'USD',
            ManagerId = tm.Id
        );

        insert testUser;
        
        System.assertEquals(TeamQuotaComponentHelper.getMyTeamQuoats(tm.Id)[0].ManagerId, tm.Id);
        Test.stopTest();
    }

    @istest
    static void getAVGDistributedScoreTest(){

        Test.startTest();

        User tm = [select Id from User where IsActive = true limit 1];

        User testUser = new User(
            FirstName = 'User T1',
            LastName = 'ACME',
            Email = 'usert1@acme.com',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true,
            Username = 'usert1@acme.com',
            Alias = 'UACME',
            Country = 'Israel',
            LanguageLocaleKey = UserInfo.getLanguage(),
            LocaleSidKey = UserInfo.getLocale(),
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Argentina/Buenos_Aires',
            CurrencyIsoCode = 'USD',
            ManagerId = tm.Id
        );
        insert testUser;

        Lead lead = new Lead(
            Company='leadWithPhone',
            NumberOfEmployees=65,
            LastName='LastName',
            Email='test@test.com',
            Phone='12345678',
            LeadSource='Big Brain - Signup',
            visitor_id__c='123',
            Sub_source__c='Sign up', 
            Channel_Lead_Source__c = 'Outbound',
            OwnerId=testUser.Id,
            Status='Attempting',
            SQL__c=true,
            Hubspot_Lifecycle_stage__c='marketingqualifiedlead',
            Distributed_score__c = 100,
            Created_From_Pull_Signups_BB__c = true,
            Distribution_reason__c = 'New lead',
            Received_Timestamp_DT__c=Datetime.now()
            );

            insert lead;
            System.assertEquals(TeamQuotaComponentHelper.getAVGDistributedScore(tm.Id)[0].get('expr0'), lead.Distributed_score__c);

            Test.stopTest();
    }

    @isTest
    static void getCountriesAndSegmentTest(){
        Test.startTest();
        User tm = [select Id from User where IsActive = true limit 1];

        User testUser = new User(
            FirstName = 'User T1',
            LastName = 'ACME',
            Email = 'usert1@acme.com',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true,
            Username = 'usert1@acme.com',
            Alias = 'UACME',
            Country = 'Israel',
            LanguageLocaleKey = UserInfo.getLanguage(),
            LocaleSidKey = UserInfo.getLocale(),
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Argentina/Buenos_Aires',
            CurrencyIsoCode = 'USD',
            ManagerId = tm.Id,
            Office__c = 'London Office'
        );
        insert testUser;

        LeanData__Round_Robin_Pool__c rrpool = new LeanData__Round_Robin_Pool__c();
        rrpool.LeanData__Grouping_Name__c = 'S&P-FR-Test';
        rrpool.LeanData__Object_Type__c = 'Lead';
        rrpool.Country__c = 'FR';
        rrpool.Segment__c='1500+';
        insert rrpool;

        LeanData__Round_Robin_Setting__c rrs = new LeanData__Round_Robin_Setting__c();
        rrs.LeanData__OwnerId__c = testUser.Id;
        rrs.LeanData__User_Owner__c = testUser.Id;
        rrs.LeanData__Pool__c = rrpool.Id;
        rrs.Set_Current_Day_Timestamp__c = System.Now().addDays(-5);
        rrs.Name = 'Test';
        insert rrs;
        System.debug(rrs);

        System.assertEquals(TeamQuotaComponentHelper.getCountriesAndSegment(tm.Id)[0].get('Country__c'), rrpool.Country__c);
    }
}
