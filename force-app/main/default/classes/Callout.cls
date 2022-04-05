global class Callout {

    public static Boolean firstRunBatch = true;
    public static Webhook_Key__mdt whMTD;

    @Future(callout=true)
    public static void postFuture(String serializedObject, String method) {
        doCallout(serializedObject, method);
    }

    public static void post(String serializedObject, String method) {
        if(!System.isBatch()){
            if(!Test.isRunningTest() || system.Limits.getFutureCalls() < 50){ //protection from system.limitexception too many future calls 51
                postFuture(serializedObject, method);
            }
        } else if(firstRunBatch){
            firstRunBatch = false;
            System.enqueueJob(new sendCalloutQueueable(serializedObject, method));
        }
    }

    private class sendCalloutQueueable implements System.Queueable, Database.AllowsCallouts {
        private String serializedObject; 
        private String method;
        public sendCalloutQueueable(String serializedObject, String method) {
            this.serializedObject = serializedObject;
            this.method = method;
        }
        public void execute(System.QueueableContext ctx) {
            doCallout(serializedObject, method);
        }
    } 

    private static void doCallout(String serializedObject, String method){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String url = ConfigManager.getBigBrainWebhookUrl();
        if(whMTD == null) whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
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