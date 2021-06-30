public with sharing class BigBrainController {
    @AuraEnabled(cacheable=true)
    public static string getAccountProfile(String pulseAccountId){
        try {
            return BigBrainAPI.getAccountProfile(pulseAccountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getAccountUsers(String pulseAccountId){
        try {
            return BigBrainAPI.getAccountUsers(pulseAccountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getAccountBilling(String pulseAccountId){
        try {
            return BigBrainAPI.getAccountBilling(pulseAccountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getAccountFeaturesUsage(String pulseAccountId){
        try {
            return BigBrainAPI.getAccountFeaturesUsage(pulseAccountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getAllOpportunityBillings(String pulseAccountId, String opportunityId){
        try {
            return BigBrainAPI.getAllOpportunityBillings(pulseAccountId, opportunityId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getPlans(String pricingVersion){
        try {
            return BigBrainAPI.getPlans(pricingVersion);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string getForecastDetails(String pulseAccountId){
        try {
            return BigBrainAPI.getForecastDetails(pulseAccountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getAccountGrantedFeatures(String pulseAccountId){
        try {
            string allFeatures = BigBrainAPI.getAllGrantedFeatures(pulseAccountId);
            string usedFeatures = BigBrainAPI.getAccountUsedGrantedFeatures(pulseAccountId);
            string resp = '{ "allFeatures": ' + allFeatures;
            resp += ', "selectedFeatures": ' + usedFeatures + ' }';            
            return resp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String grantAccountFeatures(String pulseAccountId, List<string> features, string due_date){
        try {
            return BigBrainAPI.grantAccountFeatures(pulseAccountId, features, due_date);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String ungrantAccountFeatures(String pulseAccountId, List<string> features){
        try {
            return BigBrainAPI.ungrantAccountFeatures(pulseAccountId, features);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static string setAccountFreeUsers(String pulseAccountId, Integer freeUsers, String untilDate){
        try {
            return BigBrainAPI.setAccountFreeUsers(pulseAccountId, freeUsers, untilDate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    @AuraEnabled(cacheable=false)
    public static string resetAccountTrial(String pulseAccountId){
        try {
            return BigBrainAPI.resetAccountTrial(pulseAccountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
}
