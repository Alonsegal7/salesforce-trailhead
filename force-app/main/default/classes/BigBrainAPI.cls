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

    public static String getAllOpportunityBillings(String pulseAccountId, String opportunityId){
        return get('/salesforce_api/account/' + pulseAccountId + '/get_all_opportunity_billings/?opportunity_id=' + opportunityId);
    }

    public static String getSalesOrderPreview(String pulseAccountId,string quoteId){
        return get('/salesforce_api/account/'+pulseAccountId+'/preview_sales_order/'+quoteId);
    }

    public static String getForecastDetails(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId + '/forecast_current_state');
    }

    public static String getActionsDetails(String pulseAccountId){
        return get('/salesforce_api/account/' + pulseAccountId + '/actions_current_state');
    }

    public static String getPlans(String pricingVersion){
        return get('/salesforce_api/plans/' + pricingVersion);
    }

    public static HttpResponse refreshSignups(list<String> pulse_account_ids, Boolean limited){
        Map<String,Object> reqBody = new Map<String,Object>();
        reqBody.put('pulse_account_ids',pulse_account_ids);
        reqBody.put('limited',limited);
        string url = '/salesforce_api/signups_refresh';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
        String baseUrl = 'https://data.bigbrain.me'; //hardcoded to pull from prod on purpose
        String userType = [select Function__c from User where Id =: UserInfo.getUserId()][0].Function__c;
        request.setMethod('POST');
        request.setEndpoint(baseUrl + url);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', whMTD.Key__c);
        request.setHeader('From', UserInfo.getUserEmail());
        request.setHeader('User-Type', userType);
        request.setBody(JSON.serialize(reqBody));
        request.setTimeout(120000);

        HttpResponse response = http.send(request);
        return response;
    }

    public static HttpResponse pullSignups(Datetime from_date_time, Datetime to_date_time){
        string url = '/salesforce_api/signups?';
        String f = string.valueOf(from_date_time).replace(' ', '%20');
        String t = string.valueOf(to_date_time).replace(' ', '%20');
        url += 'from_date_time='+f+'&to_date_time='+t;

        //return get(url); 

        //the following section is for testing the endpoint in fullsandbox while pulling signups from bb prod
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
        String baseUrl = 'https://data.bigbrain.me'; //hardcoded to pull from prod on purpose
        String userType = [select Function__c from User where Id =: UserInfo.getUserId()][0].Function__c;
        request.setMethod('GET');
        request.setEndpoint(baseUrl + url);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', whMTD.Key__c);
        request.setHeader('From', UserInfo.getUserEmail());
        request.setHeader('User-Type', userType);
        request.setTimeout(120000);

        HttpResponse response = http.send(request);
        return response;
    }

    public static String grantAccountFeatures(String pulseAccountId, List<String> features){
        Map<String, String> requestParams = new Map<String, String>();
        Date dueDate = Date.today().addDays(30);

        requestParams.put('features', JSON.serialize(features));
        requestParams.put('due_date', dueDate.format());
        requestParams.put('reason', 'partner granted feature from salesforce plugin');

        return put('/salesforce_api/account/' + pulseAccountId + '/grant_features', requestParams);
    }

    public static String ungrantAccountFeatures(String pulseAccountId, List<string> features){
        Map<String, String> requestParams = new Map<String, String>();
        requestParams.put('features', JSON.serialize(features));

        return put('/salesforce_api/account/' + pulseAccountId + '/ungrant_features', requestParams);
    }

    public static String setAccountFreeUsers(String pulseAccountId, Integer freeUsers, String untilDate){
        Map<String, String> mapName = new Map<String, String>();
        mapName.put('free_users', String.valueOf(freeUsers));
        mapName.put('due_date', untilDate);
        return put('/salesforce_api/account/' + pulseAccountId + '/free_users', mapName);
    }

    public static String resetAccountTrial(String pulseAccountId){
        return put('/salesforce_api/account/' + pulseAccountId + '/reset_trial');
    }

    public static String setPricingVersion(String pulseAccountId, String version) {
        Map<String, String> mapName = new Map<String, String>();
        mapName.put('version', version);
        return put('/salesforce_api/account/' + pulseAccountId + '/pricing_version', mapName);
    }

    private static string get(String url) {
        HttpResponse response = makeRequest('GET', url);
        return response.getBody();
    }

    private static string put(String url, Map<String, String> params) {
        HttpResponse response = makeRequest('PUT', url, params);
        return response.getBody();
    }

    private static string put(String url) {
        HttpResponse response = makeRequest('PUT', url);
        return response.getBody();
    }

    private static HttpResponse makeRequest(String method, String url, Map<String, String> params){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setRequestHeaders(request, method, url);
        request.setBody(JSON.serialize(params));

        if(Test.isRunningTest()){ return new HttpResponse(); }
        HttpResponse response = http.send(request);
        return response;
    }

    private static HttpResponse makeRequest(String method, String url){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        setRequestHeaders(request, method, url);

        if(Test.isRunningTest()){ return new HttpResponse(); }
        HttpResponse response = http.send(request);
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