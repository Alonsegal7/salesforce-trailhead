@isTest
public class RiskBannerController_Test {
    @TestSetup
    static void testSetup(){
        User rep = [SELECT Id FROM User WHERE Group__c = 'Sales' and Seniority__c = 'Rep' and IsActive = true limit 1];
        User bizOps = [SELECT Id FROM User WHERE Group__c = 'BizOps' and IsActive = true limit 1];
        Account mondayAccount = TestObjectCreator.CreateAccount();
        mondayAccount.OwnerId = rep.Id;
        insert mondayAccount;

        Risk__c riskRecord = new Risk__c();
        riskRecord.Risk_Name__c = 'Test Risk';
        riskRecord.Risk_Status__c = 'New Risk';
        riskRecord.Risk_Severity__c = 'Low';
        riskRecord.Description__c = 'Test Risk Description';
        riskRecord.Risk_Reason__c = 'Covid-19';
        riskRecord.Risk_Probability__c = 'Low';
        riskRecord.Monday_Account__c = mondayAccount.Id;
        insert riskRecord;
    }

    @isTest
    static void getRisks_Test(){
        Risk__c getRisk = [SELECT Id, Risk_Name__c, Monday_Account__c FROM Risk__c WHERE Risk_Status__c = 'New Risk'];
        List<Risk__c> riskList = RiskBannerController.getRisks(getRisk.Monday_Account__c);

        // List<Risk__c> getRiskList = [SELECT Id FROM Risk__c WHERE Id =: riskList.Id];
        System.assert(riskList.size() > 0);
    }
}