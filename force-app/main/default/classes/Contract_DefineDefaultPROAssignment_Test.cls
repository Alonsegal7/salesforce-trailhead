@isTest
public with sharing class Contract_DefineDefaultPROAssignment_Test {
    @TestSetup
    static void makeData(){
        Id ACC_PARTNER_COMP_RT_CONST = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Account company = TestObjectCreator.CreateCompany();
        insert company;
        
        List<Contract> contractsToCreate = new List<Contract>();
        Contract contract1 = TestObjectCreator.CreateContract(company);
        contract1.Name = 'Test contract 1';
        contract1.Status__c='Active';
        contractsToCreate.add(contract1);
        Contract contract2 = TestObjectCreator.CreateContract(company);
        contract2.Name = 'Test contract 2';
        contract2.Status__c='Active';
        contractsToCreate.add(contract2);
        Contract contract3 = TestObjectCreator.CreateContract(company);
        contract3.Name = 'Test contract 3';
        contract3.Status__c='Active';
        contractsToCreate.add(contract3);
        Contract contract4 = TestObjectCreator.CreateContract(company);
        contract4.Name = 'Test contract 4';
        contract4.Status__c='Active';
        contractsToCreate.add(contract4);
        Contract contract5 = TestObjectCreator.CreateContract(company);
        contract5.Name = 'Test contract 5';
        contract5.Status__c='Active';
        contractsToCreate.add(contract5);
        insert contractsToCreate;

        //create partner company 
        List<Account> partnersList = new List<Account>();
        partnersList.add(new Account(
                            Name = 'testPartner', 
                            RecordTypeId = ACC_PARTNER_COMP_RT_CONST,
                            Partner_Company_Status__c = 'Signed',
                            Signature_Approval_Status__c = 'Approved'
                        ));
        insert partnersList;
        //create partner contact
        Contact con = new Contact(Email='demo1@randomdemodomain.com', FirstName = 'test', LastName = 'bla', AccountId = partnersList.get(0).Id);
        insert con;
        //--Users Creation
        List<User> usersToCreate = new List<User>();
        Profile profilePartner = [SELECT Id FROM Profile WHERE Name='Partner Community Custom'];
        profile profileAdmin =[SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile profileIdRenewal = [SELECT Id FROM Profile WHERE Name = 'Renewals'];
        //create partner user + partner manager user
        User userManager = TestUtils.getUserWithoutRole(profileAdmin);
        insert userManager;
		User partnerUser = new User(ContactId = con.Id, Alias='standt1', ManagerId=userManager.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = profilePartner.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
        usersToCreate.add(partnerUser);
        //create sales user - Business role AM + Segment Enterprise  
        User user1SalesAMEnt = TestUtils.getUserWithoutRole(profileAdmin);
        user1SalesAMEnt.Segment__c = 'Enterprise';
        user1SalesAMEnt.Group__c='Sales';
        user1SalesAMEnt.Business_Role__c = 'AM';
        usersToCreate.add(user1SalesAMEnt);
        //create sales user - Business role AE + Segment SMB 
        User user2SalesAESmb = TestUtils.getUserWithoutRole(profileAdmin);
        user2SalesAESmb.Segment__c = 'SMB';
        user2SalesAESmb.Group__c='Sales';
        user2SalesAESmb.Business_Role__c = 'AE';
        usersToCreate.add(user2SalesAESmb);
        //create sales user - Business role AM + Segment Mid-Market + No Pod 
        User user3SalesAMMid = TestUtils.getUserWithoutRole(profileAdmin);
        user3SalesAMMid.Segment__c = 'Mid-Market';
        user3SalesAMMid.Group__c='Sales';
        user3SalesAMMid.Business_Role__c = 'AM';
        usersToCreate.add(user3SalesAMMid);
        //create renewal user - for Pod assignment
        User renewalUser = TestUtils.getUserWithoutRole(profileIdRenewal);
        renewalUser.ManagerId=userManager.Id;
        usersToCreate.add(renewalUser);

        insert usersToCreate;

        List<Account> accountdToCreate = new List<Account>();
        //MA managed by a partner
        Account maPartner = TestObjectCreator.CreateMondayAccount(company);
        maPartner.Name='PartnersMA';
        maPartner.ARR__c = 100;
        maPartner.OwnerId = partnerUser.Id;
        maPartner.active_contract__c = contract1.id;
        accountdToCreate.add(maPartner);
        System.debug('maPartner- Noam'+maPartner);
        //MA Is co-sell - Sales rep is account owner 
        Account maCoSellSalesLead = TestObjectCreator.CreateMondayAccount(company);
        maCoSellSalesLead.Name='CoSellAccountSalesLead';
        maCoSellSalesLead.ARR__c = 300;
        maCoSellSalesLead.Channel_Partner__c=partnersList.get(0).Id;
        maCoSellSalesLead.OwnerId = user2SalesAESmb.Id;
        maCoSellSalesLead.active_contract__c = contract4.id;
        accountdToCreate.add(maCoSellSalesLead);
        System.debug('maCoSellSalesLead- Noam'+maCoSellSalesLead);
        //MA Is co-sell - Sales rep is account owner + No existing Pod for user  
        Account maCoSellSalesLeadNoPod = TestObjectCreator.CreateMondayAccount(company);
        maCoSellSalesLeadNoPod.Name='CoSellAccountSalesLeadNoPod';
        maCoSellSalesLeadNoPod.ARR__c = 500;
        maCoSellSalesLeadNoPod.Channel_Partner__c=partnersList.get(0).Id;
        maCoSellSalesLeadNoPod.OwnerId = user3SalesAMMid.Id;
        maCoSellSalesLeadNoPod.active_contract__c = contract5.id;
        accountdToCreate.add(maCoSellSalesLeadNoPod);
        System.debug('CoSellAccountSalesLeadNoPod- Noam'+maCoSellSalesLeadNoPod);
        //MA managed by sales rep (AM + Segment Enterprise)
        Account maSalesEntAM = TestObjectCreator.CreateMondayAccount(company);
        maSalesEntAM.Name='SalesMAAM';
        maSalesEntAM.ARR__c = 150;
        maSalesEntAM.OwnerId=user1SalesAMEnt.Id;
        maSalesEntAM.active_contract__c = contract2.id;
        accountdToCreate.add(maSalesEntAM);
        System.debug('maSalesEntAM- Noam'+maSalesEntAM);
         //MA managed by sales rep (AE + Segment SMB)
        Account maSalesSmbAE = TestObjectCreator.CreateMondayAccount(company);
        maSalesSmbAE.Name='SalesMAAE';
        maSalesSmbAE.ARR__c = 200;
        maSalesSmbAE.OwnerId=user2SalesAESmb.Id;
        maSalesSmbAE.active_contract__c = contract3.id;
        accountdToCreate.add(maSalesSmbAE);
        System.debug('maSalesSmbAE- Noam'+maSalesSmbAE);

        insert accountdToCreate;

        //creation of Pod Assignment for Partner Company
        List<Pod_Assignment__c> podsToCreate = new List<Pod_Assignment__c>();
        Pod_Assignment__c podForPartnerCompany = new Pod_Assignment__c(
            Partner_Pod_Lead_Partner_Company__c=partnersList.get(0).Id,
            Pod_Type__c='Partners',
            Pod_Start_Date__c=date.today(),
            Renewal_Manager__c=renewalUser.Id,
            Status__c='Active');
        podsToCreate.add(podForPartnerCompany);
        //creation of Pod Assignment for Sales rep (AE + Segment SMB)
        Pod_Assignment__c podForPorSmbAE = new Pod_Assignment__c(
            Sales_Pod_Lead__c=user2SalesAESmb.Id,
            Pod_Type__c='Sales',
            Pod_Start_Date__c=date.today(),
            Renewal_Manager__c=renewalUser.Id,
            Status__c='Active');
        podsToCreate.add(podForPorSmbAE);
        //creation of Pod Assignment for Sales rep (AM + Segment AM)
        Pod_Assignment__c podForPorSEntAM = new Pod_Assignment__c(
            Sales_Pod_Lead__c=user1SalesAMEnt.Id,
            Pod_Type__c='Sales',
            Pod_Start_Date__c=date.today(),
            Renewal_Manager__c=renewalUser.Id,
            Status__c='Active');
        podsToCreate.add(podForPorSEntAM);
        insert podsToCreate;

        //update contracts with main monday accounts related
        List<Contract> contractsToUpdate = new List<Contract>();
        contract1.Main_Monday_Account_Related__c = maPartner.id;
        contractsToUpdate.add(contract1);
        contract2.Main_Monday_Account_Related__c = maSalesEntAM.id;
        contractsToUpdate.add(contract2);
        contract3.Main_Monday_Account_Related__c = maSalesSmbAE.id;
        contractsToUpdate.add(contract3);
        contract4.Main_Monday_Account_Related__c = maCoSellSalesLead.id;
        contractsToUpdate.add(contract4);
        contract5.Main_Monday_Account_Related__c = maCoSellSalesLeadNoPod.id;
        contractsToUpdate.add(contract5);

        update contractsToUpdate;
    }
    @isTest
    static void maOwnerIsPartnerPROShouldBeAccountOwner() {
        Account maPartner = [SELECT Id,Name,ARR__c,OwnerId FROM Account WHERE ARR__c = 100 LIMIT 1 ];
        Contract con = [SELECT Id, Name,Primary_Renewal_Owner__c,Main_Monday_Account_Related__c FROM Contract WHERE Name = 'Test contract 1' LIMIT 1 ];
        Pod_Assignment__c pod = [SELECT Id,Renewal_Manager__c FROM Pod_Assignment__c WHERE Pod_Type__c='Partners' LIMIT 1];
        con.EndDate=Date.today().addMonths(6); //contract that will be ended in 6 months, should be triggerd the PRO schduled batach
        System.debug('Noam con main MA releated'+con.Main_Monday_Account_Related__c);
        update con;
        Test.startTest();
        Batch_DefineDefaultPROOnContract batch = new Batch_DefineDefaultPROOnContract();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        con=[SELECT Primary_Renewal_Owner__c,Name FROM Contract WHERE Name = 'Test contract 1' LIMIT 1]; 
       system.assertEquals(con.Primary_Renewal_Owner__c, maPartner.OwnerId); //following the logic, the Account Owner should be the RM from the Pod Assignment
    }  
    @IsTest
    static void maIsCoSellOwnerIsSalesPROIsRenewalManager() {
        Account maCoSellSalesLead = [SELECT Id,Name,ARR__c,OwnerId,Owner_is_Partner__c,Channel_Partner__c FROM Account WHERE ARR__c = 100 LIMIT 1 ];
        Account partnerCompany = [SELECT Id FROM Account WHERE  Name = 'testPartner'];
        maCoSellSalesLead.Channel_Partner__c = partnerCompany.Id;
        update maCoSellSalesLead;
        Contract con = [SELECT Id, Name,Primary_Renewal_Owner__c FROM Contract WHERE Name = 'Test contract 4' LIMIT 1 ];
        Pod_Assignment__c pod = [SELECT Id,Renewal_Manager__c FROM Pod_Assignment__c  WHERE Sales_Pod_Lead__c =: maCoSellSalesLead.OwnerId LIMIT 1];
        con.EndDate=Date.today().addMonths(6); //contract that will be ended in 6 months, should be triggerd the PRO schduled batach
        update con;
        System.debug('Noam con pro'+con.Primary_Renewal_Owner__c);
        system.debug('Noam Owner is partner in condition'+maCoSellSalesLead.Owner_is_Partner__c );
        system.debug('Noam Owner is partner in channel manager'+maCoSellSalesLead.Channel_Partner__c );
        Test.startTest();
        Batch_DefineDefaultPROOnContract batch = new Batch_DefineDefaultPROOnContract();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        con=[SELECT Primary_Renewal_Owner__c,Name FROM Contract WHERE Name = 'Test contract 4' LIMIT 1]; 
        system.debug('Noam Contract 4- CO SELL'+con.Primary_Renewal_Owner__c);
        system.assertEquals(con.Primary_Renewal_Owner__c, pod.Renewal_Manager__c); //following the logic, the Sales Pod RM should be the PRO

    }
    @IsTest
    static void maIsCoSellOwnerIsSalesPROIsRenewalManagerNoPod() {
        Account maCoSellSalesLeadNoPod = [SELECT Id,Name,ARR__c,OwnerId FROM Account WHERE ARR__c = 500 LIMIT 1 ];
        Contract con = [SELECT Id, Name,Primary_Renewal_Owner__c,Main_Monday_Account_Related__c FROM Contract WHERE Name = 'Test contract 5' LIMIT 1 ];
        con.EndDate=Date.today().addMonths(6); //contract that will be ended in 6 months, should be triggerd the PRO schduled batach
        update con;
        System.debug('Noam con pro'+con.Primary_Renewal_Owner__c);
        System.debug('Noam con main MA releated'+con.Main_Monday_Account_Related__c);
        System.debug('Noam Quary'+ [SELECT Id,Primary_Renewal_Owner__c,Renewal_Manager__c,Main_Monday_Account_Related__c,(SELECT Id, OwnerId,Channel_Partner__c,Owner_is_Partner__c,Owner.Segment__c,Owner.Business_Role__c,Owner.Profile.Name FROM Accounts__r ORDER BY ARR__C DESC NULLS LAST LIMIT 1) FROM Contract WHERE Status__c = 'Active' and (EndDate =: con.EndDate or Define_Default_PRO_Assignment__c=true)  and Primary_Renewal_Owner__c = null and Main_Monday_Account_Related__c <> null ORDER BY EndDate DESC]);
        Test.startTest();
        Batch_DefineDefaultPROOnContract batch = new Batch_DefineDefaultPROOnContract();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        con=[SELECT Primary_Renewal_Owner__c,Name FROM Contract WHERE Name = 'Test contract 5' LIMIT 1]; 
        system.debug('Noam Contract 4- CO SELL'+con.Primary_Renewal_Owner__c);
        system.assertEquals(con.Primary_Renewal_Owner__c, maCoSellSalesLeadNoPod.OwnerId); //following the logic, the Sales Pod RM should be the PRO

    }

    @IsTest
    static void maOwnerIsSalesPROShouldBeAccountOwner() {
        Account maSalesEntAM = [SELECT Id,Name,OwnerId,ARR__c FROM Account WHERE ARR__c=150  LIMIT 1 ];
        Contract con = [SELECT Id,Name,Primary_Renewal_Owner__c FROM Contract WHERE Name = 'Test contract 2' LIMIT 1 ];
        Pod_Assignment__c podForPorEntAM = [SELECT Id,Sales_Pod_Lead__c,Renewal_Manager__c FROM Pod_Assignment__c WHERE Sales_Pod_Lead__c =: maSalesEntAM.OwnerId];
        con.EndDate=Date.today().addMonths(6); //contract that will be ended in 6 months, should be triggerd the PRO schduled batach
        update con;
        Test.startTest();
        Batch_DefineDefaultPROOnContract batch = new Batch_DefineDefaultPROOnContract();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        con=[SELECT Primary_Renewal_Owner__c,Renewal_Manager__c,Name FROM Contract WHERE Name = 'Test contract 2' LIMIT 1]; 
        system.assertEquals(con.Primary_Renewal_Owner__c, maSalesEntAM.OwnerId); //following the logic, the PRO should be the account owner
        system.assertEquals(con.Renewal_Manager__c, podForPorEntAM.Renewal_Manager__c); //following the logic, the PRO RM should be based on Pod
    }

    @IsTest
    static void maOwnerIsSalesPROShouldBeRenewalManager() {
        Account maSalesSMBAE = [SELECT Id,OwnerId,ARR__c FROM Account WHERE ARR__c =200  LIMIT 1 ];
        Contract con = [SELECT Id,Name,Primary_Renewal_Owner__c FROM Contract WHERE Name = 'Test contract 3' LIMIT 1 ];
        Pod_Assignment__c pod = [SELECT Id,Renewal_Manager__c FROM Pod_Assignment__c WHERE Sales_Pod_Lead__c =: maSalesSMBAE.OwnerId LIMIT 1];
        con.EndDate=Date.today().addMonths(6); //contract that will be ended in 6 months, should be triggerd the PRO schduled batach
        update con;
        system.debug('Noam con'+con.Primary_Renewal_Owner__c);
        system.debug('Noam con before change '+con);
        Test.startTest();
        Batch_DefineDefaultPROOnContract batch = new Batch_DefineDefaultPROOnContract();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        con=[SELECT Primary_Renewal_Owner__c,Renewal_Manager__c,Name FROM Contract WHERE Name = 'Test contract 3' LIMIT 1]; 
        system.debug('Noam con after change '+con);
        system.assertEquals(con.Primary_Renewal_Owner__c, pod.Renewal_Manager__c); //following the logic, the PRO should be the RM from the Pod Assignment
        system.assertEquals(con.Renewal_Manager__c, pod.Renewal_Manager__c);
    }
    
}