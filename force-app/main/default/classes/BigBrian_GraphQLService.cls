public with sharing class BigBrian_GraphQLService {

    public class bbRequest { 
        @InvocableVariable(label='Data Type (user/account)' required=true) 
        public String dataType; 
        @InvocableVariable(label='User Id') 
        public String userId; 
        @InvocableVariable(label='Email Address') 
        public String email; 
        @InvocableVariable(label='User Outputs (seperated by ,)') 
        public String userOutputs; 
        @InvocableVariable(label='Account Outputs (seperated by ,)') 
        public String accountOutputs; 
        @InvocableVariable(label='Account Id') 
        public String accountId; 
    }

    @InvocableMethod(label='Search Record in BigBrain')
    public static list<String> searchInBB(List<bbRequest> requests) {
        list<String> resList=new list<String>();
        try{
            for(bbRequest r:requests){
                String body='';
                if(r.dataType=='user'){
                    if(r.userOutputs==null||r.userOutputs=='')
                    r.userOutputs='id';
                    if(r.userId!=null&&r.userId!=''){
                        body = '{"query": "{users(ids:'+r.userId+') ';
                    }else if (r.email!=null){
                        body = '{"query": "{users(emails:' + r.email + ') {'+r.userOutputs+', account{name, pulse_account_id, plan{id}}}}"}';
                    }
                    body+=' {'+r.userOutputs;
                    if(r.accountOutputs!=null&&r.accountOutputs!=''){
                        body+=', account{'+r.accountOutputs+'} ';
                    }
                }else if(r.dataType=='account'){
                    if(r.accountOutputs==null||r.accountOutputs=='')
                    r.accountOutputs='id';
                    if(r.accountId!=null&&r.accountId!=''){
                        body = '{"query": "{accounts(ids:'+r.accountId+') ';
                    }
                    body+=' {'+r.accountOutputs;
                }
                body+=' }}"}';
                System.debug('Raz Ben Ron BBGQL req body:'+body);
                HttpResponse res = calloutToBB(body);
                System.debug('Raz Ben Ron BBGQL res.getBody():'+res.getBody());
                resList.add(JSON.serialize(res.getBody()));
                integer i=1/0;
            }
        }catch(Exception e){
            //Utilities.sendSlackMessage(':bomb::bomb: A very important error message from class xxxxx :bomb::bomb:','test-raz',null,e,null,null,'12345678');
        }
        return resList;
        
    }
    public static HttpResponse calloutToBB(String body){
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setEndpoint('https://data.bigbrain.me/graphql/v1'); 
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0aWQiOjExLCJhaWQiOjEzNjYsImlhZCI6IjIwMjEtMDEtMDMgMTM6MjM6MDMgVVRDIn0.6TgTmtvEX_y2HS-zw7JXc0CZRKXPJnUAtnvfuuIzzEk');
        request.setBody(body);
        HttpResponse response = http.send(request);
        return response;
    }
}