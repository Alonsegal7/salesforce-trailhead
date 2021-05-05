@isTest
public class Account_UpdateCsmManagerTest {
    @TestSetup
    static void setup(){
        User csmUser = [select Id, ManagerId from User where IsActive = true and Profile.Name = 'CSM' and ManagerId != null limit 1];
        Account comapnyAcc = TestObjectCreator.CreateCompany();
        comapnyAcc.CSM__c = csmUser.Id;
        comapnyAcc.CSM_Manager__c = csmUser.ManagerId;
        insert comapnyAcc;

        List<Account> mondayAccounts = new List<Account>();
        for(Integer i = 0;i<4;i++){
            mondayAccounts.add(TestObjectCreator.CreateMondayAccount(comapnyAcc));
        }

        for(Account acc: mondayAccounts){
            acc.CSM__c = csmUser.Id;
            acc.CSM_Manager__c = csmUser.ManagerId;
        }

        insert mondayAccounts;
    }

    static testmethod void testSanity(){
        Id mondayAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Account acc = [select CSM__c, CSM__r.ManagerId from Account where RecordTypeId =: mondayAccRecordTypeId limit 1];
        User newManager = [select Id from User where IsActive = true and Id !=: acc.CSM__c and Id !=: acc.CSM__r.ManagerId limit 1];
        User updateUser = new User(Id = acc.CSM__c, ManagerId = newManager.Id);
        Test.startTest();
        update updateUser;
        Test.stopTest();
        List<Account> accList = [select CSM__c, CSM_Manager__c, RecordTypeId from Account];
        for (Account accRec: accList){
            if(accRec.RecordTypeId == mondayAccRecordTypeId){
                System.assertEquals(newManager.Id, accRec.CSM_Manager__c);
            } else {
                System.assertEquals(acc.CSM__r.ManagerId, accRec.CSM_Manager__c);
            }
        }
    }
}
