@istest
public with sharing class VatVerificationServiceTest {
    @istest
    public static void VatVerificationServiceTest() {
        Country_Region_Mapping__c rgn = new Country_Region_Mapping__c();
		rgn.Country_Name__c = 'Luxembourg';
		rgn.Name = 'LU';
		rgn.Vat_Number_Verification_Required__c=true;
        insert rgn;
        

        VatVerificationService.FlowInputs inpts = new VatVerificationService.FlowInputs();
        inpts.countryName='Luxembourg';
        inpts.vatNumber='LU26375245';

        
        Test.startTest();
        VatVerificationService.callVatServiceFromFlow(new List<VatVerificationService.FlowInputs>{inpts});
        Test.stopTest();
    }
}