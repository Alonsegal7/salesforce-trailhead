@RestResource(urlMapping='/CallVatServiceRestUrl') 
global with sharing class CallVatServiceRest {
    @HttpPost
    global static string CheckVatNumber(String countryName, String vatNumber,String canadaVatTypes) {
        string countryISO = countryName;
        string vatNmber = vatNumber;
        string caVatTypes = canadaVatTypes;
        return VatVerificationService.CallVatService(countryISO,vatNmber,caVatTypes);
    }
}