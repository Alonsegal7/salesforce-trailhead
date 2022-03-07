public without sharing class Account_RegionalCompanyService {

    public static void findOrCreateRegionalCompany(List<Account> newAccounts, map<Id,Account> oldAccounts) {

        System.debug('Entered Account_RegionalCompanyService findOrCreateRegionalCompany');
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Id accountsPoolUserId = '0053X00000Bo8ZZQAZ';
        Set<Id> globalCompanysIds = new Set<Id>();
        
        //create the scope
        List<Account> relevantMAs = new List<Account>(); 
        for (Account acc : [SELECT Id, Name, recordTypeId, ParentId, Parent.Account_Territory__c, Company__c, Region__c, Manual_Trigger__c FROM Account WHERE Id IN: newAccounts]) {
            if (acc.recordTypeId == MARecordTypeId && acc.ParentId != null && acc.Company__c != null && acc.Region__c != null && //prerequisites
            (acc.Parent.Account_Territory__c != 'Regional' || //parent that's not a regional company
            acc.Manual_Trigger__c == 'Aggregate Territory Accounts' || //manual trigger
            (oldAccounts!=null && oldAccounts.get(acc.Id).Region__c!=null && acc.Region__c != oldAccounts.get(acc.Id).Region__c))) { //region change 
                System.debug('Account_RegionalCompanyService building scope found match');
                if(acc.Manual_Trigger__c == 'Aggregate Territory Accounts') acc.Manual_Trigger__c = '';
                relevantMAs.add(acc);
                globalCompanysIds.add(acc.Company__c);
            }
        }
        if (relevantMAs.size() == 0) return;
        
        //from the entire scope, find which MAs already has a regional company in the hirarchy and link those first to the existing regional companies
        
        List<Account> updatedMAs = linkMAsToExistingRegionalCompanies(relevantMAs);
        List<Account> remainingMAs = new List<Account>([SELECT Id, Company__c, Region__c, Parent.Name FROM Account WHERE ID IN: relevantMAs AND ID NOT IN: updatedMAs]);
        
        //create regional companies for the rest
        List<Account> regionalCompaniesToCreate = new List<Account>();
        for (Account acc : remainingMAs) {
            regionalCompaniesToCreate.add(new Account(
                Name = acc.Parent.Name + ' - ' + acc.Region__c,
                Account_Territory__c = 'Regional',
                Region__c = acc.Region__c,
                OwnerId = accountsPoolUserId,
                ParentId = acc.Company__c,
                Company__c = acc.Company__c,
                RecordTypeId = companyRecordTypeId));
        }
        try {
            insert regionalCompaniesToCreate;
        } catch (Exception e) {
            System.debug('Account_RegionalCompanyService failed to insert regionalCompaniesToCreate: ' + e.getMessage());
        }
        
        //link the remaining MAs to the new regional companies that were created
        
        updatedMAs.addall(linkMAsToExistingRegionalCompanies(relevantMAs));
        try {
            update updatedMAs;
        } catch (Exception e) {
            System.debug('Account_RegionalCompanyService failed to upadte updatedMAs: ' + e.getMessage());
        }

        //update the companies to global
        List<Account> globalCompaniesToUpdate = new List<Account>([SELECT Id, Account_Territory__c FROM Account WHERE RecordTypeId =: companyRecordTypeId AND Account_Territory__c != 'Global' AND Id IN: globalCompanysIds]);
        if (globalCompaniesToUpdate.size() > 0) {
            for (Account acc : globalCompaniesToUpdate) {
                acc.Account_Territory__c = 'Global';
            }
            try {
                update globalCompaniesToUpdate;
            } catch (Exception e) {
                System.debug('Account_RegionalCompanyService failed to update globalCompaniesToUpdate: ' + e.getMessage());
            }
        }
    }

    public static List<Account> linkMAsToExistingRegionalCompanies(List<Account> inputMAs) {
        List<Account> outputMAs = new List<Account>(); 
        Set<Id> companyIDs = new Set<Id>();
        for (Account acc : inputMAs) {
            companyIDs.add(acc.Company__c);
        }
        List<Account> existingRegionalCompaniesList = new List<Account>([SELECT Id, Account_Territory__c, Region__c, Company__c, ParentId FROM Account WHERE ParentId IN: companyIDs AND Account_Territory__c = 'Regional']);
        Map<Id,List<Account>> companiesWithChildRegionalCompanies = new Map<Id,List<Account>>();
        for (Account acc : existingRegionalCompaniesList) {
            if (companiesWithChildRegionalCompanies.containsKey(acc.ParentId)) {
                companiesWithChildRegionalCompanies.get(acc.ParentId).add(acc);
            }
            else {
                companiesWithChildRegionalCompanies.put(acc.ParentId,new List<Account>{acc});
            }   
        }
        for (Account acc : inputMAs) {
            if (companiesWithChildRegionalCompanies.containsKey(acc.Company__c)) { //the global company has regional companies
                for(Account regAcc : companiesWithChildRegionalCompanies.get(acc.Company__c)) { //search the MA's region in the regional companies
                    if (regAcc.Region__c == acc.Region__c) {
                        outputMAs.add(new Account(Id = acc.Id, ParentId = regAcc.Id, Manual_Trigger__c = ''));
                    }
                }
            }
        }
        return outputMAs;
    } 
}
