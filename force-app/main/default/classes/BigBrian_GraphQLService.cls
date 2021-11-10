public without sharing class BigBrian_GraphQLService {
    public static String authToken;

    public class bigBrainRequest {
        @InvocableVariable(label='Data Type (user/account)' required=true)
        public String entityName;
        @InvocableVariable(label='Filter Conditions' required=true)
        public String filterConditions;
        @InvocableVariable(label='Output Fields List (f.e  id,name)' required=true)
        public String outputFieldsList;
        @InvocableVariable(label='Output Related Entities (f.e account_owners{name,email})' required=false)
        public String outputRelatedEntities;
    }

    @InvocableMethod(label='Search Records in BigBrain')
    public static List<String> searchRecordsInBB(List<bigBrainRequest> requests) {
        List<String> resList = new List<String>();
        String query;
        try {
            for(bigBrainRequest req : requests){
                query = buildQuery(req.entityName, req.filterConditions, req.outputFieldsList, req.outputRelatedEntities);
                HttpResponse res = sendCallout(query);
                resList.add(JSON.serialize(res.getBody()));
            }
        } catch(Exception e){
            Utilities.sendEmail('Error in GraphQL_CalloutService: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'kseniasm@monday.com'}); 
        }
        return resList;
    }
    public static string buildQuery(String entityName, String filterConditions, String outputFieldsList, String outputRelatedEntities){
        String query = '{"query":"{' + entityName + '(' + filterConditions+')' + '{'+outputFieldsList;
        if(outputRelatedEntities != null && outputRelatedEntities != '') query += ',' + outputRelatedEntities;
        query += '}}"}';
        return query;
    } 

    public static HttpResponse sendCallout(String query) {
        Http http = new Http(); 
        HttpRequest request = new HttpRequest();
        String endpoint = ConfigManager.getBigBrainGraphQLUrl();
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        if(authToken == null) authToken = [select Key__c from Webhook_Key__mdt where DeveloperName = 'GraphQL' limit 1].Key__c;
        request.setHeader('Authorization', authToken);
        request.setBody(query);
        request.setTimeout(120000);
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        return response;
    }
}
