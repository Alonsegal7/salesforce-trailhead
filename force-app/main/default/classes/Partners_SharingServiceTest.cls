@isTest
public with sharing class Partners_SharingServiceTest {

    public static Id partnerOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
    @TestSetup
    static void makeData(){
        User partnerUser = TestObjectCreator.createValidPartnerUser();
        //create monday account
        Account comp = TestObjectCreator.CreateCompany();
        insert comp;
        Account mondayAcc = TestObjectCreator.CreateMondayAccount(comp);
        insert mondayAcc;
        mondayAcc.OwnerId = partnerUser.Id;
        update mondayAcc;
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        opp.RecordTypeId = partnerOppRecordTypeId;
        insert opp;
        opp.OwnerId = partnerUser.Id;
        update opp;
    }
    static testmethod void test1(){
        Id userId = [select OwnerId from Opportunity limit 1].OwnerId;
        User u = new User(Id = userId, Eligible_for_Partners_Commission__c = true);
        update u;
    }

    static testmethod void test2(){
        Id userId = [select OwnerId from Opportunity limit 1].OwnerId;
        User partnerUser = [select Contact.AccountId, ManagerId from User where Id =: userId];
        Commission_Commitment__c commitment = new Commission_Commitment__c(Name = 'test');
        commitment.Pulse_Account_Id__c = '12345';
        commitment.Partner_Company__c = partnerUser.Contact.AccountId;
        commitment.External_Source_ID__c = '879';
        commitment.Report_Id__c = '12';
        Commission_Collection__c collection = new Commission_Collection__c(Name = 'test');
        collection.Pulse_Account_Id__c = '12345';
        collection.Commitment_Big_Brain_Id__c = '879';
        collection.Report_Id__c = '12';
        collection.Partner_Company__c = partnerUser.Contact.AccountId;
        Payment_Request__c pr1 = new Payment_Request__c(
            Month__c = Date.today().toStartOfMonth(), 
            Channel_Partner__c = partnerUser.Contact.AccountId, 
            CPM__c = partnerUser.ManagerId, 
            Monthly_Commission_Amount__c = 100, 
            Yearly_Commission_Amount__c = 200, 
            Two_Yearly_Commission_Amount__c = 300,
            MDF_Amount__c = 100,
            Spiff_Amount__c = 50,
            Status__c = 'Draft',
            CurrencyIsoCode = 'USD'
        );        
        insert commitment;
        insert collection; 
        insert pr1;
    }
    static testmethod void checkAccountOwnerBecamePartner(){
        Account acc = [select Id, OwnerId from Account where RecordType.DeveloperName = 'Monday_Account' limit 1];
        User u = new User(Id = acc.OwnerId);
        List<Account> accList = new List<Account>();
        System.runAs(u){
            accList = [select Id, OwnerId from Account where RecordType.DeveloperName = 'Monday_Account' limit 1];
            Opportunity opp = TestObjectCreator.CreateOpp(acc);
            opp.RecordTypeId = partnerOppRecordTypeId;
            insert opp;
        }
        System.assertNotEquals(0, accList.size());
    }

    static testmethod void checkAccountOwnerIsNotPartner(){
        Account acc = [select Id, OwnerId from Account where RecordType.DeveloperName = 'Monday_Account' limit 1];
        User u = new User(Id = acc.OwnerId);
        acc.OwnerId = UserInfo.getUserId();
        update acc;
        List<Account> accList = new List<Account>();
        /*System.runAs(u){
            accList = [select Id, OwnerId from Account where RecordType.DeveloperName = 'Monday_Account' limit 1];
        }
        System.assertEquals(0, accList.size());*/
    }

    static testmethod void checkOppOwnerBecamePartner(){
        Opportunity opp = [select Id, OwnerId from Opportunity limit 1];
        User u = new User(Id = opp.OwnerId);
        List<Opportunity> oppList = new List<Opportunity>();
        System.runAs(u){
            oppList = [select Id, OwnerId from Opportunity limit 1];
        }
        System.assertNotEquals(0, oppList.size());
    }

    static testmethod void checkOppOwnerIsNotPartner(){
        Opportunity opp = [select Id, OwnerId from Opportunity limit 1];
        User u = new User(Id = opp.OwnerId);
        opp.OwnerId = UserInfo.getUserId();
        update opp;
        List<Opportunity> oppList = new List<Opportunity>();
        /*System.runAs(u){
            oppList = [select Id, OwnerId from Opportunity limit 1];
        }
        System.assertEquals(0, oppList.size());*/
    }
}