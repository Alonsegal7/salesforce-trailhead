public without sharing class Lead_RelatedCompanyLogic {
    
    //expects raw signups, will determine if the leads has a related company and will update the company, runs in before (if moved to after make sure to send all the fields)
    public static void updateRelatedCompany(List<Lead> rawLeads, Map<Id,Lead> oldLeads) { 
        try {
            Set<Lead> rawSignUpsWithDomain = new Set<Lead>();
            Set<Lead> leadsWithEmployeeNumberUpdateToCompany = new Set<Lead>();
            Set<String> domainsFromLeads = new Set<String>();
            for(Lead lead : rawLeads) {
                if(lead.RecordTypeId == Utilities.rawSignupRecordTypeId && !String.isBlank(lead.BB_Account_Domain__c) && String.isBlank(lead.Signup_Cleanup_Reason__c) && 
                (oldLeads == null || String.isBlank(oldLeads?.get(lead.Id).BB_Account_Domain__c) || lead.Manual_Trigger__c == 'Run Related Company Logic')) {
                    rawSignUpsWithDomain.add(lead);
                    domainsFromLeads.add(lead.BB_Account_Domain__c);
                    if(lead.Manual_Trigger__c == 'Run Related Company Logic') lead.Manual_Trigger__c = '';
                }
                //NumberOfEmployees was updated on lead that has a company
                if(oldLeads != null && lead.NumberOfEmployees != null && lead.Related_Company__c != null && lead.NumberOfEmployees != oldLeads.get(lead.Id).NumberOfEmployees) {
                    leadsWithEmployeeNumberUpdateToCompany.add(lead);
                }
            }
            if (rawSignUpsWithDomain.isEmpty() && leadsWithEmployeeNumberUpdateToCompany.isEmpty()) return;
            if (!rawSignUpsWithDomain.isEmpty()) {
                List<Lead> relatedLeads = new List<Lead>();
                List<Lead> newLeads = new List<Lead>();
                List<Company_Domain__c> relatedCompanyDomains = new List<Company_Domain__c>([SELECT Id, Company__c, Domain__c FROM Company_Domain__c WHERE Domain__c IN: domainsFromLeads]);
                Map<String,Id> domainToCompanyId = new Map<String,Id>();
                for (Company_Domain__c cd : relatedCompanyDomains) {
                    domainToCompanyId.put(cd.Domain__c, cd.Company__c);
                }
                for (Lead lead : rawSignUpsWithDomain) {
                    if(domainToCompanyId.containsKey(lead.BB_Account_Domain__c)) {
                        lead.Related_Company__c = domainToCompanyId.get(lead.BB_Account_Domain__c);
                        lead.Domain_Exists_On_Creation__c = true;
                        relatedLeads.add(lead);
                    }
                    else {
                        lead.Domain_Exists_On_Creation__c = false;
                        newLeads.add(lead);
                    }
                    lead.Related_Lead_Code__c = true;
                }
                if(relatedLeads.size()>0) {
                    assignOwnerForRelatedLeads(relatedLeads);
                    leadsWithEmployeeNumberUpdateToCompany.addAll(relatedLeads);
                }
                if(newLeads.size()>0) createCompany(newLeads);
            }
            if (!leadsWithEmployeeNumberUpdateToCompany.isEmpty()) {
                updateNumberOfEmployeesOnCompany(leadsWithEmployeeNumberUpdateToCompany);
            }
        } catch (Exception e) {
            Utilities.sendDebugEmail('Error in Lead_RelatedCompanyLogic ',e,e.getMessage());
        }
    }

    public static void assignOwnerForRelatedLeads(List<Lead> relatedLeads) {  //design lucid chart: https://lucid.app/lucidchart/0738f8d9-b813-4a55-a37d-cff87dcf3da1/edit?invitationId=inv_9b44939d-0b8d-4d4f-9475-9fab64e63a60&page=qCpFz9NWg1Nr#
 
        Set<Id> relatedCompaniesId = new Set<Id>();
        for(Lead lead : relatedLeads) {
            relatedCompaniesId.add(lead.Related_Company__c);
        }
        Map<Id,Map<String, Object>> companiesWithRelatedObjects = getCompanyWithRelatedObjects(relatedCompaniesId);

        //build a map of global company to it's regional companies and for each lead check if there's a regional company in the same region
        Map<Id,List<Account>> companyToRegionalCompanies = Account_RegionalCompanyService.getMapCompanyToRegionals(relatedCompaniesId);
        Map<Id,Account> relatedCompaniesMap = new Map<Id,Account>([SELECT Id, Account_Territory__c, Strategic_receiver__c, OwnerId, Is_Globally_Managed__c FROM Account WHERE Id IN: relatedCompaniesId]);
        Boolean foundMatch;
        for(Lead lead : relatedLeads) {
            foundMatch = false;
            //1 - regional company ownership check 
            if(companyToRegionalCompanies.containsKey(lead.Related_Company__c)) {
                List<Account> regionalCompanies = companyToRegionalCompanies.get(lead.Related_Company__c);
                System.debug('Lead_RelatedCompanyLogic regionalCompanies: '+regionalCompanies);
                for(Account regComp : regionalCompanies) {
                    if(lead.Region__c == regComp.Region__c) { //found related company
                        if(isUserActive(regComp.Strategic_receiver__c)) {
                            updateRelated(lead, regComp.Strategic_receiver__c, 'Regional Company Lead Receiver', regComp.Id);
                            foundMatch = true;
                        }
                        else if (isUserActive(regComp.OwnerId)) {
                            updateRelated(lead, regComp.OwnerId, 'Regional Company Owner', regComp.Id);
                            foundMatch = true;
                        }
                        else break; //found regional company with inactive stratigic reciever and inactive owner, moving to global company ownership check
                    }
                }
            }
            if(foundMatch) continue;
            //2 - didn't find match yet, global company ownership check
            Account relatedCompany = relatedCompaniesMap.get(lead.Related_Company__c);
            if(isUserActive(relatedCompany.Strategic_receiver__c)) {
                updateRelated(lead, relatedCompany.Strategic_receiver__c, 'Global Company Lead Receiver', relatedCompany.Id);
                continue; 
            }
            else if (isUserActive(relatedCompany.OwnerId)) {
                updateRelated(lead, relatedCompany.OwnerId, 'Global Company Owner', relatedCompany.Id);
                continue;
            }
            //3 - global owner and stratigic reciever are inactive, proceeding to assignment based on paying monday accounts and open opps
            else { 
                List<Account> payingMAs = (List<Account>)companiesWithRelatedObjects.get(relatedCompany.Id)?.get('paying_monday_accounts');
                List<Opportunity> openOpps = (List<Opportunity>)companiesWithRelatedObjects.get(relatedCompany.Id)?.get('open_opportunities');
                if (relatedCompany.Is_Globally_Managed__c) { //MM/SMB company, global ownership
                    if(payingMAs != null && isUserActive(payingMAs[0]?.OwnerId)) { //owner of the highest paying monday accounts globally
                        updateRelated(lead, payingMAs[0].OwnerId, 'Paying Monday Account Owner', payingMAs[0].Id);
                    }
                    else if(openOpps != null && isUserActive(openOpps[0]?.OwnerId)) { //owner of the highest amount opp globally
                        updateRelated(lead, openOpps[0].OwnerId, 'Open Oppty Owner', openOpps[0].Id);
                    }
                    else {
                        lead.Related_Lead_Code__c = true;
                        lead.Distribution_reason__c = 'No Assignment Found';
                    }
                    continue;
                }
                else { //ENT company (regionally managed), check for paying MAs and open opps in the same country
                    if (payingMAs != null) {
                        for(Account ma : payingMAs) {
                            if(ma.BillingCountry == lead.Country && isUserActive(ma.OwnerId)) {
                                updateRelated(lead, ma.OwnerId, 'Paying Monday Account Owner', ma.Id);
                                foundMatch = true;
                                break;
                            }
                        }
                    }
                    if(foundMatch) continue;
                    if (openOpps != null) {
                        for(Opportunity opp : openOpps) {
                            if(opp.Monday_Account_Country__c == lead.Country && isUserActive(opp.OwnerId)) {
                                updateRelated(lead, opp.OwnerId, 'Open Oppty Owner', opp.Id);
                                foundMatch = true;
                                break;
                            }
                        }
                    }
                    if(foundMatch) continue;
                    lead.Related_Lead_Code__c = true;
                    lead.Distribution_reason__c = 'No Assignment Found';
                }
            }
        }
    }

    private static void updateRelated(Lead leadToUpdate, Id newOwnerId, String reason, Id recordIdForUrl) {
        leadToUpdate.OwnerId = newOwnerId;
        leadToUpdate.Distribution_reason__c = 'Related';
        leadToUpdate.Related_Distribution_Reason__c = reason;
        leadToUpdate.Related_Record_URL__c = 'https://monday.lightning.force.com/' +recordIdForUrl;
        leadToUpdate.Status = 'Received';
        leadToUpdate.Related_Lead_Code__c = true;
        //add logic to send notification to new lead owner
    }

    private static Boolean isUserActive(Id userId) {
        return (Utilities.activeUsersMap.containsKey(userId) && userId != Utilities.AccountsPoolUserId); //check if the user is active and not accounts pool
    }

    private static Map<Id,Map<String, Object>> getCompanyWithRelatedObjects(Set<Id> companyIds) {
        Map<Id,Map<String, Object>> companyRelatedObjects = new Map<Id,Map<String, Object>>();
        List<Account> mondayAccountsList = [SELECT Id, OwnerId, BillingCountry, Company__c FROM Account WHERE Eligible_For_Related__c = true AND RecordTypeId =: Utilities.MARecordTypeId AND Company__c IN: companyIds AND Arr__c>0 ORDER BY Arr__c DESC]; 
        List<Opportunity> oppList = [SELECT Id, OwnerId, Monday_Account_Country__c, Company__c FROM Opportunity WHERE Eligible_For_Related__c = true AND Company__c IN: companyIds AND IsClosed = false ORDER BY CreatedDate DESC];
        for(Account ma : mondayAccountsList) {
            if (companyRelatedObjects.containsKey(ma.Company__c)) {
                if (companyRelatedObjects.get(ma.Company__c).containsKey('paying_monday_accounts')) {
                    ((List<Account>)companyRelatedObjects.get(ma.Company__c).get('paying_monday_accounts')).add(ma);
                }
                else {
                    companyRelatedObjects.get(ma.Company__c).put('paying_monday_accounts', new List<Account>{ma});
                }
            }
            else {
                companyRelatedObjects.put(ma.Company__c, new Map<String, Object>{
                    'paying_monday_accounts' => new List<Account>{ma}
                });
            } 
        }
        for(Opportunity opp : oppList) {
            if (companyRelatedObjects.containsKey(opp.Company__c)) {
                if (companyRelatedObjects.get(opp.Company__c).containsKey('open_opportunities')) {
                    ((List<Opportunity>)companyRelatedObjects.get(opp.Company__c).get('open_opportunities')).add(opp);
                }
                else {
                    companyRelatedObjects.get(opp.Company__c).put('open_opportunities', new List<Opportunity>{opp});
                }
            }
            else {
                companyRelatedObjects.put(opp.Company__c, new Map<String, Object>{
                    'open_opportunities' => new List<Opportunity>{opp}
                });
            } 
        }
        return companyRelatedObjects;
    }

    private static void updateNumberOfEmployeesOnCompany(Set<Lead> leadsToCheck) {
        Set<Id> relatedCompanyIds = new Set<Id>();
        for (Lead lead : leadsToCheck) {
            relatedCompanyIds.add(lead.Related_Company__c);
        }
        if (relatedCompanyIds.isEmpty()) return;
        Map<Id,Account> companiesMap = new Map<Id,Account>([SELECT Id, NumberOfEmployees FROM Account WHERE Id IN: relatedCompanyIds]);
        List<Account> companiesToUpdate = new List<Account>();
        for (Lead lead : leadsToCheck) {
            if (lead.NumberOfEmployees != companiesMap.get(lead.Related_Company__c).NumberOfEmployees) {
                companiesToUpdate.add(new Account(Id = lead.Related_Company__c, NumberOfEmployees = lead.NumberOfEmployees));
            }
        }
        update companiesToUpdate;
    }

    public static void createCompany(List<Lead> leadsToCreateCompanyFor) {
        List<Account> companiesToCreate = new List<Account>();
        Map<String, List<Lead>> leadsByDomain = new Map<String, List<Lead>>();
        for (Lead lead : leadsToCreateCompanyFor) {
            if(!leadsByDomain.containsKey(lead.BB_Account_Domain__c)) { //this prevents duplicate company creation when multiple leads in the same bulk has the same domain
                companiesToCreate.add(new Account(
                    Name = lead.Company, 
                    OwnerId = Utilities.AccountsPoolUserId,
                    RecordTypeId = Utilities.CompanyRecordTypeId,
                    Account_Territory__c = 'Global',
                    Website = lead.BB_Account_Domain__c,
                    NumberOfEmployees = lead.NumberOfEmployees,
                    BillingCountryCode = lead.CountryCode,
                    BillingCountry = (Utilities.getRegionMapping())?.get(lead.CountryCode)?.Country_Name__c,
                    BillingCity = lead.City)
                );
                leadsByDomain.put(lead.BB_Account_Domain__c, new List<Lead>{lead});
            }
            else {
                leadsByDomain.get(lead.BB_Account_Domain__c).add(lead);
            }
        }
        insert companiesToCreate;
        for (Account comp : companiesToCreate) {
            for (Lead lead : leadsByDomain.get(comp.Website)) {
                lead.Related_Company__c = comp.Id;
            }
        }
    }
}