public with sharing class Opportunity_ClaimDetailsController {
    @AuraEnabled(cacheable=true)
    public static User getUserDetails(String userId){
        try{
            User user=[select id,ProfileId,Profile.Name from User where id=:userId limit 1][0];
            return user;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}
