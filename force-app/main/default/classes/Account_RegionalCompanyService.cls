public without sharing class Account_RegionalCompanyService {

    public static void findOrCreateRegionalCompany(List<Account> newAccounts, map<Id,Account> oldAccounts) {

        System.debug('Entered Account_RegionalCompanyService findOrCreateRegionalCompany');
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
        Id accountsPoolUserId = '0053X00000Bo8ZZQAZ';
        Set<Id> globalCompanysIds = new Set<Id>();
        
        //create the scope
        List<Account> relevantMAs = new List<Account>(); 
        for (Account acc : newAccounts) {
            if (acc.recordTypeId == MARecordTypeId && acc.ParentId != null && acc.Company__c != null && acc.Region__c != null && //prerequisites
            (oldAccounts == null || //new account
            acc.Parent_Regional_Company_Region__c == null || //parent that's not a regional company
            (acc.Manual_Trigger__c == 'Aggregate Territory Accounts' && (oldAccounts.get(acc.Id).Manual_Trigger__c == null || acc.Manual_Trigger__c != oldAccounts.get(acc.Id).Manual_Trigger__c)) || //manual trigger
            (oldAccounts.get(acc.Id).Region__c == null || acc.Region__c != oldAccounts.get(acc.Id).Region__c))) { //region change 
                System.debug('Account_RegionalCompanyService building scope found match');
                relevantMAs.add(acc);
                globalCompanysIds.add(acc.Company__c);
            }
        }
        if (relevantMAs.isEmpty()) return;
        
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

        //remove duplicates, in case the same account entered the trigger twice
        Set<Account> updateMAsDedupSet = new Set<Account>();
        updateMAsDedupSet.addAll(updatedMAs);
        List<Account> updatedMAsDedup = new List<Account>();
        updatedMAsDedup.addAll(updateMAsDedupSet);
        try {
            update updatedMAsDedup;
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
        List<Account> existingRegionalCompaniesList = new List<Account>([SELECT Id, Account_Territory__c, Region__c, Company__c, ParentId, Named_Account__c FROM Account WHERE ParentId IN: companyIDs AND Account_Territory__c = 'Regional']);
        Map<Id,List<Account>> companiesWithChildRegionalCompanies = new Map<Id,List<Account>>();
        for (Account acc : existingRegionalCompaniesList) {
            if (companiesWithChildRegionalCompanies.containsKey(acc.ParentId)) {
                companiesWithChildRegionalCompanies.get(acc.ParentId).add(acc);
            }
            else {
                companiesWithChildRegionalCompanies.put(acc.ParentId,new List<Account>{acc});
            }   
        }
        Boolean isNamedOnCreate = false;
        for (Account acc : inputMAs) {
            if (companiesWithChildRegionalCompanies.containsKey(acc.Company__c)) { //the global company has regional companies
                for(Account regAcc : companiesWithChildRegionalCompanies.get(acc.Company__c)) { //search the MA's region in the regional companies
                if (regAcc.Region__c == acc.Region__c) {
                        isNamedOnCreate = (acc.CreatedDate.addHours(24) >= Datetime.now() && regAcc.Named_Account__c); //monday account created today and it's regional company is a named company, used to mark the account as named on creation in the next line
                        outputMAs.add(new Account(Id = acc.Id, ParentId = regAcc.Id, Manual_Trigger__c = '', Named_Account_on_Creation__c = isNamedOnCreate));
                    }
                }
            }
        }
        return outputMAs;
    }
    
    //method to be called when a regional company is created or updated
    public static void updateRegionalCompanyOnRelatedObjects(List<Account> newAccounts, map<Id,Account> oldAccounts){
        Map<Id,List<Account>> regionalCompaniesByGlobalCompanyId = new Map<Id,List<Account>>();
        System.debug('Account_RegionalCompanyService updateRegionalCompanyOnRelatedObjects entered');
        for (Account acc : newAccounts) {
            if (acc.Account_Territory__c == 'Regional' && acc.Company__c != null && acc.ParentId != null && (oldAccounts == null || acc.Region__c != oldAccounts.get(acc.Id).Region__c)) { //new regional company or a region change
                if (regionalCompaniesByGlobalCompanyId.containsKey(acc.Company__c)) {
                    regionalCompaniesByGlobalCompanyId.get(acc.Company__c).add(acc);
                }
                else {
                    regionalCompaniesByGlobalCompanyId.put(acc.Company__c,new List<Account>{acc});
                } 
            }
        }
        if (regionalCompaniesByGlobalCompanyId.keySet().isEmpty()) return;
        
        //check if any of the leads under the global company is on the same region and if so mark the new regional company as their Parent Company
        List<Lead> relatedLeads = new List<Lead>([SELECT Id, Region__c, Related_Company__c, Parent_Company__c FROM Lead WHERE Status != 'Unqualified' AND Parent_Company__c = null AND Related_Company__c IN: regionalCompaniesByGlobalCompanyId.keySet()]);
        if (!relatedLeads.isEmpty()) {
            for (Lead lead : relatedLeads) {
                for (Account regCompany : regionalCompaniesByGlobalCompanyId.get(lead.Related_Company__c)) {
                    if (lead.Region__c == regCompany.Region__c) {
                        lead.Parent_Company__c = regCompany.Id;
                    }    
                }
            }
            try {
                update relatedLeads;
            } catch (Exception e) {
                System.debug('Account_RegionalCompanyService updateRegionalCompanyOnRelatedObjects error updating relatedLeads: '+ e.getMessage());
            }
        }
        
        //check if any of the opportunities under the global company is on the same region and if so mark the new regional company as their Parent Company
        List<Opportunity> relatedOpps = new List<Opportunity>([SELECT Id, Account_Region__c, Company__c, Parent_Company__c FROM Opportunity WHERE Parent_Company__c = null AND Company__c IN: regionalCompaniesByGlobalCompanyId.keySet()]);
        if (!relatedOpps.isEmpty()){
            for (Opportunity opp : relatedOpps) {
                for (Account regCompany : regionalCompaniesByGlobalCompanyId.get(opp.Company__c)) {
                    if (opp.Account_Region__c == regCompany.Region__c) {
                        opp.Parent_Company__c = regCompany.Id;
                    }    
                }
            }
            try {
                update relatedOpps;
            } catch (Exception e) {
                System.debug('Account_RegionalCompanyService updateRegionalCompanyOnRelatedObjects error updating relatedOpps: '+ e.getMessage());
            }
        }
    }

    //method to be called from the lead trigger
    public static void linkLeadsToExistingRegionalCompanies(List<Lead> newLeads, map<Id,Lead> oldLeads) {
        //create the scope
        List<Lead> inputLeads = new List<Lead>(); 
        Set<Id> companyIDs = new Set<Id>();
        for (Lead lead : newLeads) {
            if (lead.Related_Company__c != null && lead.Region__c != null && //prerequisites
            (oldLeads == null || //new lead 
            (oldLeads.get(lead.Id).Region__c == null || lead.Region__c != oldLeads.get(lead.Id).Region__c) || //region change 
            (lead.Manual_Trigger__c == 'Match Parent' && (oldLeads.get(lead.Id).Manual_Trigger__c == null || lead.Manual_Trigger__c != oldLeads.get(lead.Id).Manual_Trigger__c)) || //manual trigger
            (lead.Status == 'Received' && oldLeads.get(lead.Id).Status != null && oldLeads.get(lead.Id).Status == 'Unqualified') || //resubmit
            (oldLeads.get(lead.Id).Related_Company__c == null || lead.Related_Company__c != oldLeads.get(lead.Id).Related_Company__c))) { //company change 
                System.debug('Account_RegionalCompanyService linkLeadsToExistingRegionalCompanies building scope found match');
                inputLeads.add(lead);
                companyIDs.add(lead.Related_Company__c);
                if (lead.Manual_Trigger__c == 'Match Parent') lead.Manual_Trigger__c = '';
            }
        }
        if (inputLeads.isEmpty()) return;
        Map<Id,List<Account>> companiesWithChildRegionalCompanies = getMapCompanyToRegionals(companyIDs);

        //find the matching regional company for each lead 
        for (Lead lead : inputLeads) {
            if (companiesWithChildRegionalCompanies.containsKey(lead.Related_Company__c)) { //the global company has regional companies
                for(Account regAcc : companiesWithChildRegionalCompanies.get(lead.Related_Company__c)) { //search the Lead's region in the regional companies
                    if (regAcc.Region__c == lead.Region__c) {
                        lead.Parent_Company__c = regAcc.Id;
                        if ((oldLeads == null || lead.CreatedDate.addHours(24) >= Datetime.now()) && regAcc.Named_Account__c) lead.Named_Account_on_Creation__c = true;
                    }
                }
            }
        }
    }

    //method to be called from the opportunity trigger
    public static void linkOppsToExistingRegionalCompanies(List<Opportunity> newOpps, map<Id,Opportunity> oldOpps) {
        //create the scope
        List<Opportunity> inputOpps = new List<Opportunity>(); 
        Set<Id> companyIDs = new Set<Id>();
        for (Opportunity opp : newOpps) {
            if (opp.Company__c != null && opp.Account_Region__c != null && //prerequisites
            (oldOpps == null || //new opp
            (oldOpps.get(opp.Id).Account_Region__c == null || opp.Account_Region__c != oldOpps.get(opp.Id).Account_Region__c) || //region change 
            (opp.Manual_Trigger__c == 'Match Parent' && (oldOpps.get(opp.Id).Manual_Trigger__c == null || opp.Manual_Trigger__c != oldOpps.get(opp.Id).Manual_Trigger__c)) || //manual trigger
            (oldOpps.get(opp.Id).Company__c == null || opp.Company__c != oldOpps.get(opp.Id).Company__c))) { //company change 
                inputOpps.add(opp);
                companyIDs.add(opp.Company__c);
                if (opp.Manual_Trigger__c == 'Match Parent') opp.Manual_Trigger__c = '';
            }
        }
        if (inputOpps.isEmpty()) return;

        Map<Id,List<Account>> companiesWithChildRegionalCompanies = getMapCompanyToRegionals(companyIDs);

        //find the matching regional company for each opp 
        for (Opportunity opp : inputOpps) {
            if (companiesWithChildRegionalCompanies.containsKey(opp.Company__c)) { //the global company has regional companies
                for(Account regAcc : companiesWithChildRegionalCompanies.get(opp.Company__c)) { //search the Opportunity's region in the regional companies
                    if (regAcc.Region__c == opp.Account_Region__c) {
                        opp.Parent_Company__c = regAcc.Id;
                        if ((oldOpps == null || opp.CreatedDate.addHours(24) >= Datetime.now()) && regAcc.Named_Account__c) opp.Named_Account_on_Creation__c = true;
                    }
                }
            }
        }
    }

    //map the global companies to their regional companies
    public static Map<Id,List<Account>> getMapCompanyToRegionals(Set<Id> companyIDs) {
        List<Account> existingRegionalCompaniesList = new List<Account>([SELECT Id, Account_Territory__c, Region__c, Company__c, ParentId, Named_Account__c FROM Account WHERE ParentId IN: companyIDs AND Account_Territory__c = 'Regional']);
        Map<Id,List<Account>> companiesWithChildRegionalCompanies = new Map<Id,List<Account>>();
        for (Account acc : existingRegionalCompaniesList) {
            if (companiesWithChildRegionalCompanies.containsKey(acc.ParentId)) {
                companiesWithChildRegionalCompanies.get(acc.ParentId).add(acc);
            }
            else {
                companiesWithChildRegionalCompanies.put(acc.ParentId,new List<Account>{acc});
            }   
        }
        return companiesWithChildRegionalCompanies;
    }
}