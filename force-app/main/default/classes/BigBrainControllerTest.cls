@isTest
public class BigBrainControllerTest {
    @isTest
    static void TestEndpoints(){
        BigBrainController.getAccountProfile('test');
        BigBrainController.getAccountUsers('test');
        BigBrainController.getAccountFeaturesUsage('test');
        BigBrainController.getAllOpportunityBillings('test', 'test');
        BigBrainController.getPlans('test');
        BigBrainController.getForecastDetails('test');
        BigBrainController.getActionsDetails('test');
        BigBrainController.grantAccountFeatures('test', new List<String>());
        BigBrainController.ungrantAccountFeatures('test', new List<String>());
        BigBrainController.setAccountFreeUsers('test', 1, 'test');
        BigBrainController.resetAccountTrial('test');
        BigBrainController.setPricingVersion('test', 'test');
    }

    @isTest
    static void TestPullSignups(){
        Test.setMock(HttpCalloutMock.class, new BigBrain_LeadPoolServiceTest.mockPullSignups());
        Test.startTest();
        BigBrainAPI.pullSignups(Datetime.now().addMinutes(-15), Datetime.now().addMinutes(-1));
        Test.stopTest();
    }

    @isTest
    static void TestRefreshSignups(){
        Test.setMock(HttpCalloutMock.class, new BigBrain_LeadPoolServiceTest.mockRefreshSignups());
        Test.startTest();
        BigBrainAPI.refreshSignups(new list<string>{'12345'}, false);
        Test.stopTest();
    }
}