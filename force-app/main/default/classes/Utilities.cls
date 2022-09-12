public without sharing class Utilities {
    static map<string,Country_Region_Mapping__c> regionsMapping= null;
    static map<string,Lead_Channel_Mapping__mdt> channelMapping= null;
    static map<id,GB_Threshold__c> allTHs= null;
    static Pricebook2 mainPB= null;

    public class sendEmailRequest {
        //required
        @InvocableVariable(label='To Address (separated by comma)' required=true)
        public list<String> toAddress;
        @InvocableVariable(label='Email Template Unique Name' required=true)
        public String emailTempUniqName;
        @InvocableVariable(label='Who Id (The identifier of an object in the database, typically a contact, lead, or user. The database record for that object is read and used in merge field processing)' required=true)
        public Id whoId;
        //optional
        @InvocableVariable(label='ccRecipients (separated by comma)' required=false)
        public list<String> ccRecipients;
        @InvocableVariable(label='reply to address' required=false)
        public String replyTo;
        @InvocableVariable(label='Sender Display Name (in case you fill this, the email will be sent from the running user)' required=false)
        public String senderDisplayName;
        @InvocableVariable(label='Organization-Wide Email Address (in case you fill this, Sender Display Name is not relevant)' required=false)
        public String oweaAddress;
        @InvocableVariable(label='What Id (Identifies an object in the database, like an account or opportunity. The record for that object is read and used in merge field processing)' required=false)
        public Id whatId;
    }

    /* we added this invocable method bc curren */
    @InvocableMethod(label='Send Email by Apex')
    public static void sendEmail(List<sendEmailRequest> requests) {
        try {
            List<Messaging.SingleEmailMessage> allEmailsToSend = new List<Messaging.SingleEmailMessage>();
            for(sendEmailRequest req : requests){
                Messaging.SingleEmailMessage m = generateEmail(req.toAddress, req.ccRecipients, req.replyTo, req.whoId, req.emailTempUniqName, req.senderDisplayName, req.oweaAddress);
                if(m != null)allEmailsToSend.add(m);
            }
            if(!allEmailsToSend.isEmpty()) Messaging.sendEmail(allEmailsToSend);
        } catch(Exception e){
            Utilities.sendEmail('Error in sendEmail: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{'kseniasm@monday.com'}); 
        }
    }

    public static Messaging.SingleEmailMessage generateEmail(List<String> toAddresses, List<String> ccAddresses, String replyTo, Id targetObjectId, String emailTempUniqName, String senderDisplayName, String oweaAddress){
        List<EmailTemplate> emailTemp_list = [select Id from EmailTemplate where DeveloperName =: emailTempUniqName limit 1];
        if(emailTemp_list == null || emailTemp_list.isEmpty()) return null;
        Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(emailTemp_list[0].Id, targetObjectId, null);
		Messaging.SingleEmailMessage resEmail = new Messaging.SingleEmailMessage();
		resEmail.setSubject(renderedEmail.getSubject());
		resEmail.setHtmlBody(renderedEmail.getHtmlBody());
        resEmail.setPlainTextBody(renderedEmail.getPlainTextBody());
        resEmail.setToAddresses(toAddresses);
		resEmail.setBccAddresses(new List<String>{'kseniasm@monday.com','mayga@monday.com'});
		resEmail.setSaveAsActivity(false);

        if(ccAddresses != null) resEmail.setCcAddresses(ccAddresses);
		if(replyTo != null && replyTo != '') resEmail.setReplyTo(replyTo); 
        if(oweaAddress != null && oweaAddress != ''){
            list<orgWideEmailAddress> owea_list = [select Id from orgWideEmailAddress where Address =: oweaAddress limit 1];
            if(owea_list != null && !owea_list.isEmpty()){
                resEmail.setOrgWideEmailAddressId(owea_list[0].Id);
            }
        } else if(senderDisplayName != null && senderDisplayName != '') resEmail.setSenderDisplayName(senderDisplayName);
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
            for(Country_Region_Mapping__c rm: [select id,Country_Name__c,Name,Region__c,Sub_Region__c from Country_Region_Mapping__c])
                regionsMapping.put(rm.Name,rm);
        }
        return regionsMapping;
    }

    public static map<string,Lead_Channel_Mapping__mdt> getChannelMapping(){
        if(channelMapping==null){
            channelMapping= new map<string,Lead_Channel_Mapping__mdt>();
            for(Lead_Channel_Mapping__mdt lcm: [SELECT Id ,Channel__c, Lead_Source__c, Type__c FROM Lead_Channel_Mapping__mdt])
                channelMapping.put(lcm.Lead_Source__c,lcm);
        }
        return channelMapping;
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
                Utilities.sendDebugEmail('Error from updateAndRetry - First Attamp. Try again ',ex,ex.getMessage()); 
                try {
                    update recordsToUpdate; 
                }
                catch (Exception e) {
                    if (e.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW')) {
                        Utilities.sendDebugEmail('Error from updateAndRetry - Second Attamp. Try again ',e,e.getMessage()); 
                        try {
                            update recordsToUpdate; 
                        }
                        catch(Exception e1){
                            Utilities.sendDebugEmail('Error from updateAndRetry - Failed after Second Attamp - Do not try anymore',e1,e1.getMessage()); 
                        }
                    }
                    else {
                        Utilities.sendDebugEmail('Error from updateAndRetry (Not UNABLE_TO_LOCK_ROW error (Second attamp)) - ',e,e.getMessage()); 
                    }
                }
            }
            else {
                Utilities.sendDebugEmail('Error from updateAndRetry (Not UNABLE_TO_LOCK_ROW error (only first attamp))  - ',ex,ex.getMessage()); 
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

    public static Id partnerCompanyRecordTypeId {  
        get {  
            if (MARecordTypeId == null) {  
                MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();  
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

    public static Id personalTargetRT {  
        get {  
            if (personalTargetRT == null) {  
                personalTargetRT = Schema.SObjectType.Target__c.getRecordTypeInfosByDeveloperName().get('Personal_Target').getRecordTypeId();  
            }
            return personalTargetRT;  
        }  
        set;  
    }   

    public static Id rawSignupRecordTypeId {  
        get {  
            if (rawSignupRecordTypeId == null) {  
                rawSignupRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Raw_Signup').getRecordTypeId();  
            }
            return rawSignupRecordTypeId;  
        }  
        set;  
    }


    public static Id potentialPartnerLeadRecordTypeId {  
        get {  
            if (potentialPartnerLeadRecordTypeId == null) {  
                potentialPartnerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Potential_Partner').getRecordTypeId();  
            }
            return potentialPartnerLeadRecordTypeId;  
        }  
        set;  
    }


    public static Id internalOppRecordTypeId {  
        get {  
            if (internalOppRecordTypeId == null) {  
                internalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();  
            }
            return internalOppRecordTypeId;  
        }  
        set;  
    }

    public static Id partnerOppRecordTypeId {  
        get {  
            if (partnerOppRecordTypeId == null) {  
                partnerOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();  
            }
            return partnerOppRecordTypeId;  
        }  
        set;  
    }


    public static Id internalLeadRecordTypeId {  
        get {  
            if (internalLeadRecordTypeId == null) {  
                internalLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Internal_Lead').getRecordTypeId();  
            }
            return internalLeadRecordTypeId;  
        }  
        set;  
    }

    public static Id partnerLeadRecordTypeId {  
        get {  
            if (partnerLeadRecordTypeId == null) {  
                partnerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();  
            }
            return partnerLeadRecordTypeId;  
        }  
        set;  
    }

    public static Id preLeadRecordTypeId {  
        get {  
            if (preLeadRecordTypeId == null) {  
                preLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Pre_Lead').getRecordTypeId();  
            }
            return preLeadRecordTypeId;  
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

    public static Map<Id,User> activeUsersMap {  
        get {  
            if (activeUsersMap == null) {  
                activeUsersMap = new Map<Id,User>([SELECT Id FROM User WHERE IsActive = true]);
            }
            return activeUsersMap;  
        }  
        set;
    }

    public static String getCompanySizeRange(Integer numberOfEmployees) {
        if (numberOfEmployees >= 1 && numberOfEmployees <= 19) {
            return '1-19';
        }
        if (numberOfEmployees >= 20 && numberOfEmployees <= 49) {
            return '20-49';
        }
        if (numberOfEmployees >= 50 && numberOfEmployees <= 99) {
            return '50-99';
        }
        if (numberOfEmployees >= 100 && numberOfEmployees <= 250) {
            return '100-250';
        }
        if (numberOfEmployees >= 251 && numberOfEmployees <= 1500) {
            return '251-1500';
        }
        if (numberOfEmployees > 1500) {
            return '1500+';
        } 
        else {
            return null;
        }
    }
}