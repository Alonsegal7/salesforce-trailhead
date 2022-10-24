@isTest
public without sharing class LeanData_PoolSettingsTest {

    @TestSetup
    static void makeData()
    {        
        List<User> salesUsers = [SELECT Id FROM USER WHERE group__c = 'Sales' AND IsActive = true LIMIT 2];
        User salesUser1 = salesUsers[0];
        User salesUser2 = salesUsers[1];
        User partnerUser = TestObjectCreator.createValidPartnerUser();
        Account partnerCompany = [SELECT Id FROM Account WHERE Name = 'testPartner'];
        Partner_Country_Quota__c pcq = new Partner_Country_Quota__c(Name='Country Quota', Country_Daily_Quota__c=100);
        insert pcq;
        Partner_Region__c partnerRegion = new Partner_Region__c(Name='test (Spain)', Country__c = 'ES', Partner_Company__c = partnerCompany.Id, Partner_Country_Quota__c=pcq.Id, Main_User__c = partnerUser.Id, Daily_Leads_Quota__c = 15, Current_Daily_Leads_Quota__c = 10);
        Partner_Region__c partnerRegion2 = new Partner_Region__c(Name='test (Brazil)', Country__c = 'BR', Partner_Company__c = partnerCompany.Id, Partner_Country_Quota__c=pcq.Id, Main_User__c = partnerUser.Id, Daily_Leads_Quota__c = 10, Current_Daily_Leads_Quota__c = 2);
        Partner_Region__c partnerRegion3 = new Partner_Region__c(Name='test (France)', Country__c = 'FR', Partner_Company__c = partnerCompany.Id, Partner_Country_Quota__c=pcq.Id, Main_User__c = partnerUser.Id, Daily_Leads_Quota__c = 10, Current_Daily_Leads_Quota__c = 2);
        insert new List<Partner_Region__c>{partnerRegion, partnerRegion2, partnerRegion3};
        Lead_Quota__c lq1 = new Lead_Quota__c(Current_Sign_Up_Quota__c = 5, Sign_Up_Daily_Quota__c = 10, User__c = salesUser1.Id, Name = 'a3e5t00000088a1');
        Lead_Quota__c lq2 = new Lead_Quota__c(Current_Sign_Up_Quota__c = 15, Sign_Up_Daily_Quota__c = 2, User__c = salesUser2.Id, Name = 'a3e5t00000088a2');
        insert new List<Lead_Quota__c>{lq1, lq2};
        LeanData__Round_Robin_Pool__c rrPoolES = new LeanData__Round_Robin_Pool__c(Name = 'a3b5t0000005CYm', LeanData__Grouping_Name__c = 'S&P-ES-FR-MM', LeanData__Object_Type__c = 'Lead', Country__c = 'ES');
        LeanData__Round_Robin_Pool__c rrPoolBR = new LeanData__Round_Robin_Pool__c(Name = 'a3b5t0000005CYn', LeanData__Grouping_Name__c = 'S&P-BR-MM', LeanData__Object_Type__c = 'Lead', Country__c = 'BR');
        LeanData__Round_Robin_Pool__c rrPoolFR = new LeanData__Round_Robin_Pool__c(Name = 'a3b5t0000005CYo', LeanData__Grouping_Name__c = 'S&P-FR-MM', LeanData__Object_Type__c = 'Lead', Country__c = 'FR');
        insert new List<LeanData__Round_Robin_Pool__c>{rrPoolBR, rrPoolES, rrPoolFR};
        LeanData__Round_Robin_Setting__c rrSettingPartnerES = new LeanData__Round_Robin_Setting__c(Name = 'a3e5t00000088mo', LeanData__Pool__c = rrPoolES.Id, LeanData__OwnerId__c = partnerUser.Id, LeanData__Status__c = 'Unavailable');
        LeanData__Round_Robin_Setting__c rrSettingPartnerBR = new LeanData__Round_Robin_Setting__c(Name = 'a3e5t00000088mq', LeanData__Pool__c = rrPoolBR.Id, LeanData__OwnerId__c = partnerUser.Id, LeanData__Status__c = 'Available');
        LeanData__Round_Robin_Setting__c rrSettingPartnerFR = new LeanData__Round_Robin_Setting__c(Name = 'a3e5t00000088mw', LeanData__Pool__c = rrPoolFR.Id, LeanData__OwnerId__c = partnerUser.Id, LeanData__Status__c = 'Available');
        LeanData__Round_Robin_Setting__c rrSettingSales1 = new LeanData__Round_Robin_Setting__c(Name = 'a3e5t00000088mp', LeanData__Pool__c = rrPoolES.Id, LeanData__OwnerId__c = salesUser1.Id, LeanData__Status__c = 'Available');
        LeanData__Round_Robin_Setting__c rrSettingSales2 = new LeanData__Round_Robin_Setting__c(Name = 'a3e5t00000088ml', LeanData__Pool__c = rrPoolBR.Id, LeanData__OwnerId__c = salesUser2.Id, LeanData__Status__c = 'Unavailable');
        insert new List<LeanData__Round_Robin_Setting__c>{rrSettingPartnerES, rrSettingPartnerBR, rrSettingPartnerFR, rrSettingSales1, rrSettingSales2};
    }

    @isTest
    static void shouldResetDailyCaps() {
        
        Double sumOfQuotaBeforeResetSales = (Double)[SELECT SUM(Sign_Up_Daily_Quota__c)sum FROM Lead_Quota__c][0].get('sum');
        Double sumOfQuotaBeforeResetPartners = (Double)[SELECT SUM(Daily_Leads_Quota__c)sum FROM Partner_Region__c][0].get('sum');
        
        Test.startTest();  
        LeanData_PoolSettings p = new LeanData_PoolSettings();
        String sch = '0 0 * * * ?';
        String jobId = System.schedule('TestScheduled', sch, p);
        
        Test.stopTest();
        //check that all the caps were reset to 0 and that the quotas were'nt reser
        Double sumOfQuotaAfterResetSales = (Double)[SELECT SUM(Sign_Up_Daily_Quota__c)sum FROM Lead_Quota__c][0].get('sum');
        Double sumOfCapsAfterResetSales = (Double)[SELECT SUM(Current_Sign_Up_Quota__c)sum FROM Lead_Quota__c][0].get('sum');
        Double sumOfQuotaAfterResetPartners = (Double)[SELECT SUM(Daily_Leads_Quota__c)sum FROM Partner_Region__c][0].get('sum');
        Double sumOfCapsAfterResetPartners = (Double)[SELECT SUM(Current_Daily_Leads_Quota__c)sum FROM Partner_Region__c][0].get('sum');

        System.assertEquals(0, sumOfCapsAfterResetSales);
        System.assertEquals(0, sumOfCapsAfterResetPartners);
        System.assertEquals(sumOfQuotaBeforeResetSales, sumOfQuotaAfterResetSales);
        System.assertEquals(sumOfQuotaBeforeResetPartners, sumOfQuotaAfterResetPartners);
    }
    
    
    @isTest
    static void shouldSetAvailability() {
        //we want to check that LQ and PR with positive quota are set to availble and those with 0 quota are unavailable
        Lead_Quota__c LQ1 = [SELECT Id, Current_Sign_Up_Quota__c, Sign_Up_Daily_Quota__c, User__c FROM Lead_Quota__c WHERE Name = 'a3e5t00000088a1'];
        LQ1.Sign_Up_Daily_Quota__c = 0;
        Partner_Region__c PR1 = [SELECT Id, Daily_Leads_Quota__c, Current_Daily_Leads_Quota__c, Main_User__c, Country__c FROM Partner_Region__c WHERE Name='test (Spain)'];
        PR1.Daily_Leads_Quota__c = 0;
        update new List<SObject>{LQ1,PR1};
        
        Test.startTest();
        LeanData_PoolSettings p = new LeanData_PoolSettings();
        String sch = '0 0 * * * ?';
        String jobId = System.schedule('TestScheduled', sch, p);
        Test.stopTest();

        List<LeanData__Round_Robin_Setting__c> allRRS = [SELECT Id, LeanData__Status__c, LeanData__Inactive_Reason__c, LeanData__Pool__r.country__c, LeanData__User_Owner__c FROM LeanData__Round_Robin_Setting__c];
        Map<Id,List<LeanData__Round_Robin_Setting__c>> userIdToRRS = new Map<Id,List<LeanData__Round_Robin_Setting__c>>(); //the map has a list of RRS as values because partner users can appear in multiple RRSs, one per country
        for (LeanData__Round_Robin_Setting__c rrs : allRRS) {
            if(userIdToRRS.containsKey(rrs.LeanData__User_Owner__c)) {
                userIdToRRS.get(rrs.LeanData__User_Owner__c).add(rrs);
            }
            else {
                userIdToRRS.put(rrs.LeanData__User_Owner__c, new List<LeanData__Round_Robin_Setting__c>{rrs});
            }
        }
        List<Lead_Quota__c> allLQs = [SELECT Id, Current_Sign_Up_Quota__c, Sign_Up_Daily_Quota__c, User__c FROM Lead_Quota__c];
        for (Lead_Quota__c lq : allLQs) {
            LeanData__Round_Robin_Setting__c relevantRRS = userIdToRRS.get(lq.User__c)[0]; //for sales there will always be 1 RRS per user
            checkStatusValidity(lq.Sign_Up_Daily_Quota__c, relevantRRS.LeanData__Status__c, relevantRRS.LeanData__Inactive_Reason__c);
        }
        List<Partner_Region__c> allPRs = [SELECT Id, Daily_Leads_Quota__c, Current_Daily_Leads_Quota__c, Main_User__c, Country__c FROM Partner_Region__c];
        for (Partner_Region__c pr : allPRs) {
            LeanData__Round_Robin_Setting__c relevantRRS = new LeanData__Round_Robin_Setting__c();
            List<LeanData__Round_Robin_Setting__c> userRRSs = userIdToRRS.get(pr.Main_User__c); //for partner there can be more then 1 RRS per user, user+country combo will be unique
            for (LeanData__Round_Robin_Setting__c rrs : userRRSs) {
                if (rrs.LeanData__Pool__r.country__c == pr.Country__c) {
                    relevantRRS = rrs;
                    checkStatusValidity(pr.Daily_Leads_Quota__c, relevantRRS.LeanData__Status__c, relevantRRS.LeanData__Inactive_Reason__c);
                    break;
                }
            }
        }
    }
    
    static void checkStatusValidity(Decimal quota, String status, String statusReason) {
        if (quota == 0) {
            System.assertEquals('Unavailable', status);
            System.assertEquals('["Lead Cap at 0 - Daily Reset"]', statusReason);
        } else {
            System.assertEquals('Available', status);
            System.assert(String.isBlank(statusReason));
        }
    }

    @isTest
    static void shouldUpdatePoolOwnerWhenPartnerRegionMainUserChanges() 
    {    
        //create another partner user in the same partner company and make this user a Main User on the partner region, this should update the corresponding LD pool setting
        Account partnerCompany = [SELECT Id FROM Account WHERE Name = 'testPartner'];
        Contact con = new Contact(Email='demo2@randomdemodomain.com', FirstName = 'test', LastName = 'bla2', AccountId = partnerCompany.Id);
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community Custom'];
        User manager2 = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name='Channel Managers' LIMIT 1];
        User partnerUser1 = [SELECT Id FROM User WHERE Email='demo1@randomdemodomain.com'];
        User partnerUser2 = new User(ContactId = con.Id, Alias='standt2', ManagerId=manager2.Id, Country='United Kingdom',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing1231@monday.com');
        insert partnerUser2;
        Partner_Region__c partnerRegion = [SELECT Id FROM Partner_Region__c WHERE Name = 'test (Spain)'];

        Test.startTest();
        partnerRegion.Main_User__c = partnerUser2.Id;
        update partnerRegion;
        Test.stopTest();

        LeanData__Round_Robin_Setting__c rrSettingES = [SELECT Id, LeanData__OwnerId__c FROM LeanData__Round_Robin_Setting__c WHERE Name = 'a3e5t00000088mo'];
        LeanData__Round_Robin_Setting__c rrSettingBR = [SELECT Id, LeanData__OwnerId__c FROM LeanData__Round_Robin_Setting__c WHERE Name = 'a3e5t00000088mq'];
        System.assertEquals(partnerUser2.Id, rrSettingES.LeanData__OwnerId__c);
        System.assertEquals(partnerUser1.Id, rrSettingBR.LeanData__OwnerId__c); //check that the owner wasn't changed on a different pool user1 was assigned to
    }

    @isTest
    static void prDailyQuotaChanged(){
        Partner_Region__c partnerRegion = [SELECT Id, Country__c, Main_User__c FROM Partner_Region__c WHERE Name='test (Brazil)'];
        LeanData__Round_Robin_Setting__c getRRSBefore = [SELECT Id, LeanData__OwnerId__c, LeanData__Grouping_Name__c, LeanData__Pool__c, LeanData__Pool__r.Country__c, LeanData__Status__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__OwnerId__c = :partnerRegion.Main_User__c AND LeanData__Pool__r.Country__c = :partnerRegion.Country__c ];
        
        Partner_Region__c partnerRegion3 = [SELECT Id, Country__c, Main_User__c FROM Partner_Region__c WHERE Name='test (France)'];
        LeanData__Round_Robin_Setting__c getRRSBeforeFR = [SELECT Id, LeanData__OwnerId__c, LeanData__Grouping_Name__c, LeanData__Pool__c, LeanData__Pool__r.Country__c, LeanData__Status__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__OwnerId__c = :partnerRegion3.Main_User__c AND LeanData__Pool__r.Country__c = :partnerRegion3.Country__c ];

        Test.startTest();
        partnerRegion.Daily_Leads_Quota__c = 0;
        partnerRegion3.Daily_Leads_Quota__c = 7;
        update partnerRegion;
        update partnerRegion3;
        Test.stopTest();

        LeanData__Round_Robin_Setting__c getRRS = [SELECT Id, LeanData__OwnerId__c, LeanData__Grouping_Name__c, LeanData__Pool__c, LeanData__Pool__r.Country__c, LeanData__Status__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__OwnerId__c = :partnerRegion.Main_User__c AND LeanData__Pool__r.Country__c = :partnerRegion.Country__c];
        LeanData__Round_Robin_Setting__c getRRSFR = [SELECT Id, LeanData__OwnerId__c, LeanData__Grouping_Name__c, LeanData__Pool__c, LeanData__Pool__r.Country__c, LeanData__Status__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__OwnerId__c = :partnerRegion3.Main_User__c AND LeanData__Pool__r.Country__c = :partnerRegion3.Country__c];

        System.assertEquals('Unavailable', getRRS.LeanData__Status__c);
        System.assertEquals('Available', getRRSFR.LeanData__Status__c);
    }
}