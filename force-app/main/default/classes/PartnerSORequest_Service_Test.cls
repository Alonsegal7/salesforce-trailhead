@istest
private class PartnerSORequest_Service_Test {
    @istest
    private static void shouldGetBillingEntity() {
        Account company = TestObjectCreator.CreateCompany();
		insert company;
        Billing_Entity__c be = TestObjectCreator.CreateBE();
		insert be;
        Company_Billing__c cb = TestObjectCreator.CreateCompanyBilling(company, be);
		insert cb;

        PartnerSORequest_Service.FlowInputs input = new PartnerSORequest_Service.FlowInputs();
        input.companyId=company.Id;

        List<List<Billing_Entity__c>> results = PartnerSORequest_Service.GetBillingEntities(new List<PartnerSORequest_Service.FlowInputs>{input});
        system.assertEquals(be.id, results[0][0].id);
    }
}
