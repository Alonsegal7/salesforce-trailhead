@isTest

public class Account_Rollup_Test {
    static testMethod void newMaCreatedRecalculateParrent() {        

        Id CompanyRecordTypeId = Utilities.CompanyRecordTypeId;
        Id MARecordTypeId = Utilities.MARecordTypeId;
        
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
        regionalCom.Region__c = 'EMEA';
        regionalCom.ParentId = globalCom.Id;
        regionalCom.Company__c = globalCom.Id;
        insert regionalCom;

        Account testMA = new Account(
            Name = 'Test MA Global',
            RecordTypeId = MARecordTypeId,
            ARR__c=1000,
            Plan_Seats__c=100,
            MAPP__c=80,
            WAPP__c=20,
            Members__c=90,
            ParentId = globalCom.Id);
        insert testMA;

        Test.startTest();

        Set<Id>accountsToTest = new Set<Id>();
        Account updatedGlobalAccount = [SELECT Id,ARR__c,Plan_Seats__c,MAPP__c,WAPP__c,Members__c FROM Account WHERE Id = :globalCom.Id][0];
        accountsToTest.add(updatedGlobalAccount.Id);
        ID testJobID = System.enqueueJob(new Account_Rollup_Scheduled.updateAccountsRollupQueueable(accountsToTest));
        System.debug('TestJobIDNo: '+testJobID);

        Test.stopTest();
        
        updatedGlobalAccount = [SELECT Id,ARR__c,Plan_Seats__c,MAPP__c,WAPP__c,Members__c FROM Account WHERE Id = :globalCom.Id];
        System.assertEquals(11000, updatedGlobalAccount.ARR__c);
        System.assertEquals(1100, updatedGlobalAccount.Plan_Seats__c);
        System.assertEquals(880, updatedGlobalAccount.MAPP__c);
        System.assertEquals(220, updatedGlobalAccount.WAPP__c);
        System.assertEquals(990, updatedGlobalAccount.Members__c);
        
    }

    static testMethod void testScheduledLogic() {        

        Id CompanyRecordTypeId = Utilities.CompanyRecordTypeId;
        Id MARecordTypeId = Utilities.MARecordTypeId;
        
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
        regionalCom.Company__c = globalCom.Id;
        regionalCom.Region__c = 'EMEA';
        insert regionalCom;

        Account testMA = new Account(
            Name = 'Test MA Global',
            RecordTypeId = MARecordTypeId,
            ARR__c=1000,
            Plan_Seats__c=100,
            MAPP__c=80,
            WAPP__c=20,
            Members__c=90,
            Company__c = globalCom.Id,
            ParentId = globalCom.Id);
        insert testMA;

        Test.startTest();

        Account_Rollup_Scheduled p = new Account_Rollup_Scheduled();
        String sch = '0 0 * * * ?';
        system.schedule('TestRollupScheduled', sch, p);


        Test.stopTest();
        
        
    }

    static testMethod void MaUpdatedRecalculateParrent() {        
        
        Id CompanyRecordTypeId = Utilities.CompanyRecordTypeId;
        Id MARecordTypeId = Utilities.MARecordTypeId;
        
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

        Set<Id>accountsToTest = new Set<Id>();
        Account updatedGlobalAccount = [SELECT Id,ARR__c,Plan_Seats__c,MAPP__c,WAPP__c,Members__c FROM Account WHERE Id = :globalCom.Id][0];
        accountsToTest.add(updatedGlobalAccount.Id);
        ID testJobID = System.enqueueJob(new Account_Rollup_Scheduled.updateAccountsRollupQueueable(accountsToTest));
        System.debug('TestJobIDNo: '+testJobID);

        Test.stopTest();
        
        updatedGlobalAccount = [SELECT Id,ARR__c,Plan_Seats__c,MAPP__c,WAPP__c,Members__c FROM Account WHERE Id = :globalCom.Id];
        System.assertEquals(12000, updatedGlobalAccount.ARR__c);
        System.assertEquals(1100, updatedGlobalAccount.Plan_Seats__c);
        System.assertEquals(880, updatedGlobalAccount.MAPP__c);
        System.assertEquals(220, updatedGlobalAccount.WAPP__c);
        System.assertEquals(990, updatedGlobalAccount.Members__c);
    }
}