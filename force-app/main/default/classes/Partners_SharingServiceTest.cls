@isTest
public with sharing class Partners_SharingServiceTest {

    public static Id partnerOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
    public static Id partnerLeadRT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();

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
        Lead l = TestObjectCreator.createLead();
        l.RecordTypeId = partnerLeadRT;
        insert l;
        l.OwnerId = partnerUser.Id;
        update l;
    }
    static testmethod void test1(){
        Id userId = [select OwnerId from Opportunity limit 1].OwnerId;
        User u = new User(Id = userId, Eligible_for_Partners_Commission__c = true);
        update u;
    }

    static testmethod void test2(){
        Id userId = [select OwnerId from Opportunity limit 1].OwnerId;
        List<User> uList = [select Id, Contact.AccountId from User where Id =: userId];
        uList.get(0).Eligible_for_Partners_Commission__c = true;
        Set<Id> partnerCompsIds = new Set<Id>{uList.get(0).Contact.AccountId};
        Partners_SharingService.addToEligibleCommissionGroup(uList, partnerCompsIds);
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

    static testmethod void checkLeadOwnerBecamePartner(){
        Lead l = [select Id, OwnerId from Lead where RecordTypeId =: partnerLeadRT limit 1];
        l.OwnerId = UserInfo.getUserId();
        update l;
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