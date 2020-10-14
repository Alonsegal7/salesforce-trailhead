@isTest
public class CalloutTest {
	static testMethod void callUpdate() {
        // this is dummy test for now
        Test.startTest();
        Account acc = new Account(Name='kuku');
        List<Account> accounts = new List<Account>();
        accounts.add(acc);
        Callout.callUpdate(accounts);
		Test.stopTest();
    }
    
    static testMethod void callDelete() {
        // this is dummy test for now
        Test.startTest();
        Account acc = new Account(Name='kuku');
        List<Account> accounts = new List<Account>();
        accounts.add(acc);
        Callout.callDelete(accounts);
		Test.stopTest();
    }
}