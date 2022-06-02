public without sharing class PartnerSORequest_Service {
        public class FlowInputs {
            @InvocableVariable(label='CompanyId' description='Input Company Id' required=true)        
            public Id companyId;
        }
    
        @InvocableMethod
        public static List<List<Billing_Entity__c>> GetBillingEntities(List<FlowInputs> flowInputs) {
            Id comapnyId = flowInputs[0].companyId;
            List<Company_Billing__c> relevantCompanyBillings = new List<Company_Billing__c>([SELECT id, Billing_Entity__c FROM Company_Billing__c WHERE Company__c = :comapnyId AND Billing_Entity__r.Status__c = 'active']);
            Set<Id> billingEntitiesIds = new Set<Id>();
            for (Company_Billing__c cb : relevantCompanyBillings) {
                billingEntitiesIds.add(cb.Billing_Entity__c);   
            }

            List<Billing_Entity__c> relevantBillingEntities = new List<Billing_Entity__c> ([SELECT id, Name, Billing_Address__c, Shipping_Address__c FROM Billing_Entity__c WHERE id IN: billingEntitiesIds LIMIT 200]);
            List<List<Billing_Entity__c>> wrapper = new List<List<Billing_Entity__c>> ();
            wrapper.add(relevantBillingEntities);
            return wrapper;
        }
}
