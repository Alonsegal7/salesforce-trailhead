@isTest
public class PartnerCommissionServiceTest {
    @TestSetup
    static void makeData(){
        Map<String, Schema.RecordTypeInfo> accountRecordTypesMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();

        //create THs
        GB_Threshold__c th = TestObjectCreator.CreateGBThreshold('Partner_Opportunity');
        th.Source_Type__c = 'Inbound';
        insert th;

        //create commission model
        Commission_Model__c commissionModel = new Commission_Model__c(Partner_Tier__c = 'Platinum', Name = 'test', Outbound_Percent__c = 30, Inbound_Percent__c	= 20, Is_Active__c = true, Commission_Type__c = 'One Time', Effective_Start_Date__c = Date.today());
        insert commissionModel;

        //create partner company
        List<Account> partnersList = new List<Account>();
        partnersList.add(new Account(Name = 'testPartner', RecordTypeId = accountRecordTypesMap.get('Partner_Company').getRecordTypeId()));
        partnersList.add(new Account(Name = 'testPartner2', RecordTypeId = accountRecordTypesMap.get('Partner_Company').getRecordTypeId()));
        insert partnersList;
    
        //create partner commission model
        List<Partner_Commission_Model__c> pcmList = new List<Partner_Commission_Model__c>();
        pcmList.add(new Partner_Commission_Model__c(Commission_Model__c = commissionModel.Id, Partner_Company__c = partnersList.get(0).Id, Start_Date__c = Datetime.now()));
        pcmList.add(new Partner_Commission_Model__c(Commission_Model__c = commissionModel.Id, Partner_Company__c = partnersList.get(1).Id, Start_Date__c = Datetime.now()));
        insert pcmList;

        Contact con = new Contact(Email='demo1@randomdemodomain.com', FirstName = 'test', LastName = 'bla', AccountId = partnersList.get(0).Id);
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community Custom'];
        User manager2 = [select Id from User where IsActive = true and Profile.Name='Channel Managers' limit 1];
		User user = new User(ContactId = con.Id, Alias='standt1', ManagerId=manager2.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
		insert user;

        //create monday account
        Account mondayAcc = new Account(OwnerId = user.Id, Name = 'testMOnday', RecordTypeId = accountRecordTypesMap.get('Monday_Account').getRecordTypeId(), primary_pulse_account_id__c = '12345', Account_Source_Type__c = 'Inbound', Sign_Up_Date__c = Date.today());
        insert mondayAcc;

        //create opportunity with opp.Potential_GB_Opp_Override__c=='Yes'
        Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = partnerRecordTypeId;
        opp.OwnerId = user.Id;
        opp.Potential_GB_Opp_Override__c = 'Yes';
        insert opp;

        opp.StageName = 'Closed Won';
        opp.Transition_to_GB__c = true;
        opp.Claimed_ARR__c = 10000;
        update opp;
    }

    static testmethod void testFirstPartnerCommissionCreation(){
        Opportunity opp = [select Id, Channel_Partner__c, Transition_to_GB__c, StageName, RecordTypeId from Opportunity limit 1];
        System.assertNotEquals(null, opp.Channel_Partner__c);
        System.assertEquals(true, opp.Transition_to_GB__c);
        System.assertEquals('Closed Won', opp.StageName);
        System.assertEquals(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId(), opp.RecordTypeId);
        List<Partner_Commission__c> pcList = [select Id from Partner_Commission__c];
        System.assertEquals(1, pcList.size());

        //update MA ARR below TH
        Id mondayAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Account mondayAcc = [select Id from Account where RecordTypeId =: mondayAccRtId limit 1];
        mondayAcc.ARR__c = 4000;
        mondayAcc.Last_ARR_Update_Timestamp__c = Datetime.now();
        Test.startTest();
        update mondayAcc;
        Test.stopTest();
        pcList = [select Id, End_Date__c from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        System.assertNotEquals(null, pcList.get(0).End_Date__c);
    }

    static testmethod void testPartnerCommissionCreationFromARR(){
        Opportunity opp = [select Id, Channel_Partner__c, Transition_to_GB__c, StageName, RecordTypeId from Opportunity limit 1];
        System.assertNotEquals(null, opp.Channel_Partner__c);
        System.assertEquals(true, opp.Transition_to_GB__c);
        System.assertEquals('Closed Won', opp.StageName);
        System.assertEquals(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId(), opp.RecordTypeId);
        List<Partner_Commission__c> pcList = [select Id from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        pcList.get(0).End_Date__c = Datetime.now().addMinutes(-1);
        update pcList;
        //update MA ARR above TH
        Id mondayAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Account mondayAcc = [select Id from Account where RecordTypeId =: mondayAccRtId limit 1];
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
}
