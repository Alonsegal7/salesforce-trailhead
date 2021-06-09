@isTest
public class Opportunity_ClosingProcess_Test {
    
    @isTest static void setup(){
        
    }
    
    @isTest static void getInitialParameters(){
		Account a = TestObjectCreator.CreateCompany();
		insert a;

		Account aa = TestObjectCreator.CreateMondayAccount(a);
		aa.Name = aa.Name + 'tst';
		aa.ParentId = a.Id;
		insert aa;

		Opportunity o = TestObjectCreator.CreateOpp(aa);
        insert o;
        
		Opportunity_ClosingProcess.getInitialParameters(o.Id);
		Opportunity_ClosingProcess.saveInnerPicklistPath(o.Id, 'CC Claim');
		Opportunity_ClosingProcess.updateProbability(o.Id, 'Closed Won');
        Opportunity_ClosingProcess.getFieldsFromFieldSet('Opportunity', 'InternalOpportunity_Won_Expansion');
    }  
}