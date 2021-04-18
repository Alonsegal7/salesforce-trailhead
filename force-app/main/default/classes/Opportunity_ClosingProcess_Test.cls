@isTest
public class Opportunity_ClosingProcess_Test {
    
    @isTest static void setup(){
        
    }
    
    @isTest static void getInitialParameters(){
		Account a = TestObjectCreator.CreateCompany();
		insert a;
		System.debug('iCloudius - Parent Account: ' + a.Name);

		Account aa = TestObjectCreator.CreateMondayAccount(a);
		aa.Name = aa.Name + 'tst';
		aa.ParentId = a.Id;
		insert aa;
		System.debug('iCloudius - Child Account: ' + aa.Name);

		Opportunity o = TestObjectCreator.CreateOpp(aa);
        insert o;
        
		Opportunity_ClosingProcess.getInitialParameters(o.Id);
        Opportunity_ClosingProcess.saveInnerPicklistPath(o.Id, 'CC Claim');
    }  
}