public without sharing class ServiceOpportunityCreation {
        @AuraEnabled
        public static List<Opportunity> createServiceOpportunities(List<Id> accountsIdsForServiceOppCreation){
    
            Id internalOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
            Id partnerOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
            //Id currentUserProfile = userinfo.getProfileId();
            //Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id =: currentUserProfile];
 
            List<Account> accountsForServiceOppCreation=  new List<Account>([
                SELECT Id, Name,Owner_s_Profile__c, Active_Contract__c, Company__c, Pricing_Version__c, ParentId,CurrencyIsoCode,primary_pulse_account_id__c,Latest_Billing_Entity__c
                FROM Account 
                WHERE Id IN: accountsIdsForServiceOppCreation 
                ORDER BY ARR__c 
                DESC]
            );
    
            List<Opportunity> serviceOppsToCreate = new List<Opportunity>();
            if(accountsForServiceOppCreation.isEmpty()) return null;
            
            Map<Id,Account> accountsWithIds = new Map<Id,Account>();
            for (Account a : accountsForServiceOppCreation) {
                Id getRelevantRT = a.Owner_s_Profile__c == 'Partner Community Custom' ? partnerOppRtId : internalOppRtId;
                serviceOppsToCreate.add(new Opportunity(
                    Name = a.Name + ' - ' + ' Service Opportnity' ,
                    Company__c = a.Company__c,
                    AccountId = a.Id,
                    CloseDate = system.today(),
                    Selected_Company_Contract__c = a.active_contract__c,
                    RecordTypeId = internalOppRtId,
                    StageName = 'Qualified',
                    Probability = 20,
                    Type= 'Service',
                    Parent_Company__c=a.ParentId,
                    Billing_Entity__c=a.Latest_Billing_Entity__c,
                    Pricing_Version__c=a.Pricing_Version__c,
                    CurrencyIsoCode = a.CurrencyIsoCode,
                    primary_pulse_account_id__c=a.primary_pulse_account_id__c
                ));          
            }
             
            //create the service opportunities
            try {
                Database.insert(serviceOppsToCreate, false);
            } catch (Exception e) {
                System.debug('Message: ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
    
            return serviceOppsToCreate;
        }
    }