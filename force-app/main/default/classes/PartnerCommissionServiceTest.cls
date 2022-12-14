@isTest
public class PartnerCommissionServiceTest {
    private static final Id OPP_PARTNER_RT_CONST = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
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
        List<Commission_Model__c> cmList = new List<Commission_Model__c>();
        cmList.add(new Commission_Model__c(Partner_Tier__c = 'Gold First Year', Name = 'test', Outbound_Percent__c = 30, Inbound_Percent__c	= 20, Is_Active__c = true, Commission_Type__c = 'One Time', Effective_Start_Date__c = Date.today()));
        cmList.add(new Commission_Model__c(Partner_Tier__c = 'Silver', Name = 'test', Outbound_Percent__c = 30, Inbound_Percent__c	= 20, Is_Active__c = true, Commission_Type__c = 'One Time', Effective_Start_Date__c = Date.today()));
        cmList.add(new Commission_Model__c(Partner_Tier__c = 'Platinum', Name = 'test', Outbound_Percent__c = 35, Inbound_Percent__c	= 25, Is_Active__c = true, Commission_Type__c = 'One Time', Effective_Start_Date__c = Date.today()));
        insert cmList;

        //create partner company
        List<Account> partnersList = new List<Account>();
        partnersList.add(new Account(Name = 'testPartner', RecordTypeId = ACC_PARTNER_COMP_RT_CONST));
        partnersList.add(new Account(Name = 'testPartner2', RecordTypeId = ACC_PARTNER_COMP_RT_CONST));
        insert partnersList;
    
        for(Account partner: partnersList){
            partner.Partner_Company_Status__c = 'Signed';
            partner.Signature_Approval_Status__c = 'Approved';
        }
        update partnersList;

        Contact con = new Contact(Email='demo1@randomdemodomain.com', FirstName = 'test', LastName = 'bla', AccountId = partnersList.get(0).Id);
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community Custom'];
        User manager2 = [select Id from User where IsActive = true and Profile.Name='Channel Managers' limit 1];
		User user = new User(ContactId = con.Id, Alias='standt1', ManagerId=manager2.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;

        //create monday account
        Account mondayAcc = new Account(OwnerId = user.Id, Name = 'testMOnday', RecordTypeId = Utilities.MARecordTypeId, primary_pulse_account_id__c = '12345', Account_Source_Type__c = 'Inbound', Sign_Up_Date__c = Date.today().addMonths(-7), Plan_Period__c = 'yearly');
        insert mondayAcc;

        //create opportunity with opp.Potential_GB_Opp_Override__c=='Yes'
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = OPP_PARTNER_RT_CONST;
        opp.Potential_GB_Opp_Override__c = 'Yes';
        opp.OwnerId = user.Id;
        insert opp;

        opp.Channel_Partner__c = partnersList.get(0).Id;
        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Is_Potential_GB_Opportunity__c = true;
        opp.Claimed_ARR__c = 10000;
        update opp;
    }

    static testmethod void test_accPlanChanged(){
        Account acc = [select Id from Account where recordTypeId =: Utilities.MARecordTypeId limit 1];
        Contract cont = TestObjectCreator.CreateContract(acc);
        cont.Period__c = 'monthly';
        cont.StartDate = date.today();
        cont.endDate = date.today().addYears(1);
        insert cont;
        acc.Plan_Period__c = 'monthly';
        acc.Active_Contract__c = cont.Id;
        update acc;
    }

    static testmethod void test_PartnerCommission_renewMonthlyPCs(){
        List<Partner_Commission__c> pcList = [select Id from Partner_Commission__c];
        pcList.get(0).Is_Future_Payment__c = true;
        pcList.get(0).End_Date__c = date.today();
        update pcList;
        String sch = '0 35 11 * * ?';
        Test.startTest();
        String jobId = System.schedule('myJobTestJobName', sch, new PartnerCommission_renewMonthlyPCs());
        Database.executeBatch(new PartnerCommission_renewMonthlyPCs());
        Test.stopTest();
    }

    static testmethod void testFirstPartnerCommissionCreation(){
        Opportunity opp = [select Id, Channel_Partner__c, Transition_to_GB__c, StageName, RecordTypeId from Opportunity where RecordTypeId=:OPP_PARTNER_RT_CONST limit 1];
        System.assertNotEquals(null, opp.Channel_Partner__c);
        System.assertEquals(true, opp.Transition_to_GB__c);
        System.assertEquals('Closed Won', opp.StageName);
        List<Partner_Commission__c> pcList = [select Id, Start_Date__c from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        System.assertEquals(Date.today().addMonths(-6), pcList.get(0).Start_Date__c);
        //update MA ARR below TH
        Account mondayAcc = [select Id, Is_GB_Account_Partners__c from Account where RecordTypeId =: Utilities.MARecordTypeId limit 1];
        System.assertEquals(true, mondayAcc.Is_GB_Account_Partners__c);
        mondayAcc.ARR__c = 4000;
        mondayAcc.Last_ARR_Update_Timestamp__c = Datetime.now();
        Test.startTest();
        update mondayAcc;
        Test.stopTest();
        pcList = [select Id, End_Date__c, Account_Source__c from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        System.assertNotEquals(null, pcList.get(0).End_Date__c);
    }

    static testmethod void testAccSourceTypeChange(){
        //update MA Source Type to Outbound
        Account mondayAcc = [select Id from Account where RecordTypeId =: Utilities.MARecordTypeId limit 1];
        mondayAcc.Account_Source_Type__c = 'Outbound';
        Test.startTest();
        update mondayAcc;
        Test.stopTest();
        List<Partner_Commission__c> pcList = [select Id, Account_Source__c from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        System.assertEquals('Outbound', pcList.get(0).Account_Source__c);
    }

    static testmethod void testPartnerCommissionCreationFromARR(){
        Opportunity opp = [select Id, Channel_Partner__c, Transition_to_GB__c, StageName, RecordTypeId from Opportunity where RecordTypeId=:OPP_PARTNER_RT_CONST limit 1];
        System.assertNotEquals(null, opp.Channel_Partner__c);
        System.assertEquals(true, opp.Transition_to_GB__c);
        System.assertEquals('Closed Won', opp.StageName);
        List<Partner_Commission__c> pcList = [select Id from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        pcList.get(0).End_Date__c = Datetime.now().addSeconds(-1);
        update pcList;
        //update MA ARR above TH
        Account mondayAcc = [select Id from Account where RecordTypeId =: Utilities.MARecordTypeId limit 1];
        mondayAcc.ARR__c = 9000;
        mondayAcc.Last_ARR_Update_Timestamp__c = Datetime.now();
        Test.startTest();
        update mondayAcc;
        Test.stopTest();
        pcList = [select Id, End_Date__c from Partner_Commission__c order by End_Date__c NULLS FIRST];
        System.assertEquals(2, pcList.size());
        System.assertEquals(null, pcList.get(0).End_Date__c);
        System.assertNotEquals(null, pcList.get(1).End_Date__c);
    }

    static testmethod void testPartnerCommissionCreationFromARRWithDateNull(){
        Account mondayAcc = [select Id from Account where RecordTypeId =: Utilities.MARecordTypeId limit 1];
        mondayAcc.ARR__c = 0;
        mondayAcc.Last_ARR_Update_Timestamp__c = null;
        Test.startTest();
        update mondayAcc;
        System.debug(mondayAcc);
        Test.stopTest();
        List<Partner_Commission__c> pcList = [select Id, End_Date__c from Partner_Commission__c order by End_Date__c NULLS FIRST];
        System.assertEquals(1, pcList.size());
        System.assertNotEquals(null, pcList.get(0).End_Date__c);
    }

    static testmethod void testPartnerTransfer(){
        Opportunity opp = [select Channel_Partner__c from Opportunity limit 1];
        Account mondayAcc = [select Id from Account where Channel_Partner__c =: opp.Channel_Partner__c limit 1];
        Account partnerAcc = [select Id from Account where Id !=: opp.Channel_Partner__c and Id !=: mondayAcc.Id limit 1];
        mondayAcc.Channel_Partner__c = partnerAcc.Id;
        mondayAcc.Last_ARR_Update_Timestamp__c = Datetime.now();
        Test.startTest();
        update mondayAcc;
        Test.stopTest();
        List<Partner_Commission__c> pcList = [select Id, End_Date__c, Partner_Company__c from Partner_Commission__c order by End_Date__c NULLS FIRST];
        System.assertEquals(2, pcList.size());
        System.assertEquals(null, pcList.get(0).End_Date__c);
        System.assertEquals(partnerAcc.Id, pcList.get(0).Partner_Company__c);
        System.assertNotEquals(null, pcList.get(1).End_Date__c);
        System.assertEquals(opp.Channel_Partner__c, pcList.get(1).Partner_Company__c);
    }

    static testmethod void testPartnerTermination(){
        Opportunity opp = [select Channel_Partner__c from Opportunity limit 1];
        Account acc = new Account(Id = opp.Channel_Partner__c, Partner_Company_Status__c = 'Terminated');
        Test.startTest();
        update acc;
        Test.stopTest();
        List<Partner_Commission__c> pcList = [select Id, End_Date__c from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        System.assertNotEquals(null, pcList.get(0).End_Date__c);
    }

    static testmethod void testPcCreationWithOverlap(){
        Commission_Model__c cm = [select Id from Commission_Model__c limit 1];
        Account acc = [select Id from Account limit 1];
        Partner_Commission_Model__c pcm = new Partner_Commission_Model__c(Commission_Model__c = cm.Id, Partner_Company__c = acc.Id, Start_Date__c = Datetime.now());
        try{
            insert pcm;
        } catch (Exception e){
            
        }
    }

    static testmethod void testReports(){
        Commission_Report__c test = new Commission_Report__c();
        test.name = 'test';
        test.Big_Brain_Id__c = '12';
        test.Date__c = Date.today();
        insert test;
        test.Big_Brain_Id__c = '13';
        update test;
        delete test;
    }

    static testmethod void testPartnerTierChanged_UpdatePC(){
        Opportunity opp = [select Channel_Partner__c from Opportunity limit 1];
        Account acc = new Account(Id = opp.Channel_Partner__c, Partner_Tier__c = 'Platinum');
        List<Partner_Commission_Model__c> pcmList = [select Id from Partner_Commission_Model__c order by CreatedDate];
        Integer pcmCount = pcmList.size();
        Test.startTest();
        update acc;
        Batch_PartnerCommissionModel_TierChanged batch = new Batch_PartnerCommissionModel_TierChanged(Date.today(), new set<id>());
        Database.executeBatch(batch, 20);
        Test.stopTest();
        pcmList = [select Id, End_Date__c from Partner_Commission_Model__c order by CreatedDate];
        System.assertEquals(pcmCount, pcmList.size());
        System.assertEquals(null, pcmList.get(0).End_Date__c);
        List<Partner_Commission__c> pcList = [select Id, End_Date__c, Partner_Commission_Model__c from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        System.assertEquals(null, pcList.get(0).End_Date__c);
        System.assertNotEquals(null, pcList.get(0).Partner_Commission_Model__c);
    }

    static testmethod void testPartnerTierChanged_CreateNewPC(){
        Opportunity opp = [select Channel_Partner__c from Opportunity limit 1];
        Account acc = new Account(Id = opp.Channel_Partner__c, Partner_Tier__c = 'Platinum');
        List<Partner_Commission_Model__c> pcmList = [select Id from Partner_Commission_Model__c order by CreatedDate];
        Integer pcmCount = pcmList.size() + 1;
        for(Partner_Commission_Model__c pcm: pcmList){
            pcm.Start_Date__c = Date.today().addMonths(-1).toStartOfMonth();
        }
        update pcmList;
        Test.startTest();
        update acc;
        Batch_PartnerCommissionModel_TierChanged batch = new Batch_PartnerCommissionModel_TierChanged(Date.today().addMonths(1), new set<id>());
        Database.executeBatch(batch, 20);
        Test.stopTest();
        pcmList = [select Id, End_Date__c from Partner_Commission_Model__c order by CreatedDate];
        System.assertEquals(pcmCount, pcmList.size());
        System.assertNotEquals(null, pcmList.get(0).End_Date__c);
        System.assertEquals(null, pcmList.get(1).End_Date__c);
        List<Partner_Commission__c> pcList = [select Id, End_Date__c, Partner_Commission_Model__c from Partner_Commission__c order by CreatedDate];
        System.assertEquals(2, pcList.size());
        System.assertNotEquals(null, pcList.get(0).End_Date__c);
        System.assertEquals(null, pcList.get(1).End_Date__c);
        System.assertNotEquals(null, pcList.get(0).Partner_Commission_Model__c);
        System.assertEquals(pcmList.get(pcmCount - 1).Id, pcList.get(1).Partner_Commission_Model__c);
        System.assertNotEquals(pcList.get(0).Partner_Commission_Model__c, pcList.get(1).Partner_Commission_Model__c);
    }
}