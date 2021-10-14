@isTest

public class Account_Rollup_Test {
    static testMethod void newMaCreatedRecalculateParrent() {        

        Id CompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        
        Account globalCom = new Account();
        globalCom.Name = 'Test Global';
        globalCom.RecordTypeId = CompanyRecordTypeId;
        globalCom.Account_Territory__c = 'Global';
        insert globalCom;
        
        Account regionalCom = new Account();
        regionalCom.Name = 'Test Regional EMEA';
        regionalCom.RecordTypeId = CompanyRecordTypeId;
        regionalCom.ARR__c=10000;
        regionalCom.Plan_Seats__c=1000;
        regionalCom.MAPP__c=800;
        regionalCom.WAPP__c=200;
        regionalCom.Members__c=900;
        regionalCom.Account_Territory__c = 'Regional';
        regionalCom.ParentId = globalCom.Id;
        insert regionalCom;

        Test.startTest();
        
        Account testMA = new Account();
        testMA.Name = 'Test MA Global';
        testMA.RecordTypeId = MARecordTypeId;
        testMA.ARR__c=1000;
        testMA.Plan_Seats__c=100;
        testMA.MAPP__c=80;
        testMA.WAPP__c=20;
        testMA.Members__c=90;
        testMA.ParentId = globalCom.Id;
        insert testMA;

        Test.stopTest();
        
        Account updatedGlobalAccount = [SELECT Id,ARR__c,Plan_Seats__c,MAPP__c,WAPP__c,Members__c FROM Account WHERE Id = :globalCom.Id];
        /*System.assertEquals(11000, updatedGlobalAccount.ARR__c);
        System.assertEquals(1100, updatedGlobalAccount.Plan_Seats__c);
        System.assertEquals(880, updatedGlobalAccount.MAPP__c);
        System.assertEquals(220, updatedGlobalAccount.WAPP__c);
        System.assertEquals(990, updatedGlobalAccount.Members__c);*/
        
    }

    static testMethod void MaUpdatedRecalculateParrent() {        
        
        Id CompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        
        Account globalCom = new Account();
        globalCom.Name = 'Test Global';
        globalCom.RecordTypeId = CompanyRecordTypeId;
        globalCom.Account_Territory__c = 'Global';
        insert globalCom;
         
        Account testMA1 = new Account();
        testMA1.Name = 'Test MA 1';
        testMA1.RecordTypeId = MARecordTypeId;
        testMA1.ARR__c=10000;
        testMA1.Plan_Seats__c=1000;
        testMA1.MAPP__c=800;
        testMA1.WAPP__c=200;
        testMA1.Members__c=900;
        testMA1.ParentId = globalCom.Id;
        insert testMA1;

        Account testMA = new Account();
        testMA.Name = 'Test MA Global';
        testMA.RecordTypeId = MARecordTypeId;
        testMA.ARR__c=1000;
        testMA.Plan_Seats__c=100;
        testMA.MAPP__c=80;
        testMA.WAPP__c=20;
        testMA.Members__c=90;
        testMA.ParentId = globalCom.Id;
        insert testMA;

        Test.startTest();
    
        testMA.ARR__c=2000;
        update testMA;

        Test.stopTest();

        Account updatedGlobalAccount = [SELECT Id,ARR__c,Plan_Seats__c,MAPP__c,WAPP__c,Members__c FROM Account WHERE Id = :globalCom.Id];
        /*System.assertEquals(12000, updatedGlobalAccount.ARR__c);
        System.assertEquals(1100, updatedGlobalAccount.Plan_Seats__c);
        System.assertEquals(880, updatedGlobalAccount.MAPP__c);
        System.assertEquals(220, updatedGlobalAccount.WAPP__c);
        System.assertEquals(990, updatedGlobalAccount.Members__c);*/ 
    }
}