public with sharing class SendContractToBB {
    public SendContractToBB() {}
    @InvocableMethod
    public static list<Contract> sendContract(list<Contract> savedContract){
        try{
            String method='POST';
            Contract con=savedContract[0];
            Subscription__c sub= new Subscription__c(
                Seats__c=string.valueof(con.Seats__c),
                Migrated_Seats__c=con.Migrated_Seats__c,
                List_Price__c=con.List_Price__c,
                Unit_Price__c=con.Unit_Price__c,
                Discount__c=con.Discount__c,
                Activation_Date__c=con.StartDate,
                Deactivation_Date__c=con.EndDate,
                Paid_Months__c=con.Paid_Months__c,
                Free_Months__c=con.Free_Months__c,
                CurrencyIsoCode=con.CurrencyIsoCode,
                Pulse_Contract_Id__c=con.Pulse_Contract_Id__c,
                Pulse_Account_Id__c=con.Pulse_Account_Id__c
            );

            system.debug('Contract Sent to BB: '+sub);
            String serializedObject=JSON.serialize(sub);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
            String url = ConfigManager.BillingCycleEP(sub.Pulse_Account_Id__c);
            request.setEndpoint(url);
            request.setMethod(method);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Authorization', whMTD.Key__c);
            request.setBody(serializedObject);
            HttpResponse response=null;
            if (!Test.isRunningTest()){
                response = http.send(request); 
                system.debug('Raz Ben Ron response: '+response);   
            }
            String resBody='';
            if(response!=null)
                resBody=response.getBody();
            else
                resBody= '{"bb_contract_id":"131664","tier":"enterprise","seats":"50","list_price":"31.98","unit_price":"31.98","currency":"USD","discount":"0.0","paid_months":"12","free_months":"0","activation_date":"2020-05-22T00:00:00.000Z","deactivation_date":"2021-05-22T00:00:00.000+00:00"}';
        }catch(Exception e){
            Utilities.sendEmail('Error in SendContractToBB ',e.getMessage(),new list<String>{label.SystemNotificationsDL});   
        }
        return savedContract;
    }

}