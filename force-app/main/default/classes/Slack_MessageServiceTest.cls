@isTest
public with sharing class Slack_MessageServiceTest {
    static testmethod void testSendToSlack(){
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        List<Slack_MessageService.slackRequest> requests = new List<Slack_MessageService.slackRequest>();
        Slack_MessageService.slackRequest req = new Slack_MessageService.slackRequest();
        req.slackMessage='test message';
        req.channel='#monday_salesforce_test';
        req.emoji=':test:';
        req.errorMessage='error test';
        req.additionalInfo='info';
        req.recordId='12345';
        requests.add(req);
        Slack_MessageService.sendToSlack(requests);
    }
    
    public class mockCallout implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            HttpResponse res = new HttpResponse();
            res.setBody( '{"text":"value"}');
            res.setStatusCode(200);
            return res;
        }   
    }
}