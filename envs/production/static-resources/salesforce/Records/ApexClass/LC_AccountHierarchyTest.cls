@isTest
public class LC_AccountHierarchyTest {

    @isTest
    public static void test() {
        Account a = new Account(Name = 'testApexAcc');
        insert a;
        LC_BaseController.execute('LC_AccountHierarchy', new Map<String, Object>{'actionName' => 'getHierarchy', 'recordId' => a.Id});
        LC_BaseController.execute('absdf', new Map<String, Object>{'actionName' => 'getHierarchy', 'recordId' => a.Id});
    }
}