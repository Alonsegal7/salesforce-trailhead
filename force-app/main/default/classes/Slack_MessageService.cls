public with sharing class Slack_MessageService {
    public class slackRequest { 
        @InvocableVariable(label='Slack Message' required=true) 
        public String slackMessage; 
        @InvocableVariable(label='Channel/User to post to' required=true) 
        public String channel; 
        @InvocableVariable(label='Emoji (for example":monkey_face:") ') 
        public String emoji; 
        @InvocableVariable(label='Error Message') 
        public String errorMessage; 
        @InvocableVariable(label='Additional Information') 
        public String additionalInfo; 
        @InvocableVariable(label='Record Id') 
        public String recordId; 
        public Exception e;
    } 
    
    @InvocableMethod(label='Send to Slack')
    public static void sendToSlack(List<slackRequest> requests) {
        String webhookURL='https://hooks.slack.com/services/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'; 
        for(slackRequest r:requests){
            requestDefaultValues(r);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('text', r.slackMessage);
            gen.writeStringField('channel', r.channel);
            gen.writeStringField('username', 'Salesforce Bot');
            gen.writeStringField('icon_emoji', r.emoji);
            gen.writeStringField('blocks', setMessageBody(r));
            gen.writeEndObject();
            String body = gen.getAsString(); 
            System.enqueueJob(new sendReq(webhookURL, 'POST', body));
        } 
    }

    public static String setMessageBody(slackRequest r){
        String section1='';
        String section2='';
        String button='';
        String recordURL='https://monday.my.salesforce.com/'+ r.recordId;
        String block='[';
        String message='{"type": "section","text": {"type": "mrkdwn","text": "'+r.slackMessage+'"}}';
        block+=message;
        System.debug('Raz Ben Ron BBGQL req error message:'+r.errorMessage);
        if(r.errorMessage!=null&&r.errorMessage!=''){
            section1='{"type": "section","text": {"type": "mrkdwn","text": "*Error Message:* '+r.errorMessage+' [Timestamp: '+datetime.now()+']"}}';
            block+=','+section1;
        }
        if(r.additionalInfo!=null&&r.additionalInfo!=''){
            section2='{"type": "section","text": {"type": "plain_text","text": "'+r.additionalInfo+'","emoji": true}}';
            block+=','+section2;
        }
        if(r.recordId!=null&&r.recordId!=''){
            button='{"type": "section","text": {"type": "mrkdwn","text": "Click to See Record in Salesforce"},"accessory": {"type": "button","text": {"type": "plain_text","text": "Go","emoji": true},"value": "click_me1","url": "'+recordURL+'","action_id": "button-action"}}';
            block+=','+button;
        }
        block+=']';
        System.debug('Raz Ben Ron SMS block:'+block);
        return block;
    }

    public static void requestDefaultValues(slackRequest r){
        if(r.channel==null||r.channel=='')
            r.channel=label.Team_Slack_Channel;
        if(r.emoji==null||r.emoji=='')
            r.emoji=':warning:';
        if(r.e!=null)
            r.errorMessage=r.e.getMessage()+',  '+r.e.getStackTraceString()+',  '+r.e.getLineNumber();

    }
    public class sendReq implements System.Queueable, Database.AllowsCallouts{

        private final String url;
        private final String method;
        private final String body;
         
        public sendReq(String url, String method, String body) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
        public void execute(System.QueueableContext ctx) {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod(method);
            req.setBody(body);
            HttpResponse res = http.send(req);
            System.debug('Raz Ben Ron SMS queueable res.getbody():'+res.getbody());
        }
    }
}