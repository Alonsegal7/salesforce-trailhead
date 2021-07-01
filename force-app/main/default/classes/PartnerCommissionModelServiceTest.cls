@isTest
public class PartnerCommissionModelServiceTest {
    @TestSetup
    static void makeData(){
        //create commission model
        Commission_Model__c commissionModel = new Commission_Model__c(Partner_Tier__c = 'Platinum', Name = 'test', Outbound_Percent__c = 30, Inbound_Percent__c	= 20, Is_Active__c = true, Commission_Type__c = 'One Time', Effective_Start_Date__c = Date.today());
        insert commissionModel;
        //create partner company
        Account partnerAccount = new Account(Name = 'testPartner', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId());
        insert partnerAccount;
        //create partner commission model
        Partner_Commission_Model__c pcm = new Partner_Commission_Model__c(Commission_Model__c = commissionModel.Id, Partner_Company__c = partnerAccount.Id, Start_Date__c = Datetime.now());
        insert pcm;
    }

    static testmethod void testPcmCreationUpdatesAccount(){
        Account acc = [select Id, Partner_Commission_Model__c from Account limit 1];
        Partner_Commission_Model__c pcm = [select Id from Partner_Commission_Model__c limit 1];
        System.assertEquals(pcm.Id, acc.Partner_Commission_Model__c);
    }

    static testmethod void testPcmCreationWithOverlap(){
        Commission_Model__c cm = [select Id from Commission_Model__c limit 1];
        Account acc = [select Id from Account limit 1];
        Partner_Commission_Model__c pcm = new Partner_Commission_Model__c(Commission_Model__c = cm.Id, Partner_Company__c = acc.Id, Start_Date__c = Datetime.now());
        try{
            insert pcm;
        } catch (Exception e){

        }
    }
}
