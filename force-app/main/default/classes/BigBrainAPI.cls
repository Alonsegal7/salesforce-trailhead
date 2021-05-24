public with sharing class BigBrainAPI {
    public BigBrainAPI() {

    }

    public static String getAccountProfile(String pulseAccountId){
        return get('/exposed_partners/profile/' + pulseAccountId);
    }
    
    public static String getAccountUsers(String pulseAccountId){
        return get('/exposed_partners/users/' + pulseAccountId);
    }

    public static String getAccountBilling(String pulseAccountId){
        return get('/exposed_partners/billing/' + pulseAccountId);
    }

    private static string get(String method) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
        String url = ConfigManager.getBigBrainBaseUrl();
        request.setEndpoint(url + method);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', whMTD.Key__c);
        
        HttpResponse response = http.send(request);    
        return response.getBody();
    }
}
