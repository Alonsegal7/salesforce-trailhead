@istest
public with sharing class NextActivityServiceTest {
    @TestSetup
    static void makeData(){
        TestObjectCreator.persistImmediate=true;
        Lead lead = TestObjectCreator.createLead();
        Account company = TestObjectCreator.CreateCompany();
        Account ma = TestObjectCreator.CreateMondayAccount(company);
        Opportunity opportunity = TestObjectCreator.CreateOpp(ma);
        Contact con = new Contact(Email='demo1@randomdemodomain.com', FirstName = 'test', LastName = 'bla', AccountId = ma.Id);
        insert con;
    }


    @istest
    public static void handleOpptyFutureTask(){
        DateTime dT = System.now();
        Date futureDueDate = date.newinstance(dT.year(), dT.month()+1, dT.day());
        Date oldDueDate = date.newinstance(dT.year(), dT.month()-1, dT.day());

        List<task> tsks = new List<task>();
        Opportunity opp = [select id ,Next_activity_date__c, Next_activity__c from Opportunity limit 1];



        Task futureTask1 = new Task(WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='futureTask1', ActivityDate=futureDueDate);
        Task oldTask1 = new Task(WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask1', ActivityDate=date.newinstance(dT.year(), dT.month()-1, dT.day()));
        Task oldTask11 = new Task(WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask11', ActivityDate=date.newinstance(dT.year(), dT.month()-2, dT.day()));

        tsks.add(futureTask1);
        tsks.add(oldTask1);
        tsks.add(oldTask11);

        insert tsks;

        opp.Next_activity_date__c=null;
        opp.Next_activity__c=null;
        update opp;

        Test.startTest();
        NextActivityService nas = new NextActivityService();
        Database.executeBatch(nas);
        Test.stopTest();

        Opportunity opp1 = [select id ,Next_activity_date__c, Next_activity__c from Opportunity limit 1];

        System.assertEquals('futureTask1', opp1.Next_activity__c);
        System.assertEquals(futureDueDate, opp1.Next_activity_date__c);

    }

    @istest
    public static void handleOpptyOldTask(){
        DateTime dT = System.now();

        List<task> tsks = new List<task>();
        Opportunity opp = [select id ,Next_activity_date__c, Next_activity__c from Opportunity limit 1];

        
        Task oldTask1 = new Task(WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask1', ActivityDate=date.newinstance(dT.year(), dT.month()-1, dT.day()));
        Task oldTask11 = new Task(WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask11', ActivityDate=date.newinstance(dT.year(), dT.month()-2, dT.day()));

        tsks.add(oldTask1);
        tsks.add(oldTask11);

        insert tsks;

        opp.Next_activity_date__c=null;
        opp.Next_activity__c=null;
        update opp;


        Test.startTest();
        NextActivityService nas = new NextActivityService();
        Database.executeBatch(nas);
        Test.stopTest();

        Opportunity opp1 = [select id ,Next_activity__c, Next_activity_date__c from Opportunity limit 1];

        System.assertEquals(null, opp1.Next_activity__c);
        System.assertEquals(null, opp1.Next_activity_date__c);

    }

    @istest
    public static void handleLeadFutureTask(){
        DateTime dT = System.now();
        Date futureDueDate = date.newinstance(dT.year(), dT.month()+1, dT.day());
        Date oldDueDate = date.newinstance(dT.year(), dT.month()-1, dT.day());

        List<task> tsks = new List<task>();
        Lead ld = [select id ,Next_activity_date__c, Next_activity__c from Lead limit 1];


        Task futureTask1 = new Task(whoId=ld.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='futureTask1', ActivityDate=futureDueDate);
        Task oldTask1 = new Task(whoId=ld.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask1', ActivityDate=date.newinstance(dT.year(), dT.month()-1, dT.day()));
        Task oldTask11 = new Task(whoId=ld.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask11', ActivityDate=date.newinstance(dT.year(), dT.month()-2, dT.day()));

        tsks.add(futureTask1);
        tsks.add(oldTask1);
        tsks.add(oldTask11);

        insert tsks;

        ld.Next_activity_date__c=null;
        ld.Next_activity__c=null;
        update ld;


        Test.startTest();
        NextActivityService nas = new NextActivityService();
        Database.executeBatch(nas);
        Test.stopTest();

        Lead lead1 = [select id ,Next_activity_date__c, Next_activity__c from Lead limit 1];

        System.assertEquals('futureTask1', lead1.Next_activity__c);
        System.assertEquals(futureDueDate, lead1.Next_activity_date__c);

    }

    @istest
    public static void handleLeadOldTask(){
        DateTime dT = System.now();

        List<task> tsks = new List<task>();
        Lead ld = [select id ,Next_activity_date__c, Next_activity__c from Lead limit 1];
        Task oldTask1 = new Task(whoId=ld.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask1', ActivityDate=date.newinstance(dT.year(), dT.month()-1, dT.day()));
        Task oldTask11 = new Task(whoId=ld.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask11', ActivityDate=date.newinstance(dT.year(), dT.month()-2, dT.day()));

        tsks.add(oldTask1);
        tsks.add(oldTask11);

        insert tsks;

        ld.Next_activity_date__c=null;
        ld.Next_activity__c=null;
        update ld;

        Test.startTest();
        NextActivityService nas = new NextActivityService();
        Database.executeBatch(nas);
        Test.stopTest();

        Lead lead1 = [select id ,Next_activity_date__c, Next_activity__c from Lead limit 1];

        System.assertEquals(null, lead1.Next_activity__c);
        System.assertEquals(null, lead1.Next_activity_date__c);

    }

    @istest
    public static void handleContactAndOppFutureTask(){//contact is a converted lead
        DateTime dT = System.now();
        Date futureDueDate = date.newinstance(dT.year(), dT.month()+1, dT.day());

        Contact con = [select id from Contact limit 1];
        Opportunity opp = [select id ,Next_activity_date__c,Next_activity__c from Opportunity limit 1];


        List<task> tsks = new List<task>();
        Task futureTask1 = new Task(WhoId=con.Id,WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='futureTask1', ActivityDate=futureDueDate);
        Task oldTask1 = new Task(WhoId=con.Id,WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask1', ActivityDate=date.newinstance(dT.year(), dT.month()-1, dT.day()));
        Task oldTask11 = new Task(WhoId=con.Id,WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask11', ActivityDate=date.newinstance(dT.year(), dT.month()-2, dT.day()));

        tsks.add(futureTask1);
        tsks.add(oldTask1);
        tsks.add(oldTask11);

        insert tsks;
        opp.Next_activity_date__c=null;
        opp.Next_activity__c=null;
        update opp;

        Test.startTest();
        NextActivityService nas = new NextActivityService();
        Database.executeBatch(nas);
        Test.stopTest();

        Lead lead1 = [select id ,Next_activity_date__c, Next_activity__c from Lead limit 1];
        Opportunity opp1 = [select id ,Next_activity_date__c, Next_activity__c from Opportunity limit 1];


        System.assertEquals(null, lead1.Next_activity__c);
        System.assertEquals(null, lead1.Next_activity_date__c);
        System.assertEquals('futureTask1', opp1.Next_activity__c);
        System.assertEquals(futureDueDate, opp1.Next_activity_date__c);

    }

    @istest
    public static void handleCompletedTasksOppty(){
        DateTime dT = System.now();
        Date futureDueDate = date.newinstance(dT.year(), dT.month()+1, dT.day());
        Date oldDueDate = date.newinstance(dT.year(), dT.month()-1, dT.day());

        List<task> tsks = new List<task>();
        Opportunity opp = [select id ,Next_activity_date__c, Next_activity__c from Opportunity limit 1];


        Task futureTask1 = new Task(WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Completed', Subject='futureTask1', ActivityDate=futureDueDate);
        Task oldTask1 = new Task(WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask1', ActivityDate=date.newinstance(dT.year(), dT.month()-1, dT.day()));
        Task oldTask11 = new Task(WhatId=opp.Id,LastModifiedDate=dT,CreatedDate=dT,Status='Open', Subject='oldTask11', ActivityDate=date.newinstance(dT.year(), dT.month()-2, dT.day()));

        tsks.add(futureTask1);
        tsks.add(oldTask1);
        tsks.add(oldTask11);

        insert tsks;
        opp.Next_activity_date__c=null;
        opp.Next_activity__c=null;
        update opp;
        

        Test.startTest();
        NextActivityService nas = new NextActivityService();
        Database.executeBatch(nas);
        Test.stopTest();

        Opportunity opp1 = [select id ,Next_activity_date__c, Next_activity__c from Opportunity limit 1];

        System.assertEquals(null, opp1.Next_activity__c);
        System.assertEquals(null, opp1.Next_activity_date__c);

    }
}
