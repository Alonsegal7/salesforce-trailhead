public class BillingEntity_PreventMaessage {
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Billing_Entity__c'];
    
        // Perform isAccessible() check here
        return listviews;
    }
    
    @AuraEnabled
    public static Boolean getUserProfile() {
        system.debug('### in function');
        Boolean billingEntityAvailable = false;
        Id profileId = userinfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: profileId].Name;
        
        if(profileName == 'Finance' || profileName == 'System Administrator'){
            billingEntityAvailable = true;
        }
        system.debug('### billingEntityAvailable: ' + billingEntityAvailable);
        return billingEntityAvailable;
    }
}