public without sharing class CompanyDomain_Service {
    public static void validateFormat(List<Company_Domain__c> newDomains) {
        for (Company_Domain__c domain : newDomains) {
            domain.Domain__c = getCleanDomain(domain.Domain__c); 
        }
    }

    public class FlowInputs {
        @InvocableVariable(label='domain' description='Input Domains' required=true)        
        public string inputDomain;
    }

    @InvocableMethod
    public static list<string> cleanDomain(List<FlowInputs> flowInputs) {
        string domain = flowInputs[0].inputDomain;
        list <string> respone = new list <string>();
        respone.add(getCleanDomain(domain));
        return respone;
    }

    private static String getCleanDomain(String inputDomain) {
        return inputDomain.replaceFirst('^(https?://)?(www\\.)?', '').split('/')[0];
    }
}