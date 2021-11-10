@isTest 
public class BigBrian_GraphQLServiceTest {
    static testmethod void testSendCalloutToBB(){
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        BigBrian_GraphQLService.bigBrainRequest bbRequest = new BigBrian_GraphQLService.bigBrainRequest();
        bbRequest.entityName = 'accounts';
        bbRequest.filterConditions = 'slugs: [\\"test\\"], limit: 1';
        bbRequest.outputFieldsList = 'pulse_account_id,name';
        bbRequest.outputRelatedEntities = 'account_owners{name,email}';
        List<BigBrian_GraphQLService.bigBrainRequest> bbRequestsList = new List<BigBrian_GraphQLService.bigBrainRequest>();
        bbRequestsList.add(bbRequest);
        Test.startTest();
        List<String> resList = BigBrian_GraphQLService.searchRecordsInBB(bbRequestsList);
        Test.stopTest();
    }

    public class mockCallout implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setBody('{"data":{"accounts":[{"pulse_account_id":123456,"name":"Test.com","account_owners":[{"email":"test@monday.com"},{"email":"test2@monday.com"}]}]}}');
            res.setStatusCode(200);
            return res;
        }   
    }
}
