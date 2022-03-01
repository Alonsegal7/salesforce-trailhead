public class IConductService implements Queueable, Database.AllowsCallouts{
    private final String ProcessId;
    private final String payload;
    public IConductService(string process, Id Id){
        if (process == 'BillingEntityERPInsertUpdateSync') {
            this.ProcessId = ConfigManager.getIConductBillingEntitySyncPID();
            this.payload = '{"parameters": [{ "Key":"Billing_Entity_Id", "Value":"' + Id + '" }]}';
        }
        if (process == 'QuoteERPInsertOnlySync') {
            this.ProcessId = ConfigManager.getIConductQuoteSyncPID();
            this.payload = '{"parameters": [{ "Key":"Quote_Id", "Value":"' + Id + '" }]}';
        }
        if (process == 'QuoteCreditSync') {
            this.ProcessId = ConfigManager.getIConductQuoteCreditSyncPID();
            this.payload = '{"parameters": [{ "Key":"Quote_Id", "Value":"' + Id + '" }]}';
        }

    }
    public void execute(QueueableContext qc){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        string APIToken = [select id, Key__c from Webhook_Key__mdt where DeveloperName='iConduct' limit 1].Key__c;
        string APIBaseUrl = 'https://www11.iconductcloud.com/api/v11/api.svc/json/Execute/';
        string url = APIBaseUrl + processID;
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Username', 'eranb@monday.com');
        request.setHeader('Token', APIToken);
        request.setBody(payload);
        request.setTimeout(120000);   
        if (!Test.isRunningTest()) {
            HttpResponse response = http.send(request);
        }
    }
}