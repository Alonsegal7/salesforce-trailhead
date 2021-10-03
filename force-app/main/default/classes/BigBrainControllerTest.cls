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
        BigBrainController.getAddedArr('test', 1, 1, 1, 1, 1);
    }
}