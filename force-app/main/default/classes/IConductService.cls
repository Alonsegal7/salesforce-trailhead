public class IConductService {
	public static void handleBillingEntitySync(Id BillingEntityId) {
        string BillingEntityProcessId = ConfigManager.getIConductBillingEntitySyncPID();
        string payload = '{"parameters": [{ "Key":"Billing_Entity_Id", "Value":"' + BillingEntityId + '" }]}';
        post(BillingEntityProcessId, payload);
    }
    
    public static void handleQuoteSync(Id QuoteId) {
        string QuoteProcessId = ConfigManager.getIConductQuoteSyncPID();
        string payload = '{"parameters": [{ "Key":"Quote_Id", "Value":"' + QuoteId + '" }]}';
        post(QuoteProcessId, payload);
    }
    
    @Future(callout=true)
    private static void post(String processID, String payload) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        string APIToken = 'E724AABD-89CB-48E6-996F-AEE061C76FF5';
        string APIBaseUrl = 'https://www11.iconductcloud.com/api/v11/api.svc/json/Execute/';
        string url = APIBaseUrl + processID;

        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Username', 'eranb@monday.com');
        request.setHeader('Token', APIToken);
        request.setBody(payload);
        request.setTimeout(60000);
        
        if (!Test.isRunningTest()) {
            HttpResponse response = http.send(request);
        }
    }
}