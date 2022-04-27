public with sharing class DealRegistration_Handler {
    public static Id leadPartnerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
    public static Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
    public static Id opportunityPartnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();

    public static Map<String, Country_Region_Mapping__c> regionsMapping = null;
    public static List<Account> relatedRegionalAccount = new List<Account>();
    public static List<Account> relatedGlobalAccount = new List<Account>();

    public static Boolean localCompany = false;
    public static Boolean regionalCompany = false;
    public static Boolean globalCompany = false;
    public static Boolean leadExist = false;
    public static Contact contactPartner;
    public static Account localAccountForLead = new Account();
    public static List<Contact> existingCon = new List<Contact>();
    public static Boolean existingContact = false;
    public static Id opportunityIdFromConvert;
    public static Id maAccountIdFromConvert;

    public static void isBeforeInsert(List<Deal_Registration__c> newLeadRegs, Map<Id, Deal_Registration__c> oldLeadRegs){
        Boolean executeBefore = false;
        List<String> registeredEmail = new List<String>();
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

        try{
            User cpm = [SELECT Id, ManagerId, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            if(cpm != null && cpm.ContactId != null){
                contactPartner = [SELECT Id, AccountId FROM Contact WHERE Id =: cpm.ContactId LIMIT 1];
            }
    
            for(Deal_Registration__c lReg : newLeadRegs){
                if(lReg.Status__c != 'Approved'){
                    executeBefore = true;
                    lReg.Registration_Expiration_Date__c = myDate + 180;
                    if(cpm != null){
                        lReg.CPM__c = cpm.ManagerId;
                    }
                    if(contactPartner != null){
                        lReg.Registered_Partner__c = contactPartner.AccountId;
                    }
                }
                registeredEmail.add(lReg.Registered_Email__c);
            }
            if(registeredEmail != null && registeredEmail.size() > 0 && !registeredEmail.isEmpty()){
                existingCon = [SELECT Id, Email FROM Contact WHERE Email IN: registeredEmail LIMIT 1];
                if(existingCon != null && !existingCon.isEmpty() && existingCon.size() > 0){
                    existingContact = true;
                }
            }
    
            if(executeBefore == true){
                DealRegistration_RegionMapping.leadReg_MapRegions(newLeadRegs, oldLeadRegs);
            }
        }

        catch(Exception e){
            system.debug('### debug1: ' + e.getMessage());
            Utilities.sendDebugEmail('Error in LeadRegistration_Handler:  ', e, e.getMessage());
        }
        
    }

    public static void isBeforeUpdate(List<Deal_Registration__c> newLeadRegs, Map<Id, Deal_Registration__c> oldLeadRegs){
        updateTimestamps(newLeadRegs, oldLeadRegs);
    }

    public static void createdRelatedDealRegRecords(List<Deal_Registration__c> newLeadRegs){
        List<Account> newAccount = new List<Account>();
        List<Lead> newLead = new List<Lead>();
        Boolean isApproved = false;
        Boolean updateAccount = false;
        Account relatedAcc = new Account();
        Id localNotEmpty;

        for(Deal_Registration__c lReg : newLeadRegs){
            if(lReg.Local_Company__c != null){
                localNotEmpty = lReg.Local_Company__c;
            }
        }

        if(localNotEmpty != null){
            relatedAcc = [SELECT Id, Deal_Registration__c, Name FROM Account WHERE Id =: localNotEmpty LIMIT 1];
        }

        for(Deal_Registration__c lReg : newLeadRegs){
            if(lReg.Local_Company__c != null){
                newAccount = updateLocalCompany(relatedAcc, lReg);
                updateAccount = true;
            }

            else{
                newAccount = createLocalCompany(lReg);
                updateAccount = false;
            }
        }
        
        if(newAccount != null && updateAccount == true){
            Database.update(newAccount);
            localAccountForLead = [SELECT Id, Company__c, Name FROM Account WHERE Id IN: newAccount LIMIT 1];
        }

        else if(newAccount != null && updateAccount == false){
            Database.insert(newAccount);
            localAccountForLead = [SELECT Id, Company__c, Name FROM Account WHERE Id IN: newAccount LIMIT 1];
        }

        for(Deal_Registration__c lRegRec : newLeadRegs){
            Lead l = createdLead(lRegRec, localAccountForLead);
            newLead.add(l);
        }

        if(newLead != null){
            try {
                Database.insert(newLead);
            }
            catch (Exception e) {
                Utilities.sendDebugEmail('Error in LeadRegistration_Handler:  ', e, e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
            if(!Test.isRunningTest()){
               System.enqueueJob(new convertRelatedLead(newLead[0], newLeadRegs[0], newAccount[0])); 
            }
            
        }
    }

    public static void isAfter(List<Deal_Registration__c> newLeadRegs, Map<Id, Deal_Registration__c> oldLeadRegs){
        Boolean isApproved = false;
        List<Contact> existingConUpdate = [SELECT Id, Email FROM Contact WHERE Email =: newLeadRegs[0].Registered_Email__c];
        if(oldLeadRegs == null || oldLeadRegs != null){
            for(Deal_Registration__c lReg : newLeadRegs){
                if(lReg.Status__c == 'Approved' && (oldLeadRegs == null || (oldLeadRegs != null && lReg.Status__c != oldLeadRegs.get(lReg.Id).Status__c))){
                    if(lReg.Related_Contact__c == null){
                        isApproved = true;
                    }
    
                    else if(lReg.Related_Contact__c != null || (existingConUpdate != null && !existingConUpdate.isEmpty() && existingConUpdate.size() > 0)){
                        lReg.addError('You cannot Approve this Deal due to an already existing Contact. Please refer to your System Administrator.');
                        return;
                    }
                }
            }

            if(isApproved == true){
                createdRelatedDealRegRecords(newLeadRegs);
            }
        }
    }

    public static List<Account> updateLocalCompany(Account relatedAcc, Deal_Registration__c lReg){
        List<Account> newAcc = new List<Account>();
        relatedAcc.Deal_Registration__c = lReg.Id;
        newAcc.add(relatedAcc);
        return newAcc;
    }

    public static List<Account> createLocalCompany(Deal_Registration__c lReg){//
        List<Account> newAcc = new List<Account>();
        Account acc = new Account();
        acc.Name = lReg.Company_Name__c;
        acc.Deal_Registration__c = lReg.Id;
        acc.RecordTypeId = companyRecordTypeId; //Company RT
        acc.BillingCountry = lReg.Company_Location__c;
        acc.Account_Territory__c = 'Local';
        acc.OwnerId = lReg.OwnerId;
        newAcc.add(acc);

        return newAcc;
    }

    public static Lead createdLead(Deal_Registration__c lRegRec, Account localAccName){
        Lead l = new Lead();
        l.LastName = lRegRec.Last_Name__c;
        l.FirstName = lRegRec.First_Name__c;
        l.Deal_Registration__c = lRegRec.Id;
        l.Company = localAccName.Name;
        l.Company_Size__c = lRegRec.Company_Size__c;
        l.Email = lRegRec.Registered_Email__c;
        l.LeadSource = lRegRec.Source__c;
        l.Lead_Source_Type__c = 'Outbound';
        l.RecordTypeId = leadPartnerRecordTypeId; // create partner lead
        l.Parent_Company__c = localAccName.Id; //local
        l.Related_Company__c = localAccName.Company__c; //global
        l.Title = lRegRec.Title__c;
        l.Country = lRegRec.Company_Location__c;
        l.Use_Cases__c = lRegRec.Use_Cases__c;
        l.Status = 'Received';

        return l;
    }

    public static void updateTimestamps(List<Deal_Registration__c> newLeadRegs, Map<Id, Deal_Registration__c> oldLeadRegs){
        List<Deal_Registration__c> leadRegToUpdate = new List<Deal_Registration__c>();

        for(Deal_Registration__c lReg : newLeadRegs){
            if(lReg.Status__c != oldLeadRegs.get(lReg.Id).Status__c && lReg.Status__c == 'Approved' && oldLeadRegs.get(lReg.Id).Status__c == 'Pending Review'){
                lReg.Timestamp_Manually_Approved__c = System.Today();
                lReg.Approved_By__c = UserInfo.getUserId();
            }
        }
    }

    public class convertRelatedLead implements Queueable{
        private Lead newLead;
        private Deal_Registration__c dealRegRecord;
        private Account newAccount;
         
        public convertRelatedLead(Lead newLead, Deal_Registration__c dealRegRecord, Account newAccount) {
            Account_Rollup.collisionState = true;
            this.newLead = newLead;
            this.dealRegRecord = dealRegRecord;
            this.newAccount = newAccount;
        }

        public void execute(QueueableContext ctx) {
            try{
                Account_Rollup.collisionState = true;
                List<Lead> leads = [SELECT Id FROM Lead WHERE Id =: newLead.Id];
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                Database.LeadConvert tempLC = new Database.LeadConvert();
                tempLC.setLeadId(leads[0].Id);
                tempLC.setConvertedStatus(convertStatus.MasterLabel);
                //tempLC.setOpportunityName(newAccount.Name + ' - ' + dealRegRecord.Expected_Tier__c + ' - ' + dealRegRecord.Expected_Plan_Seats__c + ' - New Business');
                Database.LeadConvertResult lc = Database.convertLead(tempLC);
                maAccountIdFromConvert = lc.getAccountId();
                opportunityIdFromConvert = lc.getOpportunityId();
                if(!Test.isRunningTest()){
                    System.enqueueJob(new updateOpportunityMappingConvert(newLead, dealRegRecord, opportunityIdFromConvert, maAccountIdFromConvert, newAccount));
                }
            }
            
            catch(Exception e){
                system.debug('### lead convert catch: ' + e.getMessage());
                Utilities.sendDebugEmail('Error in LeadRegistration_Handler:  ', e, e.getMessage());
            }
        }
    }

    public class updateOpportunityMappingConvert implements Queueable{
        private Lead newLead;
        private Deal_Registration__c dealRegRecord;
        private Id opportunityIdFromConvert;
        private Id maAccountIdFromConvert;
        private Account newAccount;
         
        public updateOpportunityMappingConvert(Lead newLead, Deal_Registration__c dealRegRecord, Id opportunityIdFromConvert, Id maAccountIdFromConvert, Account newAccount) {
            Account_Rollup.collisionState = true;
            this.newLead = newLead;
            this.dealRegRecord = dealRegRecord;
            this.opportunityIdFromConvert = opportunityIdFromConvert;
            this.maAccountIdFromConvert = maAccountIdFromConvert;
            this.newAccount = newAccount;
        }

        public void execute(QueueableContext ctx) {
            Account_Rollup.collisionState = true;
            List<Opportunity> opportunityToUpdate = new List<Opportunity>();
            Opportunity convertedOpp = [SELECT Id, Name, CloseDate, Type, StageName, RecordTypeId, Use_Cases_PL__c, DepartmentFunction__c, OwnerId, Deal_Registration__c, Competition_They_re_Evaluating__c, Current_Tool__c, Timeline__c, Pains_PL__c, Main_Point_of_Contacts__c, Company__c, Monday_Account__c, LeadSource, pulse_account_ids__c, Partner_Marketing_Activity__c
                                        FROM Opportunity WHERE Id =: OpportunityIdFromConvert][0];
                convertedOpp.Name = newLead.Company + ' - ' + dealRegRecord.Expected_Tier__c + ' - ' + dealRegRecord.Expected_Plan_Seats__c + ' - New Business';
                convertedOpp.CloseDate = dealRegRecord.Expected_Closed_Date__c;
                convertedOpp.Type = 'New Business';
                convertedOpp.StageName = 'Qualified';
                convertedOpp.RecordTypeId = opportunityPartnerRecordTypeId;
                convertedOpp.Use_Cases_PL__c = dealRegRecord.Use_Cases__c;
                convertedOpp.DepartmentFunction__c = dealRegRecord.Department__c;
                convertedOpp.OwnerId = dealRegRecord.OwnerId;
                convertedOpp.Deal_Registration__c = dealRegRecord.Id;
                convertedOpp.Competition_They_re_Evaluating__c = dealRegRecord.Competition_They_re_Evaluating__c;
                convertedOpp.Other_tools_they_re_using__c = dealRegRecord.Tools_in_their_Ecosystem__c;
                convertedOpp.Current_Tool__c = dealRegRecord.Current_Tool__c;
                convertedOpp.Timeline__c = dealRegRecord.Timeline_Why__c;
                convertedOpp.Pains_PL__c = dealRegRecord.Pains__c;
                convertedOpp.Main_Point_of_Contacts__c = dealRegRecord.Champion_Title__c;
                convertedOpp.Company__c = newLead.Related_Company__c;
                convertedOpp.Monday_Account__c = newLead.ConvertedAccountId;
                convertedOpp.LeadSource = dealRegRecord.Source__c;
                convertedOpp.pulse_account_ids__c = newLead.primary_pulse_account_id__c;
                convertedOpp.Expected_Plan_Seats__c = dealRegRecord.Expected_Plan_Seats__c;
                convertedOpp.Expected_Plan_Tier__c = dealRegRecord.Expected_Tier__c;
                convertedOpp.Expected_Plan_Period__c = 'Yearly';
                convertedOpp.Partner_Marketing_Activity__c = dealRegRecord.Partner_Marketing_Activity__c;
            Database.update(convertedOpp);
            Opportunity oppCheck = [SELECT Id, Owner.Function__c, Owner.Office__c, Account_Source_Type__c FROM Opportunity WHERE Id=:convertedOpp.Id][0];
            system.debug('### oppCheck: ' + oppCheck);
            Deal_Registration__c dealRegUpdate = [SELECT Id, Related_Opportunity__c FROM Deal_Registration__c WHERE Id =: dealRegRecord.Id][0];
            dealRegUpdate.Related_Opportunity__c = convertedOpp.Id;
            Database.update(dealRegUpdate);
            if(!Test.isRunningTest()){
                System.enqueueJob(new updateAccountMappingConvert(newLead, dealRegRecord, maAccountIdFromConvert, newAccount));
            }
            
        }
    }

    public class updateAccountMappingConvert implements Queueable{
        private Lead newLead;
        private Deal_Registration__c dealRegRecord;
        private Id maAccountIdFromConvert;
        private Account newAccount;
         
        public updateAccountMappingConvert(Lead newLead, Deal_Registration__c dealRegRecord, Id maAccountIdFromConvert, Account newAccount) {
            Account_Rollup.collisionState = true;
            this.newLead = newLead;
            this.dealRegRecord = dealRegRecord;
            this.maAccountIdFromConvert = maAccountIdFromConvert;
            this.newAccount = newAccount;
        }

        public void execute(QueueableContext ctx) {
            Account_Rollup.collisionState = true;
            Account convertedAcc = [SELECT Id, Name, OwnerId, ParentId, Deal_Registration__c FROM Account WHERE Id =: maAccountIdFromConvert][0];
            convertedAcc.ParentId = newLead.Related_Company__c;
            convertedAcc.OwnerId = dealRegRecord.OwnerId;
            convertedAcc.Deal_Registration__c = newLead.Deal_Registration__c;
            Database.update(convertedAcc);
            if(!Test.isRunningTest()){
                System.enqueueJob(new createCompanyHierarchy(dealRegRecord, newAccount, newLead, convertedAcc));
            }
        }
    }

    public class createCompanyHierarchy implements Queueable{
        private Deal_Registration__c dealRegRecord;
        private Account localCompanyRecord;
        private Lead newLead;
        private Account convertedAcc;
        private List<Account> newGlobalCompany = new List<Account>();
        private List<Account> newRegionalCompany = new List<Account>();
        
        public createCompanyHierarchy(Deal_Registration__c dealRegRecord, Account localCompanyRecord, Lead newLead, Account convertedAcc) {
            Account_Rollup.collisionState = true;
            this.dealRegRecord = dealRegRecord;
            this.localCompanyRecord = localCompanyRecord;
            this.newLead = newLead;
            this.convertedAcc = convertedAcc;
        }

        public void execute(QueueableContext ctx) {
            Account_Rollup.collisionState = true;
            if(dealRegRecord.Global_Company__c != null && dealRegRecord.Regional_Company__c != null){
                system.debug('### 1');
                localCompanyRecord.ParentId = dealRegRecord.Regional_Company__c;
                localCompanyRecord.Company__c = dealRegRecord.Global_Company__c;
            }

            else if(dealRegRecord.Global_Company__c != null && dealRegRecord.Regional_Company__c == null){
                newRegionalCompany = createRegionalCompany(dealRegRecord, dealRegRecord.Global_Company__c);
                if(newRegionalCompany != null && newRegionalCompany.size() > 0 && !newRegionalCompany.isEmpty()){
                    Database.insert(newRegionalCompany);
                    system.debug('### newRegionalCompany: ' + newRegionalCompany);
                }
                localCompanyRecord.ParentId = newRegionalCompany[0].Id;
                localCompanyRecord.Company__c = dealRegRecord.Global_Company__c;
            }

            else if(dealRegRecord.Global_Company__c == null && dealRegRecord.Regional_Company__c == null){
                newGlobalCompany = createGlobalCompany(dealRegRecord);
                if(newGlobalCompany != null && newGlobalCompany.size() > 0 && !newGlobalCompany.isEmpty()){
                    Database.insert(newGlobalCompany);
                    system.debug('### newGlobalCompany: ' + newGlobalCompany);
                    newRegionalCompany = createRegionalCompany(dealRegRecord, newGlobalCompany[0].Id);
                    if(newRegionalCompany != null && newRegionalCompany.size() > 0 && !newRegionalCompany.isEmpty()){
                        Database.insert(newRegionalCompany);
                        system.debug('### newRegionalCompany: ' + newRegionalCompany);
                    }
                    localCompanyRecord.ParentId = newRegionalCompany[0].Id;
                    localCompanyRecord.Company__c = newGlobalCompany[0].Id;
                }
            }
            Database.update(localCompanyRecord);
            system.debug('### localCompanyRecord: ' + localCompanyRecord);
            newLead.Related_Company__c = localCompanyRecord.Company__c; //get the global company
            Database.update(newLead);
            system.debug('### newLead: ' + newLead);
            convertedAcc.Company__c = localCompanyRecord.Company__c; //get the global company
            convertedAcc.Prioritized_Account__c = true;
            convertedAcc.Manual_Trigger__c = 'Rollup Company';
            Account_Rollup.collisionState = false;
            Database.update(convertedAcc);
            //Account_Rollup.MA(convertedAcc);
            system.debug('### convertedAcc: ' + convertedAcc);
            List<Account> acc = [SELECT Id, Company__c, Prioritized_Account__c FROM Account WHERE Id =: convertedAcc.Id];
            system.debug('### acc: ' + acc);
        }

        public List<Account> createRegionalCompany(Deal_Registration__c dealRegRecord, Id globalCompanyId){
            system.debug('### createRegionalCompany:');
            List<Account> newAcc = new List<Account>();

            Account acc = new Account();
            acc.Name = dealRegRecord.Company_Name__c + ' - ' + dealRegRecord.Region__c;
            acc.Deal_Registration__c = dealRegRecord.Id;
            acc.RecordTypeId = companyRecordTypeId; //Company RT
            acc.Account_Territory__c = 'Regional';
            acc.ParentId = globalCompanyId;
            acc.Company__c = globalCompanyId;
            acc.Region__c = dealRegRecord.Region__c;
            acc.BillingCountry = dealRegRecord.Company_Location__c;
            acc.OwnerId = dealRegRecord.OwnerId;

            relatedRegionalAccount.add(acc);
            system.debug('### relatedRegionalAccount: ' + relatedRegionalAccount);
            return relatedRegionalAccount;
        }

        public List<Account> createGlobalCompany(Deal_Registration__c dealRegRecord){
            system.debug('### createGlobalCompany:');
            List<Account> newAcc = new List<Account>();

            Account acc = new Account();
            acc.Name = dealRegRecord.Company_Name__c + ' - Global';
            acc.Deal_Registration__c = dealRegRecord.Id;
            acc.RecordTypeId = companyRecordTypeId; //Company RT
            acc.Account_Territory__c = 'Global';
            acc.Website = dealRegRecord.Company_Website__c;
            acc.BillingCountry = dealRegRecord.Company_Location__c;
            acc.OwnerId = dealRegRecord.OwnerId;

            relatedGlobalAccount.add(acc);
            system.debug('### relatedGlobalAccount: ' + relatedGlobalAccount);
            return relatedGlobalAccount;
        }
    }
}