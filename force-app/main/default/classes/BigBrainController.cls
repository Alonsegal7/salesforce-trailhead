public with sharing class BigBrainController {
    @AuraEnabled(cacheable=true)
    public static string getAccountProfile(){
        try {
            return BigBrainAPI.getAccountProfile('841481');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
