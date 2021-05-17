global class Callout {
    
    @Future(callout=true)
    public static void post(String serializedObject, String method) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
        String url = ConfigManager.getBigBrainWebhookUrl();
        request.setEndpoint(url);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', whMTD.Key__c);
        
        request.setBody(serializedObject);
        if (!Test.isRunningTest()){
            HttpResponse response = http.send(request);    
        }
    }
    
    public static void inBatches(List<sObject> objects, String method){
        List<sObject> arr = new List<sObject>();
        for(sObject o : objects){
            if(arr.size() < 50){
                arr.add(o);
            }
            else{
                Callout.post(JSON.serialize(arr), method);
                arr.clear();
            }
        }
        if(arr.size() > 0){
         	Callout.post(JSON.serialize(arr), method);   
        }
    }    
    
    public static void callUpdate(List<sObject> objects) {
        inBatches(objects, 'POST');
    }
    
    public static void callDelete(List<sObject> objects) {
        inBatches(objects, 'DELETE');
    }
}