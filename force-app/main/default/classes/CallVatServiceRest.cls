@RestResource(urlMapping='/CallVatServiceRestUrl') 
global with sharing class CallVatServiceRest {
    @HttpPost
    global static string CheckVatNumber(String countryName, String vatNumber) {
        string countryISO = countryName;
        string vatNmber = vatNumber;
        return VatVerificationService.CallVatService(countryISO,vatNmber);
    }
}