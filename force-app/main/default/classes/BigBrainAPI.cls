public with sharing class BigBrainAPI {
    public class BigBrainException extends Exception {}

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
        String params = 'free_users=' + String.valueOf(freeUsers);
        if (untilDate != null && untilDate != ''){
            params += '&due_date='+untilDate;
        }
        return put('/exposed_partners/set_free_users/' + pulseAccountId, params);
    }

    private static string get(String url) {
        HttpResponse response = makeRequest('GET', url);
        return response.getBody();
    }

    public static string put(String url, String params) {
        HttpResponse response = makeRequest('PUT', url);
        return response.getBody();
    }

    private static HttpResponse makeRequest(String method, String url, String params){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setRequestHeaders(request, method, url);
        request.setBody(params);
        HttpResponse response = http.send(request); 


        if (response.getStatusCode() != 200) {
            throw new BigBrainException();
        }

        return response;
    }

    private static HttpResponse makeRequest(String method, String url){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setRequestHeaders(request, method, url);
        HttpResponse response = http.send(request); 

        if (response.getStatusCode() != 200) {
            throw new BigBrainException();
        }

        return response;
    }

    private static void setRequestHeaders(HttpRequest request, String method, String url){
        Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
        String baseUrl = ConfigManager.getBigBrainBaseUrl();

        request.setMethod(method);
        request.setEndpoint(baseUrl + url);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', whMTD.Key__c);
        request.setHeader('From', UserInfo.getUserEmail());
    }
}
