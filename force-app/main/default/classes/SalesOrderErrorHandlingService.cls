public with sharing class SalesOrderErrorHandlingService {
    
    public static string CallBigBrainPreview(string quoteId,string pulseId){
        List<quote> quotesToUpdate = new List<quote>();
            Quote quote = [select id,BigBrain_Preview_API_Status__c,Error_Description__c from quote where id=: quoteid limit 1]; //when bb will work bulk - change to bulk
            string res = '';
            string status ='';
            quote.BigBrain_Preview_API_Status__c='Request Sent';//indicate the quote that the request was out for bb

            if (!Test.isRunningTest()) {
                res = BigBrainAPI.getSalesOrderPreview(pulseId,quoteId);
                system.debug('BigBrainFinalRes'+res);
                status = HandleOrderErrors(res,quoteId);
            }
            else{
                string fakeSystemError = '{"message":"Error Making Request"}';
                status=HandleOrderErrors(fakeSystemError,quoteId);

                string fakeRes = '{"valid":false,"validation_errors":["missing license period","not assigned to contract","no corresponding plan"],"validation_warnings":["account is not paying"],"arr":"4560.0","added_arr":"4560.0","list_price":"4560.0"}';
                status=HandleOrderErrors(fakeRes,quoteId);
            }

            if (status!='Valid' && status!='Invalid') {//bb returned general error (on the second attamp) - set status to system error
                quote.BigBrain_Preview_API_Status__c='System Error';
                quote.Error_Description__c=status;
            }
            else {
                quote.BigBrain_Preview_API_Status__c=status;//didn't get errors- will return valid/invalid
                quote.Error_Description__c=null;//for cases where the service first failed, then re-run and succeed - clean the error 
            }
            quotesToUpdate.add(quote);//add the service status to the quote

            if (!quotesToUpdate.isempty()) {
                try {
                    update quotesToUpdate;
                }      
                catch (Exception ex) {
                    if(ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW')){
                        try {
                            update quotesToUpdate;
                        }
                        catch (Exception e) {
                            System.debug('Message: ' + e.getMessage());
                        }
                    }
                    else {
                        System.debug('Message: ' + ex.getMessage());
                    }
                    return 'System Error';
                } 
            }
            return status;
    }

    public static string HandleOrderErrors(string request,id salesOrder){
        ResponseWrapper wrapedRes = ResponseWrapper.parse(request);//parse
        if (wrapedRes.message!=null && wrapedRes.message!='') {// erorr returned from server
            return wrapedRes.message;
        }
        else{
            if (wrapedRes.valid==false) {//bb returned error - handle and return status to quote level
                List<Order_Activation_Conflict__c> confilcts = handleOrderConflicts(wrapedRes,salesOrder);//handle
                if (!confilcts.isempty()) {//upsert
                    try {
                        upsert confilcts Key__c;
                    }      
                    catch (Exception ex) {
                        if(ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW')){
                            try {
                                upsert confilcts Key__c;
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
                return 'Invalid';
            }
            else {
                return 'Valid';
            }
        }
    }

    public static List<Order_Activation_Conflict__c> handleOrderConflicts(ResponseWrapper wrrapedErrors, id salesOrder){
        List<Order_Activation_Conflict__c> conflicts = new  List<Order_Activation_Conflict__c>();
        for (string validationError : wrrapedErrors.validation_errors) {
            Order_Activation_Conflict__c conflict = new Order_Activation_Conflict__c(
                Conflict_Description__c=validationError,
                Type__c='Error',
                Quote__c=salesOrder,
                Key__c=validationError+salesOrder
            );
            conflicts.add(conflict);
        }
        for (string validationWarning : wrrapedErrors.validation_warnings) {
            Order_Activation_Conflict__c conflict = new Order_Activation_Conflict__c(
                Conflict_Description__c=validationWarning,
                Type__c='Warning',
                Fix_Status__c='Not Required For Import',
                Quote__c=salesOrder,
                Key__c=validationWarning+salesOrder
            );
            conflicts.add(conflict);
        }
        return conflicts;
    }
    public class ResponseWrapper {
        public List<string> validation_errors {get;set;}
        public List<string> validation_warnings {get;set;}
        public string message {get;set;}
        public Boolean valid {get;set;}
    }

    public static ResponseWrapper parse(String json) {
        return (ResponseWrapper) System.JSON.deserialize(json, ResponseWrapper.class);
    }
}