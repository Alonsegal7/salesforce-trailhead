@isTest
public class BeforeInsertOpportunityTest {
    /*
    static testMethod void fillPulseAccountIdsFromPrimary() {
        Test.startTest();
        Account c = new Account(Name='company 1');
        insert c;
		Opportunity opp = new Opportunity(primary_pulse_account_id__c='123', AccountId=c.Id, Name='test opp', StageName='Closed Lost', CloseDate=System.today(), pulse_account_ids__c=null);
		insert opp;
        Opportunity opp1 = [select Id, pulse_account_ids__c from Opportunity where Id = :opp.Id];
		System.assertEquals(opp1.pulse_account_ids__c, '123');
        Test.stopTest();
    }
   
    static testMethod void fillPrimaryAccountIdFromPastOpportunity() {
        Test.startTest();
        Account c = new Account(Name='company 1');
        insert c;
        Opportunity prevOpp = new Opportunity(primary_pulse_account_id__c='456', AccountId=c.Id, Name='test opp', StageName='Closed Lost', CloseDate=System.today(), pulse_account_ids__c=null);
		insert prevOpp;
        Opportunity opp = new Opportunity(AccountId=c.Id, Name='test opp 2', StageName='Qualified', pulse_account_ids__c=null, CloseDate=System.today());
		insert opp;
        opp = [select Id, pulse_account_ids__c, primary_pulse_account_id__c from Opportunity where Id = :opp.Id];
		System.assertEquals(opp.pulse_account_ids__c, '456');
        System.assertEquals(opp.primary_pulse_account_id__c, '456');
        Test.stopTest();
    }
    
    static testMethod void dontFillPrimaryAccountIdFromPastOpportunity() {
        Test.startTest();
        Account c = new Account(Name='company 1');
        insert c;
        Opportunity prevOpp = new Opportunity(primary_pulse_account_id__c='456', AccountId=c.Id, Name='test opp', StageName='Closed Lost', CloseDate=System.today(), pulse_account_ids__c=null);
		insert prevOpp;
        
        Opportunity prevOpp2 = new Opportunity(primary_pulse_account_id__c='678', AccountId=c.Id, Name='test opp', StageName='Closed Lost', CloseDate=System.today(), pulse_account_ids__c=null);
		insert prevOpp2;
        
        Opportunity opp = new Opportunity(AccountId=c.Id, Name='test opp 2', StageName='Qualified', pulse_account_ids__c=null, CloseDate=System.today());
		insert opp;
        opp = [select Id, pulse_account_ids__c, primary_pulse_account_id__c from Opportunity where Id = :opp.Id];
		System.assertEquals(opp.pulse_account_ids__c, null);
        System.assertEquals(opp.primary_pulse_account_id__c, null);
        Test.stopTest();
    }
 */
}