@isTest
public without sharing class CommissionCommitmentCollectionServiceTst {
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

    static testmethod void testInsert(){
        Commission_Report__c test = new Commission_Report__c();
        test.name = 'test';
        test.Big_Brain_Id__c = '12';
        test.Date__c = Date.today();
        insert test;
        List<Partner_Commission__c> pcList = [select Id from Partner_Commission__c];
        System.assertEquals(1, pcList.size());
        Commission_Commitment__c commitment = new Commission_Commitment__c(Name = 'test');
        commitment.Partner_Commission__c = pcList.get(0).Id;
        commitment.Pulse_Account_Id__c = '12345';
        commitment.External_Source_ID__c = '879';
        commitment.Report_Id__c = '12';
        Commission_Collection__c collection = new Commission_Collection__c(Name = 'test');
        collection.Partner_Commission__c = pcList.get(0).Id;
        collection.Pulse_Account_Id__c = '12345';
        collection.Commitment_Big_Brain_Id__c = '879';
        collection.Report_Id__c = '12';
        
        insert commitment;
        insert collection; 

        collection = [select Monday_Account__c, Opportunity__c, Commission_Commitment__c from Commission_Collection__c limit 1];
        System.assertNotEquals(null, collection.Monday_Account__c);
        System.assertNotEquals(null, collection.Opportunity__c);
        System.assertNotEquals(null, collection.Commission_Commitment__c);
        commitment = [select Monday_Account__c, Opportunity__c from Commission_Commitment__c limit 1];
        System.assertNotEquals(null, commitment.Monday_Account__c);
        System.assertNotEquals(null, commitment.Opportunity__c);

        collection.Partner_Commission__c = null;
        collection.Pulse_Account_Id__c = null;
        commitment.Partner_Commission__c = null;
        commitment.Pulse_Account_Id__c = null;
        
        update collection;
        update commitment;

        collection = [select Monday_Account__c, Opportunity__c from Commission_Collection__c limit 1];
        System.assertEquals(null, collection.Monday_Account__c);
        System.assertEquals(null, collection.Opportunity__c);
        commitment = [select Monday_Account__c, Opportunity__c from Commission_Commitment__c limit 1];
        System.assertEquals(null, commitment.Monday_Account__c);
        System.assertEquals(null, commitment.Opportunity__c);
    }
}
