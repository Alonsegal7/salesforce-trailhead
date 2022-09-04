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
        //creatr partner contact
        Contact con = new Contact(Email='demo1@randomdemodomain.com', FirstName = 'test', LastName = 'bla', AccountId = partnersList.get(0).Id);
        insert con;
        List<User> usersToCreate = new List<User>();
        //create partner user + partner manager user
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community Custom'];
        profile profilePartnerManager =[SELECT Id FROM Profile WHERE Name='System Administrator'];
        User userManager = TestUtils.getUserWithoutRole(profilePartnerManager);
        insert userManager;

		User partnerUser = new User(ContactId = con.Id, Alias='standt1', ManagerId=userManager.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
        usersToCreate.add(partnerUser);
        //create sales user - Business role AM + Segment Enterprise  
        Profile profileIdForAM = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1SalesAMEnt = TestUtils.getUserWithoutRole(profileIdForAM);
        user1SalesAMEnt.Segment__c = 'Enterprise';
        user1SalesAMEnt.Group__c='Sales';
        user1SalesAMEnt.Business_Role__c = 'AM';
        usersToCreate.add(user1SalesAMEnt);
        //create sales user - Business role AE + Segment SMB 
        Profile profileIdForAE = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user2SalesAESmb = TestUtils.getUserWithoutRole(profileIdForAE);
        user2SalesAESmb.Segment__c = 'SMB';
        user2SalesAESmb.Group__c='Sales';
        user2SalesAESmb.Business_Role__c = 'AE';
        usersToCreate.add(user2SalesAESmb);
        //create renewal user - for Pod assignment
        Profile profileIdRenewal = [SELECT Id FROM Profile WHERE Name = 'Renewals'];
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

        insert podsToCreate;

        //update contracts with main monday accounts related
        List<Contract> contractsToUpdate = new List<Contract>();
        contract1.Main_Monday_Account_Related__c = maPartner.id;
        contractsToUpdate.add(contract1);
        contract2.Main_Monday_Account_Related__c = maSalesEntAM.id;
        contractsToUpdate.add(contract2);
        contract3.Main_Monday_Account_Related__c = maSalesSmbAE.id;
        contractsToUpdate.add(contract3);

        update contractsToUpdate;

        //creation of Pod Assignment for Saels rep (AM + Segment ENT)
        // Pod_Assignment__c podForAM= new Pod_Assignment__c(
        //         Sales_Pod_Lead__c=user1SalesAMEnt.Id,
        //         Pod_Type__c='Sales',
        //         Pod_Start_Date__c=date.today(),
        //         Renewal_Manager__c=renewalUser.Id,
        //         Status__c='Active');
        // insert podForPorEntAM;
    }
    @isTest
    static void maOwnerIsPartnerPROShouldBeAccountOwner() {
        Account maPartner = [SELECT Id,Name,ARR__c,OwnerId FROM Account WHERE ARR__c = 100 LIMIT 1 ];
        Contract con = [SELECT Id, Name,Primary_Renewal_Owner__c FROM Contract WHERE Name = 'Test contract 1' LIMIT 1 ];
        Pod_Assignment__c pod = [SELECT Id,Renewal_Manager__c FROM Pod_Assignment__c WHERE Pod_Type__c='Partners' LIMIT 1];
        con.EndDate=Date.today().addMonths(6); //contract that will be ended in 6 months, should be triggerd the PRO schduled batach
        update con;
        Test.startTest();
        Batch_DefineDefaultPROOnContract batch = new Batch_DefineDefaultPROOnContract();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        con=[SELECT Primary_Renewal_Owner__c,Name FROM Contract WHERE Name = 'Test contract 1' LIMIT 1]; 
       system.assertEquals(con.Primary_Renewal_Owner__c, maPartner.OwnerId); //following the logic, the Account Owner should be the RM from the Pod Assignment
    }  
    @IsTest
    static void maOwnerIsPartnerPROIsRenewalManager() {
    }

    @IsTest
    static void maOwnerIsSalesPROShouldBeAccountOwner() {
        Account maSalesEntAM = [SELECT Id,Name,OwnerId,ARR__c FROM Account WHERE ARR__c=150  LIMIT 1 ];
        Contract con = [SELECT Id,Name,Primary_Renewal_Owner__c FROM Contract WHERE Name = 'Test contract 2' LIMIT 1 ];
        con.EndDate=Date.today().addMonths(6); //contract that will be ended in 6 months, should be triggerd the PRO schduled batach
        update con;
        Test.startTest();
        Batch_DefineDefaultPROOnContract batch = new Batch_DefineDefaultPROOnContract();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        con=[SELECT Primary_Renewal_Owner__c,Name FROM Contract WHERE Name = 'Test contract 2' LIMIT 1]; 
        system.assertEquals(con.Primary_Renewal_Owner__c, maSalesEntAM.OwnerId); //following the logic, the PRO should be the account owner
    }

    @IsTest
    static void maOwnerIsSalesPROShouldBeRenewalManager() {
        Account maSalesSMBAE = [SELECT Id,Name,ARR__c FROM Account WHERE ARR__c =200  LIMIT 1 ];
        Contract con = [SELECT Id,Name,Primary_Renewal_Owner__c FROM Contract WHERE Name = 'Test contract 3' LIMIT 1 ];
        Pod_Assignment__c pod = [SELECT Id,Renewal_Manager__c FROM Pod_Assignment__c WHERE Pod_Type__c='Sales' LIMIT 1];
        con.EndDate=Date.today().addMonths(6); //contract that will be ended in 6 months, should be triggerd the PRO schduled batach
        update con;
        system.debug('Noam con'+con.Primary_Renewal_Owner__c);
        system.debug('Noam con before change '+con);
        Test.startTest();
        Batch_DefineDefaultPROOnContract batch = new Batch_DefineDefaultPROOnContract();
        Database.executeBatch(batch, 30);
        Test.stopTest();
        con=[SELECT Primary_Renewal_Owner__c,Name FROM Contract WHERE Name = 'Test contract 3' LIMIT 1]; 
        system.debug('Noam con after change '+con);
        system.assertEquals(con.Primary_Renewal_Owner__c, pod.Renewal_Manager__c); //following the logic, the PRO should be the RM from the Pod Assignment
    }
    
}