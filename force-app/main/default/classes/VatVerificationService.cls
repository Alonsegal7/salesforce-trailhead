public with sharing class VatVerificationService {

    public static string CallVatService(String countryName, String vatNumber){
        //Start Tal - VAT Logic
        String isInvalid = 'invalid';
        //End Tal - VAT Logic
        String isIrrelevant='irrelevant';
        List<Country_Region_Mapping__c> countryCode = [SELECT Name, Country_Name__c, Region__c, Sub_Region__c FROM Country_Region_Mapping__c WHERE Vat_Number_Verification_Required__c = true AND Country_Name__c =: countryName];
        //Country code that are marked on the custom setting as required
        if (!countryCode.isempty() && vatNumber != null && vatNumber != '') {
            vatNumber = vatNumber.replaceAll('[^a-zA-Z0-9]', '');
            Map<String, Object> responseMap = new Map<String, Object>();
            Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='BillingEntityVatService'][0];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string url = ConfigManager.getBillingVatServiceUrl();
            String authenticationToken = whMTD.Key__c;
            String endpoint = url+'/billing-subscriptions/sales-managed/salesforce/taxes/validate-vat-number/?vatNumberType='+GetVatNumberType(countryName,null)+'&country='+countryCode[0].Name+'&vatNumber='+vatNumber+'&token='+authenticationToken;
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            HttpResponse response=null;
            String resBody='';
            
            if (!Test.isRunningTest()){
                response = http.send(request);
                resBody=response.getBody();
                system.debug('result'+resBody);
                }
            else {
                    resBody = '{"status":"valid"}';
                }

            responseMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
            return string.valueof(responseMap.get('status'));
        }

        //Start Tal - VAT Logic
        else if(!countryCode.isEmpty() && (vatNumber == null || vatNumber == '')){
            return isInvalid;
        }
        //End Tal - VAT Logic

        //The country wasn't defined as required on Country_Region_Mapping__c
        else {
            return isIrrelevant;    
        }
    }

    public static string GetVatNumberType(string country, string state){
        return country=='Australia'?'au_abn':'eu_vat';
    }


    public class FlowInputs {
        @InvocableVariable(label='countryName' description='Country Code' required=true)        
        public string countryName;

        @InvocableVariable(label='vatNumber' description='Vat number' required=true)        
        public string vatNumber;
    }


    @InvocableMethod
    public static list<string> callVatServiceFromFlow(List<FlowInputs> flowInputs) {
        string countryName = flowInputs[0].countryName;
        string vatNumber = flowInputs[0].vatNumber;

        list <string> respone = new list <string>();
        respone.add(CallVatService(countryName,vatNumber));
        return respone;
    }
}