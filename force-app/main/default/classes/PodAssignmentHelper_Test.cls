
@isTest
public with sharing class PodAssignmentHelper_Test {
    //for partner accounts that has been created on signed->check if the pod assignment has been created
    static testMethod void PodAssignemntCreationForPartnersCreatedOnSigned(){
        Test.startTest();
        //create partner company anc check if Pod for partner company has been created
        Id ACC_PARTNER_COMP_RT_CONST = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Account PartnerCompany = new Account(
            Name='Partner Company Test',
            RecordTypeId=ACC_PARTNER_COMP_RT_CONST,
            Partner_Company_Status__c = 'Signed',
            Signature_Approval_Status__c = 'Approved');
        insert PartnerCompany;
        system.debug('Noam '+PartnerCompany);
        PartnerCompany = [SELECT Id FROM Account WHERE Partner_Company_Status__c='Signed'  LIMIT 1 ];
        Pod_Assignment__c pod = [SELECT Id,Partner_Pod_Lead_Partner_Company__c FROM Pod_Assignment__c WHERE Partner_Pod_Lead_Partner_Company__c =: PartnerCompany.Id LIMIT 1];
        system.assertEquals(PartnerCompany.Id, pod.Partner_Pod_Lead_Partner_Company__c);
        Test.stopTest(); 
    }  
    //for partner accounts that has been created on New-> changed to signed-> check if the pod assignment has been created
    static testMethod void PodAssignemntCreationForPartnersChangedToSigned(){
        Test.startTest();
        //create partner company on new status
        Id ACC_PARTNER_COMP_RT_CONST = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        Account PartnerCompany = new Account(
            Name='Partner Company Test',
            RecordTypeId=ACC_PARTNER_COMP_RT_CONST,
            Partner_Company_Status__c = 'New',
            Signature_Approval_Status__c = 'Approved');
        insert PartnerCompany;
        //update partner  company to signed
        PartnerCompany.Partner_Company_Status__c='Signed';
        update PartnerCompany; 
        //Pod assignment should be created
        PartnerCompany = [SELECT Id FROM Account WHERE Partner_Company_Status__c='Signed'  LIMIT 1 ];
        Pod_Assignment__c pod = [SELECT Id,Partner_Pod_Lead_Partner_Company__c FROM Pod_Assignment__c WHERE Partner_Pod_Lead_Partner_Company__c =: PartnerCompany.Id LIMIT 1];
        system.assertEquals(PartnerCompany.Id, pod.Partner_Pod_Lead_Partner_Company__c);
        //should be created on Pending assigmnet status with no renewal manager 
        system.assertEquals(pod.Status__c,'Pending Assignment');
        system.assertEquals(pod.Renewal_Manager__c, null);
        Test.stopTest(); 
    } 

    //for rep saels user (AM/AE) that has been created -> create a Pod assignemnt 
    static testMethod void PodAssignemntCreationForSalesUser(){
    Test.startTest();
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    List<User> usersToCreate = new List<User>();
    //create sales user - Business role AM + Segment Enterprise  
    User user1SalesAMEnt = TestUtils.getUserWithoutRole(profileId);
    user1SalesAMEnt.Group__c='Sales';
    user1SalesAMEnt.Business_Role__c ='AM';
    user1SalesAMEnt.Seniority__c ='Rep';
    user1SalesAMEnt.LastName = 'Test AM Pod';
    usersToCreate.add(user1SalesAMEnt);
    //create sales user - Business role AE + Segment SMB ;
    User user2SalesAESmb = TestUtils.getUserWithoutRole(profileId);
    user2SalesAESmb.Group__c='Sales';
    user2SalesAESmb.Business_Role__c ='AE';
    user2SalesAESmb.Seniority__c ='Rep';
    user2SalesAESmb.LastName = 'Test AE Pod';
    usersToCreate.add(user2SalesAESmb);
    System.debug('AE '+ user2SalesAESmb);
    insert usersToCreate;
    //check if for both users the Pod assignment has been created 
    user1SalesAMEnt= [SELECT Id,Business_Role__c FROM User WHERE LastName='Test AM Pod'  LIMIT 1];
    user2SalesAESmb = [SELECT Id FROM User WHERE LastName='Test AE Pod' LIMIT 1];
    Pod_Assignment__c PodForAM = [SELECT Id,Sales_Pod_Lead__c,Renewal_Manager__c,Status__c FROM Pod_Assignment__c WHERE Sales_Pod_Lead__c =: user1SalesAMEnt.Id LIMIT 1];
    Pod_Assignment__c PodForAE = [SELECT Id,Sales_Pod_Lead__c FROM Pod_Assignment__c WHERE Sales_Pod_Lead__c =: user2SalesAESmb.Id LIMIT 1];
    system.assertEquals(user1SalesAMEnt.Id, PodForAM.Sales_Pod_Lead__c);
    system.assertEquals(user2SalesAESmb.Id, PodForAE.Sales_Pod_Lead__c);
    //should be created on Pending assigmnet status with no renewal manager 
    system.assertEquals(PodForAM.Status__c,'Pending Assignment');
    system.assertEquals(PodForAM.Renewal_Manager__c, null);
    Test.stopTest(); 
    }  

    //for user that has been created as another business role (BDR) and changed to be an AM -> create a Pod assignemnt 
    static testMethod void PodAssignemntCreationForUserChangedToSalesUser(){
        Test.startTest();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        List<User> usersToCreate = new List<User>();
        //create BDR user - Business role AM + Segment Enterprise  
        User userBDR = TestUtils.getUserWithoutRole(profileId);
        userBDR.Group__c='Sales';
        userBDR.Business_Role__c ='BDR';
        userBDR.Seniority__c ='Rep';
        userBDR.LastName = 'Test Change To AM Pod';
        insert userBDR;
        userBDR.Business_Role__c='AM';
        update userBDR;
        //check if after updating the user bsuiness role the Pod has been created
        userBDR= [SELECT Id FROM User WHERE LastName='Test Change To AM Pod'  LIMIT 1];
        Pod_Assignment__c PodForNewAM = [SELECT Id,Sales_Pod_Lead__c,Renewal_Manager__c,Status__c FROM Pod_Assignment__c WHERE Sales_Pod_Lead__c =: userBDR.Id LIMIT 1];
        system.assertEquals(userBDR.Id, PodForNewAM.Sales_Pod_Lead__c);
        Test.stopTest(); 
        }

        //when renewal manager is assigned to a Pod assignemnt - start date + statues should be populeted
        static testMethod void PodAssignemntUpdateFieldsRenewalManagerAssigned(){
            Test.startTest();
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            //create a manager user for the sale rep
            User manager = TestUtils.getUserWithoutRole(profileId);
            manager.LastName = 'Manager';
            insert manager;
            //creata a sales rep (Pod lead) + renewal manager - for pod assignment check
            List<User> UsersToCreate = new List<User>();
            User userSales = TestUtils.getUserWithoutRole(profileId);
            userSales.Group__c='Sales';
            userSales.Business_Role__c ='AM';
            userSales.Seniority__c ='Rep';
            userSales.LastName = 'AM Sales rep';
            usersales.ManagerId = manager.Id;
            UsersToCreate.add(userSales);
            Profile profileIdRenewal = [SELECT Id FROM Profile WHERE Name = 'Renewals'];
            User renewalUser = TestUtils.getUserWithoutRole(profileIdRenewal);
            renewalUser.LastName = 'Renewal User';
            renewalUser.ManagerId = manager.Id;
            UsersToCreate.add(renewalUser);
            insert UsersToCreate;
            //create a Partner Company 
            Id ACC_PARTNER_COMP_RT_CONST = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
            Account PartnerCompany = new Account(
                Name='Partner Company Test',
                RecordTypeId=ACC_PARTNER_COMP_RT_CONST,
                Partner_Company_Status__c='Signed',
                OwnerId= manager.id,
                Signature_Approval_Status__c = 'Approved');
            insert PartnerCompany;
            //pods that is awaiting to renewal manager assisgment - when created manager should be defined (Sales + Partners)
            List<Pod_Assignment__c> PodsToCreate = new List<Pod_Assignment__c>();
            Pod_Assignment__c podForPodSales = new Pod_Assignment__c(
                Sales_Pod_Lead__c=userSales.Id,
                Pod_Type__c='Sales',
                Status__c='Pending Assignment');
            PodsToCreate.add(podForPodSales);
            Pod_Assignment__c podForPodPartners = new Pod_Assignment__c(
                Partner_Pod_Lead_Partner_Company__c=PartnerCompany.Id,
                Pod_Type__c='Partners',
                Status__c='Pending Assignment');
            PodsToCreate.add(podForPodPartners);
            insert PodsToCreate;
            //update with RM Pods of Sales + Partners
            List<Pod_Assignment__c> PodsToUpdate = new List<Pod_Assignment__c>();
            podForPodSales = [SELECT Id,Renewal_Manager__c FROM Pod_Assignment__c  WHERE Sales_Pod_Lead__c =: userSales.Id LIMIT 1];
            podForPodSales.Renewal_Manager__c = renewalUser.Id;
            PodsToUpdate.add(podForPodSales);
            podForPodPartners = [SELECT Id,Renewal_Manager__c FROM Pod_Assignment__c  WHERE Partner_Pod_Lead_Partner_Company__c =: PartnerCompany.Id LIMIT 1];
            podForPodPartners.Renewal_Manager__c = renewalUser.Id;
            PodsToUpdate.add(podForPodPartners);
            update PodsToUpdate;
            // check that manager defined correctly (Pod created w/o Pod lead mananger - For Sales)
            //check if after aasigning a renewal manager - relvant fields has been updated 
            podForPodSales = [SELECT Id,Pod_Lead_Manager__c,Pod_Start_Date__c,status__c FROM Pod_Assignment__c  WHERE Sales_Pod_Lead__c =: userSales.Id LIMIT 1];
            // check that manager defined correctly (Pod created w/o Pod lead mananger - For Partners)
            podForPodPartners = [SELECT Id,Pod_Lead_Manager__c FROM Pod_Assignment__c  WHERE Partner_Pod_Lead_Partner_Company__c =: PartnerCompany.Id LIMIT 1];      
            system.assertEquals(podForPodSales.Pod_Lead_Manager__c,manager.Id);
            system.assertEquals(podForPodPartners.Pod_Lead_Manager__c,manager.Id);
            system.assertEquals(podForPodSales.status__c, 'Active');
            system.assertEquals(podForPodSales.Pod_Start_Date__c, system.today());
            Test.stopTest(); 
            }  
          
}