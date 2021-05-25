public with sharing class BigBrainController {
    @AuraEnabled(cacheable=true)
    public static string getAccountProfile(){
        try {
            return BigBrainAPI.getAccountProfile('841481');
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

    @AuraEnabled(cacheable=false)
    public static string setAccountFreeUsers(String pulseAccountId, Integer freeUsers, String untilDate){
        try {
            return BigBrainAPI.setAccountFreeUsers(pulseAccountId, freeUsers, untilDate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }
}
