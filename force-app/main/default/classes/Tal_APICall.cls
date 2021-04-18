public with sharing class Tal_APICall {
    @AuraEnabled
	public static String getInitialParameters(){
		String res = '';
		Map <String, object> mso = new Map <String, object>();
		mso.put('partnerFieldSet', getPartnerFieldSet());
		System.debug('### Tal:\n' + JSON.serializePretty(mso));
		res = JSON.serialize(mso);
		return res;
    }

    public static List <Map<String, Object>> getPartnerFieldSet(){
		System.debug('### Tal Test');
		List<String> ls = new List<String>();
		List <Map<String, Object>> lmss = new List <Map<String, Object>>();
		for(Schema.FieldSetMember f : SObjectType.Lead_Registration__c.FieldSets.Partner_DealRegistration_Form.getFields()) {
			Map<String, Object> tmp = new Map<String, Object>();
			tmp.put('name', f.getFieldPath());
			tmp.put('required', (f.getDbRequired() || f.getRequired()));
			lmss.add(tmp);
			ls.add(f.getFieldPath());
		}
		System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
		return lmss;
    }

    public static Boolean checkExistingAccount_BB(Map<String, Object> resultsMap){
        system.debug('### resultsMap: ' + resultsMap);
        Boolean bool = true;
        return bool;
    }

    @AuraEnabled
    public static void getSalesforceData(String email, String companySize, String companyWebsite) {
        Map<Id, Id> csVsAccount = new Map<Id, Id>();
        Map<Id, Id> conVsMondayAcc = new Map<Id, Id>();
        System.debug('### in_v3:' + email);
        String emailDomains = email.split('@').get(1);

        system.debug('### emailDomains: ' + emailDomains);
        List<Company_Domain__c> comDomainList = [SELECT Id, Name, Company__c, Domain__c FROM Company_Domain__c WHERE Domain__c =: emailDomains];
        system.debug('### comDomainList: ' + comDomainList);
        List<Contact> conList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE Email =: email];
        List<Lead> leadList = [SELECT Id, Name, Email FROM Lead WHERE Email =: email];
        system.debug('### conList: ' + conList);

        List<Lead_Registration__c> leadRedList = [SELECT Id, Name, Company_Size__c, CPM__c, OwnerId, Registered_Email__c, Lead_Registration_Partner__c FROM Lead_Registration__c WHERE Company_Website__c =: companyWebsite];
        if(conList.isEmpty() && leadList.isEmpty()){
            system.debug('### isEmpty');
            for(Lead_Registration__c lReg : leadRedList){
                lReg.Lead_Registration_Partner__c = true;
            }
        }

        //if User exist with Monday Account
        if(!conList.isEmpty()){
            for(Contact con : conList){
                conVsMondayAcc.put(con.Id, con.AccountId);
                system.debug('### conList: ' + conList);
            }
        }
        
        if(!conVsMondayAcc.isEmpty()){
            List<Account> mondayAccount = [SELECT Id, Name, Company_Size__c, OwnerId, Owner.Profile.Name, Monday_Account_Status__c, Company__c FROM Account WHERE Id IN: conVsMondayAcc.values()];
            system.debug('### mondayAccount: ' + mondayAccount);
            system.debug('### conVsMondayAcc.values(): ' + conVsMondayAcc.values());
            if(!mondayAccount.isEmpty()){
                for(Account acc : mondayAccount){
                    // if()
                    // Paying Account
                }    
            }
            
        }

        if(!comDomainList.isEmpty()){
            for(Company_Domain__c cd : comDomainList){
                system.debug('###contains: ' + emailDomains);
                csVsAccount.put(cd.Id, cd.Company__c);
                system.debug('### csVsAccount: ' + csVsAccount);
            }
        }

        if(!csVsAccount.isEmpty()){
            List<Account> companyAccount = [SELECT Id, Name, Company_Size__c FROM Account WHERE Id IN: csVsAccount.values()];
            List<Account> mondayAccount = [SELECT Id, Name, Company_Size__c, OwnerId, Owner.Profile.Name, Monday_Account_Status__c, Company__c
                                            FROM Account
                                            WHERE RecordType.DeveloperName = 'Monday_Account' AND Company__c IN: csVsAccount.values()];
            
            system.debug('### companyAccount: ' + companyAccount);
            system.debug('### mondayAccount: ' + mondayAccount);

        }
    }

    @AuraEnabled
    public static Boolean getCalloutResponseContents(String url, String email) {
        System.debug('### in_v3:' + url);
        String s = '{"query": "{users(emails:"' + email + '") {id, name, account{name, pulse_account_id, plan{id}}}}"}';
        // String payload = '{"parameters": [{ "Key":"Quote_Id", "Value":"' + QuoteId + '" }]}';
        system.debug('### payload: ' + s);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        //request.setHeader('Token-Type', 'Bearer Token');
        request.setHeader('Authorization', 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0aWQiOjExLCJhaWQiOjEzNjYsImlhZCI6IjIwMjEtMDEtMDMgMTM6MjM6MDMgVVRDIn0.6TgTmtvEX_y2HS-zw7JXc0CZRKXPJnUAtnvfuuIzzEk');
        // request.setBody('{"query": "{users(ids:18317520) {id, name, account{name, pulse_account_id, plan{id}}}}"}');
        request.setBody(s);
        HttpResponse response = http.send(request);
        // Parse the JSON response
		system.debug('### response.getStatusCode(): ' + response.getStatusCode());
        if (response.getStatusCode() == 201) {
            system.debug('### in');
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } 
        system.debug('### in2: '+response.getBody());
        
        Map<String, Object> resultsMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        // Map<String, Object> resultsMap_v1 = (Map<String, Object>)JSON.parse(response.getBody());
        System.debug('### deserializeUntyped' + resultsMap);
        // System.debug('### parse' + resultsMap_v1);

        Boolean check = checkExistingAccount_BB(resultsMap);
        return check;
    }
    
    public static HttpResponse makePostCallout() {
        String s = '{"query" : "{users(ids:18317520) {id}}"}';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://data.bigbrain.me/graphql/v1');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        //request.setHeader('Token-Type', 'Bearer Token');
        request.setHeader('Authorization', 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0aWQiOjExLCJhaWQiOjEzNjYsImlhZCI6IjIwMjEtMDEtMDMgMTM6MjM6MDMgVVRDIn0.6TgTmtvEX_y2HS-zw7JXc0CZRKXPJnUAtnvfuuIzzEk');
        request.setBody('{"query": "{users(ids:18317520) {id, name}}"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
		system.debug('### response.getStatusCode(): ' + response.getStatusCode());
        if (response.getStatusCode() == 201) {
            system.debug('### in');
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            system.debug('### in2: '+response.getBody());
            System.debug(response.getBody());
        }
        return response;
    }
/*
Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://data.bigbrain.me/graphql/v1');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody('{"emails":"talpa@monday.com"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
        return response;

        }*/
}