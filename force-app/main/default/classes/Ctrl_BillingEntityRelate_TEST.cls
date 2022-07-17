@isTest 
private class Ctrl_BillingEntityRelate_TEST {
	@isTest
	private static void test1() {
		Billing_Entity__c be = TestObjectCreator.CreateBE();
		insert be;
		
		Account a = TestObjectCreator.CreateCompany();
		insert a;
		System.debug('iCloudius - Parent Account: ' + a.Name);

		Account aa = TestObjectCreator.CreateMondayAccount(a);
		aa.Latest_Billing_Entity__c = be.Id;
		aa.Name = aa.Name + 'tst';
		aa.ParentId = a.Id;
		insert aa;
		System.debug('iCloudius - Child Account: ' + aa.Name);

		Opportunity o = TestObjectCreator.CreateOpp(aa);
		insert o;

		Company_Billing__c cb = TestObjectCreator.CreateCompanyBilling(aa, be);
		insert cb;

		Country_Region_Mapping__c rgn = new Country_Region_Mapping__c();
		rgn.Country_Name__c = 'Luxembourg';
		rgn.Name = 'LU';
		insert rgn;

		Ctrl_BillingEntityRelate.fieldValidations(be);
		Ctrl_BillingEntityRelate.getInitialParameters(o.Id);
		Ctrl_BillingEntityRelate.testUniquness(be.VAT_Number__c, '', '', '', '');
		Ctrl_BillingEntityRelate.doRelate(o.Id, be.Id);
		Test.isRunningTest();
		Ctrl_BillingEntityRelate.CallVatService('Luxembourg','LU26375245', null, null);

		Ctrl_BillingEntityRelate.getValuesCallVatService(be.Id);
		Ctrl_BillingEntityRelate.updateBillingEntityFields(be.Id, 'Yes', 'LU26375245', 'irrelevant'); //scenario #1 - VAT is required
		Ctrl_BillingEntityRelate.updateBillingEntityFields(be.Id, 'No', 'LU26375245', 'unknown'); // scenario #2 - VAT is not required
		Ctrl_BillingEntityRelate.isVATrequiresChecking();
		Ctrl_BillingEntityRelate.getBE(be.Id);

	}
}