@isTest
public class Opportunity_ClosingProcess_Test {
    
    @isTest static void getInitialParameters(){
		Account a = TestObjectCreator.CreateCompany();
		//a.NumberOfEmployees = 200;
		insert a;

		Account aa = TestObjectCreator.CreateMondayAccount(a);
		aa.Name = aa.Name + 'tst';
		aa.ParentId = a.Id;
		insert aa;

		Opportunity o = TestObjectCreator.CreateOpp(aa);
		o.Company__c = a.Id;
        insert o;
		o.company_size__c = 100;
		update o;

		user u = [select id from user where isActive = true and group__c = 'Sales' and Profile.Name = 'monday Sales - AE' limit 1];
		Co_Sell_Request__c csr = new Co_Sell_Request__c(
            Main_Opportunity__c = o.Id,
            Secondary_Opportunity_Owner__c = u.Id,
            Type__c = 'Create',
            Monday_Account__c = aa.Id
        );
		insert csr;
        
		Opportunity_ClosingProcess.getInitialParameters(o.Id);
		Opportunity_ClosingProcess.closedStageSelected(o.Id);
		Opportunity_ClosingProcess.updateCompSize_account(o.Id);
		Opportunity_ClosingProcess.saveInnerPicklistPath(o.Id, 'CC Claim');
		Opportunity_ClosingProcess.getFieldsFromFieldSet('Opportunity', 'InternalOpportunity_Won_Expansion');
		Opportunity_ClosingProcess.closeOpp(o.Id, 'Closed Won');
		Opportunity_ClosingProcess.handover_updateCompSizeRecalcTH(o.Id);
		Opportunity_ClosingProcess.checkCosellImpactSurveyFilled(csr.Id);
    }  
}