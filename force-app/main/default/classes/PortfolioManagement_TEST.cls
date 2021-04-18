@isTest 
private class PortfolioManagement_TEST {

	@isTest
	private static void testName() {
		
		List <RecordType> lrt = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Partner_Company'];

		Globals.CodeOff = true;
		Account a = TestObjectCreator.CreateAccount();
		insert a;

		Account aa = TestObjectCreator.CreateAccount();
		aa.RecordTypeId = lrt[0].Id;
		insert aa;

		Contact c = TestObjectCreator.CreateContact(aa);
		insert c;

		User u = TestObjectCreator.CreateUser();
		u.ProfileId = '00e1t000000e3IT';
		u.ContactId = c.Id;
		u.ManagerId = UserInfo.getUserId();
		insert u;

		Globals.CodeOff = true;
		List <Opportunity> lo = new List <Opportunity>();
		Opportunity o = TestObjectCreator.CreateOpp(a);
		lo.add(o);
		o = TestObjectCreator.CreateOpp(a);
		o.Name = o.Name + '_1';
		o.StageName = 'Closed Won';
		lo.add(o);
		o = TestObjectCreator.CreateOpp(a);
		o.Name = o.Name + '_2';
		o.StageName = 'Closed Lost';
		lo.add(o);
		o = TestObjectCreator.CreateOpp(a);
		o.Name = o.Name + '_3';
		o.StageName = 'Closed Lost';
		o.Type = 'Renewal';
		lo.add(o);
		o = TestObjectCreator.CreateOpp(a);
		o.Name = o.Name + '_4';
		o.StageName = 'Closed Lost';
		o.Type = 'Expansion';
		lo.add(o);
		o = TestObjectCreator.CreateOpp(a);
		o.Name = o.Name + '_5';
		o.StageName = 'Closed Lost';
		o.Type = 'New Business';
		lo.add(o);

		Date d = Date.today();


		o = TestObjectCreator.CreateOpp(aa);
		o.OwnerId = u.Id;
		o.Name = o.Name + '_6';
		o.Is_Potential_GB_Opportunity__c = true;
		o.Potential_GB_Opp_Override__c = 'Yes';
		o.CloseDate = d.addDays(-1);
		lo.add(o);
		o = TestObjectCreator.CreateOpp(aa);
		o.OwnerId = u.Id;
		o.Name = o.Name + '_7';
		o.Is_Potential_GB_Opportunity__c = true;
		o.Potential_GB_Opp_Override__c = 'Yes';
		o.CloseDate = d.addDays(-10);
		lo.add(o);
		o = TestObjectCreator.CreateOpp(aa);
		o.OwnerId = u.Id;
		o.Name = o.Name + '_8';
		o.Is_Potential_GB_Opportunity__c = false;
		o.Potential_GB_Opp_Override__c = 'No';
		o.CloseDate = d.addDays(-1);
		lo.add(o);
		o = TestObjectCreator.CreateOpp(aa);
		o.OwnerId = u.Id;
		o.Name = o.Name + '_9';
		o.Is_Potential_GB_Opportunity__c = false;
		o.Potential_GB_Opp_Override__c = 'No';
		o.CloseDate = d.addDays(-10);
		lo.add(o);
		o = TestObjectCreator.CreateOpp(aa);
		o.OwnerId = u.Id;
		o.Name = o.Name + '_10';
		o.Is_Potential_GB_Opportunity__c = true;
		o.Potential_GB_Opp_Override__c = 'Yes';
		o.CloseDate = d.addDays(-1);
		lo.add(o);
		o = TestObjectCreator.CreateOpp(aa);
		o.OwnerId = u.Id;
		o.Name = o.Name + '_11';
		o.Is_Potential_GB_Opportunity__c = true;
		o.Potential_GB_Opp_Override__c = 'Yes';
		o.CloseDate = d.addDays(-40);
		lo.add(o);
		o = TestObjectCreator.CreateOpp(aa);
		o.OwnerId = u.Id;
		o.Name = o.Name + '_12';
		o.Is_Potential_GB_Opportunity__c = false;
		o.Potential_GB_Opp_Override__c = 'No';
		o.CloseDate = d.addDays(-1);
		lo.add(o);
		o = TestObjectCreator.CreateOpp(aa);
		o.OwnerId = u.Id;
		o.Name = o.Name + '_13';
		o.Is_Potential_GB_Opportunity__c = false;
		o.Potential_GB_Opp_Override__c = 'No';
		o.CloseDate = d.addDays(-40);
		lo.add(o);

		insert lo;
		
		Set <Id> setId = new Set <Id> (new List <Id> { a.Id, aa.Id });

		PortfolioManagement_SCHEDULE cdl = new PortfolioManagement_SCHEDULE();
		System.schedule('Test Sched', PortfolioManagement_SCHEDULE.CRON_EXP, cdl);

		PortfolioManagement_BATCH theBatch = new PortfolioManagement_BATCH();
		theBatch = new PortfolioManagement_BATCH(setId);
		Database.executeBatch(theBatch);

		Globals.CodeOff = false;
		a.Account_Domains__c = 'cnn.com';
		update a;

	}
}