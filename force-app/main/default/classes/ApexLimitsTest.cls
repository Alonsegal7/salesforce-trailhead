@istest
public with sharing class ApexLimitsTest {
    @istest
    public static void ApexLimitsTestFunction() {
        Map<String, Integer> tstMap = new Map<String, Integer>();
        tstMap = ApexLimits.getLimits('DailyApiRequests');
    }
}