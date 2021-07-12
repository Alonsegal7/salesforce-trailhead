public without sharing class LeadsCap_MonitorWidgetController {
    @AuraEnabled(cacheable=true)
    public static Leads_Cap__c getLeadCapDetails(String userId){
        try{
            User user=[select id,ProfileId,Profile.Name,IsPortalEnabled,ContactId,Contact.AccountId 
                        from User where id=:userId 
                        limit 1][0];
            system.debug('LCMWC Raz Ben Ron user: '+user);
            string query='select id,Channel_Partner__c,User__c,Open_Leads_Actual__c,Open_Leads_Limit__c,Available_for_Distribution__c,Remaining_Leads_to_Hold__c ';
            query+=' from Leads_Cap__c where ';
            if(user.IsPortalEnabled){
                query+='Channel_Partner__c= \''+ user.Contact.AccountId + '\' ';
            }else{
                query+='User__c= \''+ user.Id +'\' ' ;
            }
            query+=' order by createddate DESC limit 1 ';
            Leads_Cap__c  lc=(Leads_Cap__c)Database.Query(query)[0];
            system.debug('LCMWC Raz Ben Ron lc: '+lc);
            return lc;

        }catch(Exception e){
            system.debug('LCMWC Raz Ben Ron e.getMessage(): '+e.getMessage()); 
            throw new AuraHandledException(e.getMessage());
        }
    }
}