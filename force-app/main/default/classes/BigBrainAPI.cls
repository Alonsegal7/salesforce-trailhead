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

    public static String setAccountFreeUsers(String pulseAccountId, Integer freeUsers, string untilDate){
        String params = 'due_date='+untilDate+'&free_users='+freeUsers;
        return put('/exposed_partners/set_free_users/' + pulseAccountId, params);
    }

    private static string get(String url) {
        HttpResponse response = makeRequest('GET', url);
        return response.getBody();
    }

    private static string put(String url, String params) {
        HttpResponse response = makeRequest('PUT', url);
        return response.getBody();
    }

    private static HttpResponse makeRequest(String method, String url, String params){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setRequestHeaders(request, method, url);
        request.setBody(params);
        HttpResponse response = http.send(request); 
        return response;
    }

    private static HttpResponse makeRequest(String method, String url){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setRequestHeaders(request, method, url);
        HttpResponse response = http.send(request); 
        return response;
    }

    private static void setRequestHeaders(HttpRequest request, String method, String url){
        Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
        String baseUrl = ConfigManager.getBigBrainBaseUrl();
        request.setMethod(method);
        request.setEndpoint(baseUrl + url);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', whMTD.Key__c);
    }
}
