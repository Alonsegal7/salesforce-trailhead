public with sharing class VatVerificationService {

    public static string CallVatService(String countryName, String vatNumber, string canadaVatType){
        List<Country_Region_Mapping__c> countryCode = [SELECT Name, Country_Name__c, Region__c, Sub_Region__c FROM Country_Region_Mapping__c WHERE Vat_Number_Verification_Required__c = true AND Country_Name__c =: countryName];
        //Country code that are marked on the custom setting as required
        if (!countryCode.isempty() && vatNumber != null && vatNumber != '') {
            if(countryCode[0].Name=='CL'){//for chile, we need to set a dash before the 9th digit
                vatNumber = vatNumber.replaceAll('[^a-zA-Z0-9]', '');
                vatNumber = vatNumber.right(8) + '-' + vatNumber.left(1);
            }
            else{
                vatNumber = vatNumber.replaceAll('[^a-zA-Z0-9]', '');
            }
            Map<String, Object> responseMap = new Map<String, Object>();
            Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='BillingEntityVatService'][0];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string url = ConfigManager.getBillingVatServiceUrl();
            String authenticationToken = whMTD.Key__c;
            String endpoint = url+'/billing-subscriptions/sales-managed/salesforce/taxes/validate-vat-number/?vatNumberType='+GetVatNumberType(countryName,canadaVatType)+'&country='+countryCode[0].Name+'&vatNumber='+vatNumber+'&token='+authenticationToken;
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
            
            ResponseWrapper resWrapper = ResponseWrapper.parse(resBody);//create object to handle response
            return HandleResponse(resWrapper);
        }

        //Start Tal - VAT Logic
        else if(!countryCode.isEmpty() && (vatNumber == null || vatNumber == '')){
            return '{"status":"invalid"}';
        }
        //End Tal - VAT Logic

        //The country wasn't defined as required on Country_Region_Mapping__c
        else {
            return '{"status":"irrelevant"}';
        }
    }

    public static string GetVatNumberType(string country,string canadaVatType){
        System.debug('canadaVatType' + canadaVatType);
        if (canadaVatType!=null) {
            if (canadaVatType=='QST') {
                return 'ca_qst';
            }
            if (canadaVatType=='GST') {
                return 'ca_gst_hst';
            }
        }
        else {
            switch on country {
                when 'Canada' {//this will be till we will support gst/qst
                    return 'ca_gst_hst';
                }
                when 'Australia' {
                    return 'au_abn';
                }
                when 'Chile' {
                    return 'cl_tin';
                }
                when 'India' {
                    return 'in_gst';
                }
                when 'Israel' {
                    return 'il_vat';
                }
                when 'New Zealand' {
                    return 'nz_gst';
                }
                when 'Norway' {
                    return 'no_vat';
                }
                when 'Russia' {
                    return 'ru_inn';
                }
                when 'Saudi Arabia' {
                    return 'sa_vat';
                }
                when 'Singapore' {
                    return 'sg_gst';
                }
                when 'South Africa' {
                    return 'za_vat';
                }
                when 'South Korea' {
                    return 'kr_brn';
                }
                when 'Switzerland' {
                    return 'ch_vat';
                }
                when 'United Arab Emirates' {
                    return 'ae_trn';
                }
                when 'United Kingdom' {
                    return 'gb_vat';
                }
                when else{
                    return 'eu_vat'; //else is EU
                }
            }
        }
        
        return country=='Australia'?'au_abn':'eu_vat';
    }


    public class FlowInputs {
        @InvocableVariable(label='countryName' description='Country Code' required=true)        
        public string countryName;

        @InvocableVariable(label='vatNumber' description='Vat number' required=true)        
        public string vatNumber;

        @InvocableVariable(label='canadaVatType' description='Canada Vat Types' required=false)        
        public string canadaVatType;

    }


    @InvocableMethod
    public static list<string> callVatServiceFromFlow(List<FlowInputs> flowInputs) {
        string countryName = flowInputs[0].countryName;
        string vatNumber = flowInputs[0].vatNumber;
        string canadaVatType = flowInputs[0].canadaVatType;

        list <string> respone = new list <string>();
        respone.add(CallVatService(countryName,vatNumber,canadaVatType));
        return respone;
    }

    public class ResponseWrapper {
        public String status {get;set;}
        public String reason {get;set;}
        public string reasonDescription {get;set;}
    }

    public static ResponseWrapper parse(String json) {
        return (ResponseWrapper) System.JSON.deserialize(json, ResponseWrapper.class);
    }

    public static string HandleResponse(ResponseWrapper wrapper){
        string res;
        if (wrapper.reason=='invalid_format') {
            wrapper.reasonDescription='Invalid format';
        }
        if (wrapper.reason=='invalid_country') {
            wrapper.reasonDescription='Invalid country';
        }
        if (wrapper.reason=='business_is_not_vat_registered') {
            wrapper.reasonDescription='The business is not vat registered';
        }
        if (wrapper.reason=='business_is_not_active') {
            wrapper.reasonDescription='The business does not exist';
        }
        if (wrapper.reason=='service_unavailable') {
            wrapper.reasonDescription='Validation service is unavailable';
        }
        res=JSON.serialize(wrapper);
        return res;
    }
}