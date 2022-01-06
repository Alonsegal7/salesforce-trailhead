@isTest
public without sharing class Account_OwnerValidationTest {
    @TestSetup
    static void makeData(){
        Account company = TestObjectCreator.CreateCompany();
        company.OwnerId = [select Id from User where Group__c = 'Sales' and Seniority__c = 'Rep' and IsActive = true limit 1].Id;
        insert company;
    }

    static testMethod void testUpdateAsNonRep() {   
        //change comp owner from one rep to another as non rep user (admin)
        Account comp = [select Id, OwnerId from Account limit 1];
        comp.OwnerId = [select Id from User where Group__c = 'Sales' and Seniority__c = 'Rep' and IsActive = true and Id !=: comp.OwnerId limit 1].Id;
        system.debug('testUpdateAsNonRep comp.OwnerId: ' + comp.OwnerId);
        update comp;
    }

    static testMethod void testUpdateAsRep() {   
        //change comp owner from one rep to another as a rep user 
        Account comp = [select Id, OwnerId from Account limit 1];
        User rep = [select Id from User where Id =: comp.OwnerId];
        comp.OwnerId = [select Id from User where Group__c = 'Sales' and Seniority__c = 'Rep' and IsActive = true and Id !=: rep.Id limit 1].Id;
        system.debug('testUpdateAsNonRep comp.OwnerId: ' + comp.OwnerId);
        system.runAs(rep){
            try{
                update comp;
            } catch (Exception ex){
                system.debug(ex.getMessage());
                system.assertEquals(true, ex.getMessage().containsIgnoreCase('Only sales management can change company owners'));
            }
        }
    }
}
