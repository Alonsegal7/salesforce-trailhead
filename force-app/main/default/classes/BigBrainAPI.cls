public with sharing class BigBrainAPI {
    public class BigBrainException extends Exception {}

    public BigBrainAPI() { }

    public static String getAccountProfile(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId);
    }
    
    public static String getAccountUsers(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId + '/users');
    }

    public static String getAccountBilling(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId + '/billings');
    }

    public static String getAccountFeaturesUsage(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId + '/features_usage');
    }

    public static String getAllOpportunityBillings(String opportunityId){
        return get('/salesforce_api/opportunity/' + opportunityId + '/get_all_opportunity_billings');
    }

    public static String getForecastDetails(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId + '/forecast_details');
    }

    public static String getPlans(String pricingVersion){
        return get('/salesforce_api/plans/' + pricingVersion);
    }
    
    public static String getAllGrantedFeatures(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId + '/available_features');
    }

    public static String getAccountUsedGrantedFeatures(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId + '/granted_features');
    }

    public static String grantAccountFeatures(String pulseAccountId, List<String> features){
        Map<String, String> requestParams = new Map<String, String>();
        Date future_date = Date.today().addDays(30);

        requestParams.put('features', String.join(features,','));
        requestParams.put('due_date', future_date.format());
        requestParams.put('reason', 'partner granted feature from salesforce plugin');
        
        return put('/salesforce_api/account/' + pulseAccountId + '/grant_features', requestParams);
    }

    public static String ungrantAccountFeatures(String pulseAccountId, List<string> features){
        Map<String, String> requestParams = new Map<String, String>();
        requestParams.put('features', String.join(features,','));

        return put('/salesforce_api/account/' + pulseAccountId + '/ungrant_features', requestParams);
    }

    public static String setAccountFreeUsers(String pulseAccountId, Integer freeUsers, string untilDate){
        Map<String, String> mapName = new Map<String, String>();
        mapName.put('free_users', String.valueOf(freeUsers));
        mapName.put('due_date', untilDate);

        return put('/salesforce_api/account/' + pulseAccountId + '/free_users', mapName);
    }

    public static String resetAccountTrial(String pulseAccountId){
        Map<String, String> mapName = new Map<String, String>();
        return put('/salesforce_api/account/' + pulseAccountId + '/reset_trial');
    }

    private static string get(String url) {
        HttpResponse response = makeRequest('GET', url);
        return response.getBody();
    }

    public static string put(String url, Map<String, String> params) {
        HttpResponse response = makeRequest('PUT', url, params);
        return response.getBody();
    }

    public static string put(String url) {
        HttpResponse response = makeRequest('PUT', url);
        return response.getBody();
    }

    private static HttpResponse makeRequest(String method, String url, Map<String, String> params){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setRequestHeaders(request, method, url);
        request.setBody(JSON.serialize(params));
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 200) {
            throw new AuraHandledException(response.getBody());
        }

        return response;
    }

    private static HttpResponse makeRequest(String method, String url){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setRequestHeaders(request, method, url);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 200) {
            throw new AuraHandledException(response.getBody());
        }

        return response;
    }

    private static void setRequestHeaders(HttpRequest request, String method, String url){
        Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
        String baseUrl = ConfigManager.getBigBrainBaseUrl();
        String userType = [select Function__c from User where Id =: UserInfo.getUserId()][0].Function__c;

        request.setMethod(method);
        request.setEndpoint(baseUrl + url);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', whMTD.Key__c);
        request.setHeader('From', UserInfo.getUserEmail());
        request.setHeader('User-Type', userType);
    }
}
