public without sharing class ServiceOpportunityCreation {
        @AuraEnabled
        public static List<Opportunity> createServiceOpportunities(List<Id> accountsforserviceIds){
    
            Id serviceOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Service_Opportunity').getRecordTypeId();
            //String pricingVersion, paymentTerms, paymentMethod = '';
 
            List<Account> relevantAccounts=  new List<Account>([
                SELECT Id, Name, Active_Contract__c, Company__c, Pricing_Version__c, ParentId,CurrencyIsoCode,primary_pulse_account_id__c
                FROM Account 
                WHERE Id IN: accountsforserviceIds 
                ORDER BY ARR__c 
                DESC]
            );
    
            List<Opportunity> serviceOppsToCreate = new List<Opportunity>();
            if(relevantAccounts.isEmpty()) return null;
            
            Map<Id,Account> accountsWithIds = new Map<Id,Account>();
            for (Account a : relevantAccounts) {
                serviceOppsToCreate.add(new Opportunity(
                    Name = a.Name + ' - ' + ' Service Opportnity' ,
                    Company__c = a.Company__c,
                    AccountId = a.Id,
                    CloseDate = system.today(),
                    Selected_Company_Contract__c = a.active_contract__c,
                    RecordTypeId = serviceOppRtId,
                    StageName = 'Qualified',
                    Probability = 20,
                    Parent_Company__c=a.ParentId,
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

