public with sharing class DealRegistration_Controller {
    @AuraEnabled
    public static String getInitialParameters(){
        String res = '';
        Map <String, object> mso = new Map <String, object>();
        mso.put('hasPermissionToForm', hasPermissionToForm());
        mso.put('companyDetailsFieldSet', getCompanyDetailsFieldSetFieldSet());
        mso.put('contactDetailsFieldSet', getContactDetailsFieldSetFieldSet());
        mso.put('opportunityInformationFieldSet', getOpportunityInformationFieldSetFieldSet());
        mso.put('opportunityQualificationFieldSet', getOpportunityQualificationFieldSetFieldSet());
        mso.put('eventDetailsFieldSet', getEventDetailsFieldSetFieldSetFieldSet());
        System.debug('### Tal:\n' + JSON.serializePretty(mso));
        res = JSON.serialize(mso);
        return res;
    }

    public static Boolean hasPermissionToForm(){
        system.debug('### in hasPermissionToForm');
        try{
            String userId = UserInfo.getUserId();
            system.debug('### userId: ' + userId);
            User u = [SELECT Id, Name, Show_Deal_Reg_Form__c FROM User WHERE Id =: userId LIMIT 1];
            system.debug('### u: ' + u);
            return u.Show_Deal_Reg_Form__c;
        }catch(Exception e){
            system.debug('### in catch: ');
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    public static List <Map<String, Object>> getCompanyDetailsFieldSetFieldSet(){
        System.debug('### Tal Test');
        List<String> ls = new List<String>();
        List <Map<String, Object>> lmss = new List <Map<String, Object>>();
        for(Schema.FieldSetMember f : SObjectType.Deal_Registration__c.FieldSets.CompanyDetails.getFields()) {
            Map<String, Object> tmp = new Map<String, Object>();
            tmp.put('name', f.getFieldPath());
            tmp.put('required', (f.getDbRequired() || f.getRequired()));
            lmss.add(tmp);
            ls.add(f.getFieldPath());
        }
        System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
        return lmss;
    }

    public static List <Map<String, Object>> getContactDetailsFieldSetFieldSet(){
        System.debug('### Tal Test');
        List<String> ls = new List<String>();
        List <Map<String, Object>> lmss = new List <Map<String, Object>>();
        for(Schema.FieldSetMember f : SObjectType.Deal_Registration__c.FieldSets.ContactDetails.getFields()) {
            Map<String, Object> tmp = new Map<String, Object>();
            tmp.put('name', f.getFieldPath());
            tmp.put('required', (f.getDbRequired() || f.getRequired()));
            lmss.add(tmp);
            ls.add(f.getFieldPath());
        }
        System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
        return lmss;
    }

    public static List <Map<String, Object>> getOpportunityInformationFieldSetFieldSet(){
        System.debug('### Tal Test');
        List<String> ls = new List<String>();
        List <Map<String, Object>> lmss = new List <Map<String, Object>>();
        for(Schema.FieldSetMember f : SObjectType.Deal_Registration__c.FieldSets.OpportunityInformation.getFields()) {
            Map<String, Object> tmp = new Map<String, Object>();
            tmp.put('name', f.getFieldPath());
            tmp.put('required', (f.getDbRequired() || f.getRequired()));
            lmss.add(tmp);
            ls.add(f.getFieldPath());
        }
        System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
        return lmss;
    }

    public static List <Map<String, Object>> getOpportunityQualificationFieldSetFieldSet(){
        System.debug('### Tal Test');
        List<String> ls = new List<String>();
        List <Map<String, Object>> lmss = new List <Map<String, Object>>();
        for(Schema.FieldSetMember f : SObjectType.Deal_Registration__c.FieldSets.OpportunityQualification.getFields()) {
            Map<String, Object> tmp = new Map<String, Object>();
            tmp.put('name', f.getFieldPath());
            tmp.put('required', (f.getDbRequired() || f.getRequired()));
            lmss.add(tmp);
            ls.add(f.getFieldPath());
        }
        System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
        return lmss;
    }

    @AuraEnabled
    public static Deal_Registration__c updateDealRegistration(Id recordId){
        system.debug('### updateDealRegistration');
        Deal_Registration__c dealReg = [SELECT Id, Related_Opportunity__c, Status__c FROM Deal_Registration__c WHERE Id =: recordId LIMIT 1];
        system.debug('### dealReg: ' + dealReg);
        return dealReg;
    }

    @AuraEnabled
    public static Profile getProfileInfo(){
        system.debug('### in getProfileInfo');
        try{
            String profileId = UserInfo.getProfileId();
            system.debug('### profileId: ' + profileId);
            Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: profileId];
            system.debug('### profile: ' + profile);
            return profile;
        }catch(Exception e){
            system.debug('### in catch: ');
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    @AuraEnabled
    public static Boolean runningInASandbox(){
        Boolean runningInASandbox = false;
        system.debug('### in runningInASandbox');
        try{
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            system.debug('### runningInASandbox: ' + runningInASandbox);
            return runningInASandbox;
        }catch(Exception e){
            system.debug('### in catch: ');
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    public static List <Map<String, Object>> getEventDetailsFieldSetFieldSetFieldSet(){
        System.debug('### in getEventDetailsFieldSetFieldSetFieldSet');
        List<String> ls = new List<String>();
        List <Map<String, Object>> lmss = new List <Map<String, Object>>();
        for(Schema.FieldSetMember f : SObjectType.Deal_Registration__c.FieldSets.EventDetails.getFields()) {
            Map<String, Object> tmp = new Map<String, Object>();
            tmp.put('name', f.getFieldPath());
            tmp.put('required', (f.getDbRequired() || f.getRequired()));
            lmss.add(tmp);
            ls.add(f.getFieldPath());
        }
        System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
        return lmss;
    }
}