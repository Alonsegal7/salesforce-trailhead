public with sharing class BigBrainService {
    public BigBrainService() {

    }
    
    @AuraEnabled
    public static string methodName(){
        try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
