public with sharing class ExistingContractValidation {
    public static boolean IsSandbox = [Select IsSandbox from Organization].IsSandbox;
    public ExistingContractValidation() {
    }
    @InvocableMethod
    public static list<Contract> getContract(list<Id> oppIdFromFlow){
        list<Contract> contractResult= new list<Contract>();
        try{
            Opportunity currentOpp=[select id,primary_pulse_account_id__c,AccountId,Company__c,
                                    Account.primary_pulse_account_id__c
                                    from Opportunity where id=:oppIdFromFlow];
            System.Debug('Raz Ben Ron ECV currentOpp: '+currentOpp);
            String method='GET';
            //String serializedObject=JSON.serialize(currentOpp);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            Webhook_Key__mdt whMTD = [select id,Key__c from Webhook_Key__mdt where DeveloperName='Big_Brain'][0];
            String url = ConfigManager.BillingCycleEP(currentOpp.Account.primary_pulse_account_id__c);
            system.debug('Raz Ben Ron ECV api url: '+url);
            request.setEndpoint(url);
            request.setMethod(method);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Authorization', whMTD.Key__c);
            //request.setBody(serializedObject);
            HttpResponse response=null;
            String resBody='';
            if (!Test.isRunningTest()){
                //REAL CONNECTION
                //if(!IsSandbox){
                    response = http.send(request); 
                    system.debug('Raz Ben Ron response: '+response); 
                    system.debug('Raz Ben Ron response: '+response.getBody()); 
                    resBody=response.getBody();
                //}else{
                    //SIMULATE FULL FESPONSE:
                    //resBody= '{"bb_contract_id":"131664","tier":"enterprise","seats":"50","list_price":"31.98","unit_price":"31.98","currency":"USD","discount":"0.0","paid_months":"12","free_months":"0","activation_date":"2020-05-22T00:00:00.000Z","deactivation_date":"2021-05-22T00:00:00.000+00:00","pricing_version":"8"}';   
                //}
                //SIMULATE NULL FESPONSE:
                //resbody=null;
            }else{
                resBody= '{"bb_contract_id":"131664","tier":"enterprise","seats":"50","list_price":"31.98","unit_price":"31.98","currency":"USD","discount":"0.0","paid_months":"12","free_months":"0","activation_date":"2020-05-22T00:00:00.000Z","deactivation_date":"2021-05-22T00:00:00.000+00:00","pricing_version":"8"}';
            }
            Map<String, Object> responseMap = new Map<String, Object>();
            Contract contracttoValidate;
            system.debug('resBody: '+resBody);
            if(resBody!=null){
                responseMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
                system.debug('Raz Ben Ron responseMap'+responseMap);
                Date startDate = date.valueOf(string.valueof(responseMap.get('activation_date')).replace('T',' ').replace('Z', ''));
                Date endDate = date.valueOf(string.valueof(responseMap.get('deactivation_date')).replace('T',' ').replace('Z', ''));
                //String tierLowerCase=string.valueof(responseMap.get('tier'));
                //String tier=tierLowerCase.subString(0,1).toUpperCase()+tierLowerCase.subString(1,tierLowerCase.length());
                String tier=Utilities.capitalizeString(string.valueof(responseMap.get('tier')));
                //String period=Utilities.capitalizeString(string.valueof(responseMap.get('period')));
                contracttoValidate= new contract (Name=string.valueof(responseMap.get('bb_contract_id')),
                                                            Pulse_Contract_Id__c=string.valueof(responseMap.get('bb_contract_id')),
                                                            /*Tier__c=string.valueof(responseMap.get('tier')),*/
                                                            Tier__c=tier,
                                                            Seats__c=integer.valueof(responseMap.get('seats')),
                                                            StartDate=startDate,
                                                            EndDate=endDate,
                                                            Period__c=String.valueof(responseMap.get('period')),
                                                            List_Price__c=double.valueof(responseMap.get('list_price')),
                                                            Unit_Price__c=double.valueof(responseMap.get('unit_price')),
                                                            CurrencyIsoCode=string.valueof(responseMap.get('currency')),
                                                            Paid_Months__c=integer.valueof(responseMap.get('paid_months')),
                                                            Free_Months__c=integer.valueof(responseMap.get('free_months')),
                                                            Exchange_Rate__c=integer.valueof(responseMap.get('exchange_rate')),
                                                            Pricing_Version__c=integer.valueof(responseMap.get('pricing_version')),
                                                            AccountId=currentOpp.Company__c,
                                                            Pulse_Account_Id__c=currentOpp.Account.primary_pulse_account_id__c);
            }
            contractResult.add(contracttoValidate);
            system.debug('Raz Ben Ron contractResult'+contractResult);
        }catch(Exception e){
            Utilities.sendEmail('Error in ExistingContractValidation ',e.getMessage(),new list<String>{label.SystemNotificationsDL});   
        }
        return contractResult;
    }

}