@isTest
public class Partner_TransferRecordsTest {
    @TestSetup
    static void setup(){
        Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Account accComp = TestObjectCreator.CreateCompany();
        insert accComp;
        Account partnerComp = new Account(Name = 'test', recordTypeId = partnerRecordTypeId);
        insert partnerComp;
        Account mondayAcc = TestObjectCreator.CreateMondayAccount(accComp);
        mondayAcc.Name = 'test1';
        mondayAcc.OwnerId = UserInfo.getUserId();
        mondayAcc.Partner__c = UserInfo.getUserId();
        insert mondayAcc;
        mondayAcc.Channel_Partner__c = partnerComp.Id;
        update mondayAcc;
        Opportunity opp = TestObjectCreator.CreateOpp(mondayAcc);
        insert opp;
        opp.Channel_Partner__c = partnerComp.Id;
        update opp;
        Lead leadrec = new Lead(FirstName = 'test', LastName = 'bla', Email = 'blabla@testmonday.com', OwnerId = UserInfo.getUserId(), Company = 'test');
        insert leadrec;
        leadrec.Partner_Company__c = partnerComp.Id;
        update leadrec;
        Sale__c saleRec = new Sale__c(Monday_Account__c = mondayAcc.Id, Owner__c = UserInfo.getUserId(), Company__c = mondayAcc.Id);
        insert saleRec;
    }

    static testmethod void runUserTransfer(){
        User userNotMe = [select Id from User where Email like '%@monday.com' and IsActive = true and Id !=: UserInfo.getUserId() and Profile.Name like '%Administrator%' limit 1];
        Test.startTest();
        Partner_TransferRecords.runUserTransfer(UserInfo.getUserId(), userNotMe.Id);
        Test.stopTest();
        Id mondayAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        List<Account> accList = [select OwnerId, Partner__c from Account where RecordTypeId =: mondayAccRtId];
        System.assertEquals(userNotMe.Id, accList.get(0).OwnerId);
        System.assertEquals(userNotMe.Id, accList.get(0).Partner__c);
        List<Lead> leadList = [select OwnerId from Lead];
        System.assertEquals(userNotMe.Id, leadList.get(0).OwnerId);
        List<Opportunity> oppList = [select OwnerId from Opportunity];
        System.assertEquals(userNotMe.Id, oppList.get(0).OwnerId);
        List<Sale__c> saleList = [select Owner__c from Sale__c];
        System.assertEquals(userNotMe.Id, saleList.get(0).Owner__c);
    }

    static testmethod void runCpmTransfer(){
        User myUser = [select ManagerId from User where Id =: UserInfo.getUserId()];
        User userNotMe = [select Id from User where Email like '%@monday.com' and IsActive = true and Id !=: UserInfo.getUserId() and Profile.Name like '%Administrator%' limit 1];
        Id partnerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Account partnerAcc = [select Id from Account where recordTypeId =: partnerRTId limit 1];
        Test.startTest();
        Partner_TransferRecords.runCpmTransfer(partnerAcc.Id, myUser.ManagerId, userNotMe.Id, Date.today());
        Test.stopTest();
        /*Id mondayAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        List<Account> accList = [select Owner_s_Manager__c, Channel_Partner__c from Account where RecordTypeId =: mondayAccRtId];
        System.assertEquals(partnerAcc.Id, accList.get(0).Channel_Partner__c);
        System.assertEquals(userNotMe.Id, accList.get(0).Owner_s_Manager__c);
        List<Lead> leadList = [select Owner_s_Manager__c from Lead];
        System.assertEquals(userNotMe.Id, leadList.get(0).Owner_s_Manager__c);
        List<Opportunity> oppList = [select Owner_s_Manager__c from Opportunity];
        System.assertEquals(userNotMe.Id, oppList.get(0).Owner_s_Manager__c);*/
    }
}