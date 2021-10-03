@isTest
public class PartnerCommission_CreateFromOpp_Test {
    private static final Id OPP_PARTNER_RT_CONST = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
    private static final Id OPP_INTERNAL_RT_CONST = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
    private static final Id ACC_MA_RT_CONST = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
    private static final Id ACC_PARTNER_COMP_RT_CONST = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Map<String, Schema.RecordTypeInfo> accountRecordTypesMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();

        //create THs
        List<GB_Threshold__c> ths = new List<GB_Threshold__c>();
        GB_Threshold__c th = TestObjectCreator.CreateGBThreshold('Partner_Opportunity');
        th.Source_Type__c = 'Inbound';
        ths.add(th);
        GB_Threshold__c th2 = TestObjectCreator.CreateGBThreshold('Partner_Opportunity');
        th2.Source_Type__c = 'Outbound';
        ths.add(th2);
        insert ths;

        //create commission model
        Commission_Model__c commissionModel = new Commission_Model__c(Partner_Tier__c = 'Platinum', Name = 'test', Outbound_Percent__c = 30, Inbound_Percent__c	= 20, Is_Active__c = true, Commission_Type__c = 'One Time', Effective_Start_Date__c = Date.today());
        insert commissionModel;

        //create partner company
        List<Account> partnersList = new List<Account>();
        partnersList.add(new Account(Name = 'testPartner', RecordTypeId = ACC_PARTNER_COMP_RT_CONST));
        insert partnersList;
    
        //create partner commission model
        List<Partner_Commission_Model__c> pcmList = new List<Partner_Commission_Model__c>();
        pcmList.add(new Partner_Commission_Model__c(Commission_Model__c = commissionModel.Id, Partner_Company__c = partnersList.get(0).Id, Start_Date__c = Datetime.now()));
        insert pcmList;

        Contact con = new Contact(Email='demo1@randomdemodomain.com', FirstName = 'test', LastName = 'bla', AccountId = partnersList.get(0).Id);
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community Custom'];
        User manager2 = [select Id from User where IsActive = true and Profile.Name='Channel Managers' limit 1];
		User user = new User(ContactId = con.Id, Alias='standt1', ManagerId=manager2.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;

        //create monday account
        Account mondayAcc = new Account(OwnerId = user.Id, Name = 'testMOnday', RecordTypeId = ACC_MA_RT_CONST, primary_pulse_account_id__c = '12345', Account_Source_Type__c = 'Inbound', Sign_Up_Date__c = Date.today());
        insert mondayAcc;

        Opportunity internalOpp = TestObjectCreator.CreateOpp(mondayAcc);
        internalOpp.RecordTypeId = OPP_INTERNAL_RT_CONST;
        internalOpp.Potential_GB_Opp_Override__c = 'Yes';
        internalOpp.OwnerId = user.Id;
        insert internalOpp;

        internalOpp.StageName = 'Closed Won';
        internalOpp.Transition_to_GB__c = true;
        internalOpp.Is_Potential_GB_Opportunity__c = true;
        internalOpp.Claimed_ARR__c = 10000;
        internalOpp.main_co_sell_opportunity__c = true;
        update internalOpp;

        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = OPP_PARTNER_RT_CONST;
        opp.Potential_GB_Opp_Override__c = 'Yes';
        opp.OwnerId = user.Id;
        insert opp;

        List<Subscription__c> subList = new List<Subscription__c>();
        Subscription__c sub1 = TestObjectCreator.CreateSubscription();
        sub1.Claimed_On_Opportunity__c = opp.Id;
        sub1.Activation_Date__c = Date.today();
        Subscription__c sub2 = TestObjectCreator.CreateSubscription();
        sub2.Pulse_Account_Id__c = '101010';
        sub2.Claimed_On_Opportunity__c = opp.Id;
        sub2.Activation_Date__c = Date.today().addDays(-1);
        subList.add(sub1);
        subList.add(sub2);
        insert subList;
    }

    static testmethod void testFirstPartnerCommissionCreation(){
        Opportunity opp = [select Id, RecordTypeId from Opportunity where RecordTypeId=:OPP_PARTNER_RT_CONST limit 1];
        Opportunity internalOpp = [select Id from Opportunity where RecordTypeId =: OPP_INTERNAL_RT_CONST limit 1];
        Account partner = [select Id from Account where recordTypeId =: ACC_PARTNER_COMP_RT_CONST limit 1];
        opp.Channel_Partner__c = partner.Id;
        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Is_Potential_GB_Opportunity__c = true;
        opp.Claimed_ARR__c = 10000;
        opp.co_sell_opportunity__c = internalOpp.Id;
        Test.startTest();
        update opp;
        Test.stopTest();

        List<Partner_Commission__c> pcList = [select Id from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
    }
}
