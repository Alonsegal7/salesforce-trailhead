public without sharing class Utilities {
    static map<string,Country_Region_Mapping__c> regionsMapping= null;
    static map<id,GB_Threshold__c> allTHs= null;
    static Pricebook2 mainPB= null;

    public class sendEmailRequest {
        //required
        @InvocableVariable(label='To Address (separated by comma)' required=true)
        public list<String> toAddress;
        @InvocableVariable(label='Email Template Id' required=true)
        public Id templateId;
        @InvocableVariable(label='Who Id (The identifier of an object in the database, typically a contact, lead, or user. The database record for that object is read and used in merge field processing)' required=true)
        public Id whoId;
        //optional
        @InvocableVariable(label='ccRecipients (separated by comma)' required=false)
        public list<String> ccRecipients;
        @InvocableVariable(label='reply to address' required=false)
        public String replyTo;
        @InvocableVariable(label='Sender Display Name (in case you fill this, the email will be sent from the running user)' required=false)
        public String senderDisplayName;
        @InvocableVariable(label='Organization-Wide Email Address Id (in case you fill this, Sender Display Name is not relevant)' required=false)
        public Id oweaId;
        @InvocableVariable(label='What Id (Identifies an object in the database, like an account or opportunity. The record for that object is read and used in merge field processing)' required=false)
        public Id whatId;
    }

    @InvocableMethod(label='Send Email by Apex')
    public static void sendEmail(List<sendEmailRequest> requests) {
        try {
            List<Messaging.SingleEmailMessage> allEmailsToSend = new List<Messaging.SingleEmailMessage>();
            for(sendEmailRequest req : requests){
                allEmailsToSend.add(generateEmail(req.toAddress, req.ccRecipients, req.replyTo, req.whoId, req.templateId, req.senderDisplayName, req.oweaId));
            }
            Messaging.sendEmail(allEmailsToSend);
        } catch(Exception e){
            Utilities.sendEmail('Error in sendEmail: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{'kseniasm@monday.com'}); 
        }
    }

    public static Messaging.SingleEmailMessage generateEmail(List<String> toAddresses, List<String> ccAddresses, String replyTo, Id targetObjectId, Id emailTemplateId, String senderDisplayName, Id oweaId){
        Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(emailTemplateId, targetObjectId, null);
		Messaging.SingleEmailMessage resEmail = new Messaging.SingleEmailMessage();
		resEmail.setSubject(renderedEmail.getSubject());
		resEmail.setHtmlBody(renderedEmail.getHtmlBody());
        resEmail.setPlainTextBody(renderedEmail.getPlainTextBody());
        resEmail.setToAddresses(toAddresses);
		resEmail.setBccAddresses(new List<String>{'kseniasm@monday.com','mayga@monday.com'});
		resEmail.setSaveAsActivity(false);

        if(ccAddresses != null) resEmail.setCcAddresses(ccAddresses);
		if(replyTo != null && replyTo != '') resEmail.setReplyTo(replyTo); 
		if(senderDisplayName == null || senderDisplayName == '') {
            Id orgWideEmailAddressId = (oweaId == null || oweaId == '') ? oweaId : [select Id from orgWideEmailAddress where Address =: 'bizops@monday.com' limit 1].Id;
            resEmail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        } else {
            resEmail.setSenderDisplayName(senderDisplayName);
        }
		return resEmail;
	}

    //Sends an email to the Salesforce admins
    public static void sendDebugEmail(String subject, Exception e, String additionalData){
        list<String> toAddresses=new list<String>{label.SystemNotificationsDL};
        String emailBody=e.getMessage()+'<br/>Line: '+e.getLineNumber()+'<br/>Stack: '+e.getStackTraceString();
        emailBody+='<br/><br/>Timestamp: '+Datetime.now()+'<br/><br/>'+additionalData;
        sendEmail(subject,emailBody,toAddresses);
    }
     
    public static void sendEmail(String subject, String body, list<String> toAddresses){
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(body+'<br/><br/>Timestamp: '+Datetime.now());
        
        try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }catch(Exception e){}
    }
    
    public static void sendEmail(String subject, String body, list<String> toAddresses, list<String> bccAddresses){
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toAddresses);
        mail.setBccAddresses(bccAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(body+'<br/><br/>Timestamp: '+Datetime.now());
        
        try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }catch(Exception e){}
    }
    
    public static String capitalizeString(String str){
        return str.subString(0,1).toUpperCase()+str.subString(1,str.length());
    }
    public static map<string,Country_Region_Mapping__c> getRegionMapping(){
        if(regionsMapping==null){
            regionsMapping= new map<string,Country_Region_Mapping__c>();
            for(Country_Region_Mapping__c rm: [select id,Name,Region__c,Sub_Region__c from Country_Region_Mapping__c])
                regionsMapping.put(rm.Name,rm);
        }
        return regionsMapping;
    }
    public static map<id,GB_Threshold__c> getAllTHs(){
        if(allTHs==null)
            allTHs= new map<Id,GB_Threshold__c>([select id,Min_ARR__c from GB_Threshold__c]);
        return allTHs;
    }
    public static Pricebook2 getMainPB(){
        if(mainPB==null && !Test.isRunningTest()) mainPB = [select id from pricebook2 where Is_Main__c=true limit 1][0];
        return mainPB;
    }

    public static Opportunitylineitem createOLIfromSubscription(Id oppId, Subscription__c sub, PriceBookEntry pbe, Boolean isFree){
        opportunitylineitem oli= new opportunitylineitem();
        oli.Subscription__c=sub.Id;
        oli.OpportunityId=oppId;
        oli.Seats__c=integer.valueof(sub.Seats__c);
        oli.Tier__c=sub.Tier__c;
        oli.Plan_Period__c=sub.Period__c;
        oli.PriceBookEntry=pbe;
        oli.PricebookEntryId=pbe.id;
        oli.CC_Claim_Product__c=true;
        oli.ServiceDate=sub.Activation_Date__c!=null?sub.Activation_Date__c:null;
        oli.UnitPrice=sub.Unit_Price__c!=null?sub.Unit_Price__c:0;                                                  
        oli.Discount=sub.Discount__c!=null&&sub.Discount__c>=0?sub.Discount__c:0; 
        if(!isFree){
            oli.Product_Type__c='License';
            oli.ARR__c=sub.ARR_Gain__c;
            oli.Quantity=sub.Paid_Months__c*integer.valueof(sub.Seats__c);
            oli.CC_Subscription_Full_ARR__c=sub.ARR__c;
        }else{
            oli.Product_Type__c='Free';
            oli.ARR__c=0;
            oli.Quantity=sub.Free_Months__c*integer.valueof(sub.Seats__c);
        }
        return oli;
    }

    public static void sendSlackMessage(String messageTitle, String channel, String emoji,Exception e, String errorMessage, String additionalInfo, String recordId){
        Slack_MessageService.slackRequest request= new Slack_MessageService.slackRequest();
        request.slackMessage=messageTitle;
        request.channel=channel;
        request.emoji=emoji;
        request.additionalInfo=additionalInfo;
        request.recordId=recordId;
        request.errorMessage=errorMessage;
        request.e=e;
        Slack_MessageService.sendToSlack(new list<Slack_MessageService.slackRequest>{request});
    }

    public static void cleanFlexQueue(){
        List<AsyncApexJob> jobsList = [select Id, ApexClass.Name from AsyncApexJob where Status = 'Holding'];
        if(jobsList.size() > 90){
            Integer iterations = 20;
            for(AsyncApexJob job: jobsList){
                if(job.ApexClass.Name == 'TriggerProducerBatchWorker' && iterations > 0){
                    System.abortJob(job.Id);
                    iterations--;
                }
            }
        }
    }

    public static void updateAndRetry(List<SObject> recordsToUpdate ) {
        try {
            update recordsToUpdate;
        }      
        catch (Exception ex) {
            if(ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW')){
                try {
                    update recordsToUpdate; 
                }
                catch (Exception e) {
                    System.debug('Message: ' + e.getMessage());
                }
            }
            else {
                System.debug('Message: ' + ex.getMessage());
            }
        }
    }



    public static String setFirstLetterUpper(String str){
        return str.substring(0,1).toUpperCase() + str.substring(1,str.length());
    }
    public static String setPlanName(String tier, String seats, String period){
        return  setFirstLetterUpper(tier)+' -- Up to '+seats+' users ('+setFirstLetterUpper(period)+')';

    }

    public class updatesObjectsQueueable implements System.Queueable {
        private List<sObject> sobjectsToUpdate; 
        public updatesObjectsQueueable(List<sObject> sobjectsToUpdate) {
            this.sobjectsToUpdate = sobjectsToUpdate;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(sobjectsToUpdate);
        }
    }

    public static Date convertDatetimeToDate(Datetime dt){
        return Date.newinstance(dT.year(), dT.month(), dT.day());
    }

    public static Id MARecordTypeId {  
        get {  
            if (MARecordTypeId == null) {  
                MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();  
            }
            return MARecordTypeId;  
        }  
        set;  
    }

    public static Id CompanyRecordTypeId {  
        get {  
            if (CompanyRecordTypeId == null) {  
                CompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();  
            }
            return CompanyRecordTypeId;  
        }  
        set;  
    }

    public static Id AccountsPoolUserId {  
        get {  
            if (AccountsPoolUserId == null) {  
                AccountsPoolUserId = '0053X00000Bo8ZZQAZ';  
            }
            return AccountsPoolUserId;  
        }  
        set;  
    }
}