@isTest
public class Partner_TransferRecordsTest {
    @TestSetup
    static void setup(){
        Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Id partnerUserId = [select Id, Name from User where Profile.Name = 'Partner Community Custom' and IsActive = true and ManagerId != null and Manager.IsActive = true limit 1].Id;
        Account accComp = TestObjectCreator.CreateCompany();
        insert accComp;
        Account partnerComp = new Account(Name = 'test', recordTypeId = partnerRecordTypeId);
        insert partnerComp;
        Account mondayAcc = TestObjectCreator.CreateMondayAccount(accComp);
        mondayAcc.Name = 'test1';
        insert mondayAcc;
        mondayAcc.Channel_Partner__c = partnerComp.Id;
        mondayAcc.OwnerId = partnerUserId;
        mondayAcc.Partner__c = partnerUserId;
        update mondayAcc;
    }

    static testmethod void runUserTransfer(){
        Id prevPartnerUser = [select Id, Partner__c from Account where RecordType.DeveloperName = 'Monday_Account' limit 1].Partner__c;
        Id newPartnerUser = [select Id, Name from User where Profile.Name = 'Partner Community Custom' and IsActive = true and ManagerId != null and Manager.IsActive = true and Id !=: prevPartnerUser limit 1].Id;
        Test.startTest();
        Partner_TransferRecords.runUserTransfer(prevPartnerUser, newPartnerUser);
        Test.stopTest();
        List<Account> accList = [select OwnerId, Partner__c from Account where RecordType.DeveloperName = 'Monday_Account'];
        System.assertEquals(newPartnerUser, accList.get(0).OwnerId);
        System.assertEquals(newPartnerUser, accList.get(0).Partner__c);
    }

    static testmethod void runCpmTransfer(){
        Account acc = [select Id, Partner__c from Account where RecordType.DeveloperName = 'Monday_Account' limit 1];
        User prevPartnerUser = [select ManagerId from User where Id =: acc.Partner__c limit 1];     
        User newPartnerUser = [select Id, Name from User where Profile.Name = 'Partner Community Custom' and IsActive = true and ManagerId != null and Manager.IsActive = true and Id !=: prevPartnerUser.Id and ManagerId !=: prevPartnerUser.ManagerId limit 1];
        Id partnerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Account partnerAcc = [select Id from Account where recordTypeId =: partnerRTId limit 1];
        Test.startTest();
        Partner_TransferRecords.runCpmTransfer(partnerAcc.Id, prevPartnerUser.ManagerId, newPartnerUser.Id, Date.today());
        Test.stopTest();
    }
}