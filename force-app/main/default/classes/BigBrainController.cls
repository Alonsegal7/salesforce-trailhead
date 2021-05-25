public with sharing class BigBrainController {
    @AuraEnabled(cacheable=false)
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

    @AuraEnabled(cacheable=false)
    public static string setAccountFreeUsers(String pulseAccountId, Integer freeUsers, String untilDate){
        try {
            return BigBrainAPI.setAccountFreeUsers(pulseAccountId, freeUsers, untilDate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
}
