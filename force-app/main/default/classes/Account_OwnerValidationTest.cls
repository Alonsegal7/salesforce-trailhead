@isTest
public without sharing class Account_OwnerValidationTest {
    @TestSetup
    static void makeData(){
        Account company = TestObjectCreator.CreateCompany();
        User rep = [SELECT Id FROM User WHERE Group__c = 'Sales' and Seniority__c = 'Rep' and IsActive = true limit 1];
        User bizOps = [SELECT Id FROM User WHERE Group__c = 'BizOps' and IsActive = true limit 1];
        company.OwnerId = rep.Id;
        insert company;
    }

    @isTest
    static void shouldAllowBizOpsToChangeCompanyOwner(){
        //change comp owner from one rep to another as non rep user (admin)
        Account comp = [select Id, OwnerId from Account limit 1];
        User bizOps = [SELECT Id FROM User WHERE Group__c = 'BizOps' and IsActive = true limit 1];
        system.runAs(bizOps) {
            comp.OwnerId = bizOps.Id;
            update comp;
        }
    }
    
    @isTest
    static void shouldAllowRepToChangeGlobalCompanyOwnerFromFlow(){
        Boolean didCatchException = false;
        String exceptionMessage;
        Account comp = [select Id, OwnerId from Account limit 1];
        User rep = [select Id from User where Id =: comp.OwnerId];
        User bizOps = [SELECT Id FROM User WHERE Group__c = 'BizOps' and IsActive = true limit 1];
        comp.OwnerId = bizOps.Id;
        comp.Owner_Change_Unlock__c = true;
        system.runAs(rep){
            try{
                update comp;
            } catch (Exception ex){
                didCatchException = true;
                exceptionMessage = ex.getMessage();
            }
            system.assert(!didCatchException);
        }
    }
    
    @isTest
    static void shouldPreventNonBizOpsToChangeGlobalCompanyOwnerManually(){
        Boolean didCatchException = false;
        String exceptionMessage;
        Account comp = [select Id, OwnerId from Account limit 1];
        User rep = [select Id from User where Id =: comp.OwnerId];
        User bizOps = [SELECT Id FROM User WHERE Group__c = 'BizOps' and IsActive = true limit 1];
        system.runAs(rep){
            try{
                comp.NumberOfEmployees = 2000; //to make sure the company is enterprise and not globally managed
                comp.OwnerId = bizOps.Id;
                update comp;
            } catch (Exception ex){
                didCatchException = true;
                exceptionMessage = ex.getMessage();
            }
            system.assert(exceptionMessage.containsIgnoreCase('Global Company Ownership can only be changed by Bizops and according to the policy.'));
        }
    }

    @isTest
    static void shouldAllowNonBizOpsToChangeSMBCompanyOwnerManually(){
        Boolean didCatchException = false;
        String exceptionMessage;
        Account comp = [select Id, OwnerId from Account limit 1];
        User rep = [select Id from User where Id =: comp.OwnerId];
        User bizOps = [SELECT Id FROM User WHERE Group__c = 'BizOps' and IsActive = true limit 1];
        system.runAs(rep){
            try{
                comp.NumberOfEmployees = 200; //to make sure the company is smb and is globally managed
                comp.OwnerId = bizOps.Id;
                update comp;
            } catch (Exception ex){
                didCatchException = true;
                exceptionMessage = ex.getMessage();
            }
            system.assert(!didCatchException);
        }
    }
}