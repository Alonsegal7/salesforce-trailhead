@isTest
public without sharing class LeanData_PoolSettingsTest {

    @TestSetup
    static void makeData()
    {        
        User partnerUser = TestObjectCreator.createValidPartnerUser();
        Account partnerCompany = [SELECT Id FROM Account WHERE Name = 'testPartner'];
        Partner_Country_Quota__c pcq = new Partner_Country_Quota__c(Name='Country Quota', Country_Daily_Quota__c=100);
        insert pcq;
        Partner_Region__c partnerRegion = new Partner_Region__c(Name='test (Spain)', Country__c = 'ES', Partner_Company__c = partnerCompany.Id, Partner_Country_Quota__c=pcq.Id, Main_User__c = partnerUser.Id);
        insert partnerRegion;
        LeanData__Round_Robin_Pool__c rrPoolES = new LeanData__Round_Robin_Pool__c(Name = 'a3b5t0000005CYm', LeanData__Grouping_Name__c = 'S&P-ES-FR-MM', LeanData__Object_Type__c = 'Lead');
        LeanData__Round_Robin_Pool__c rrPoolBR = new LeanData__Round_Robin_Pool__c(Name = 'a3b5t0000005CYn', LeanData__Grouping_Name__c = 'S&P-BR-MM', LeanData__Object_Type__c = 'Lead');
        insert new List<LeanData__Round_Robin_Pool__c>{rrPoolBR, rrPoolES};
        LeanData__Round_Robin_Setting__c rrSettingES = new LeanData__Round_Robin_Setting__c(Name = 'a3e5t00000088mo', LeanData__Pool__c = rrPoolES.Id, LeanData__OwnerId__c = partnerUser.Id);
        LeanData__Round_Robin_Setting__c rrSettingBR = new LeanData__Round_Robin_Setting__c(Name = 'a3e5t00000088mq', LeanData__Pool__c = rrPoolBR.Id, LeanData__OwnerId__c = partnerUser.Id);
        insert new List<LeanData__Round_Robin_Setting__c>{rrSettingES, rrSettingBR};
        
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
}