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

		Ctrl_BillingEntityRelate.getInitialParameters(o.Id);
		Ctrl_BillingEntityRelate.testUniquness(be.VAT_Number__c, '', '', '', '');
		Ctrl_BillingEntityRelate.doRelate(o.Id, be.Id);
	}
}