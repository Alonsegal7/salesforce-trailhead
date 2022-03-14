public without sharing class Opportunity_ClosingProcess {

    @AuraEnabled
	public static String getInitialParameters(Id oppId){
		String res = '';
		Map <String, object> mso = new Map <String, object>();
		mso.put('opportunity', getOpportunityData(oppId));
        mso.put('subscription', getSubscription(oppId));
        mso.put('internalOppLost_NotExpansion', InternalOpportunity_Lost_NotExpansion());
        mso.put('internalOppLWon_Expansion', InternalOpportunity_Won_Expansion());
        mso.put('internalOppLWon_NotExpansion', InternalOpportunity_Won_NotExpansion());
        mso.put('partnerOppLWonLost_Expansion', PartnerOpportunity_WonLost_NotExpansion());
        // mso.put('quote', getQuote(oppId));
		System.debug('iCloudius - Initial Parameters:\n' + JSON.serializePretty(mso));
		res = JSON.serialize(mso);
		return res;
    }

    @AuraEnabled
    public static Boolean checkCosellImpactSurveyFilled(Id coSellReqId){
        try {
            Co_Sell_Request__c rec = [select Id, Status__c, Impact_Survey_Filled__c from Co_Sell_Request__c where Id =: coSellReqId];
            return (rec.Status__c == 'Approved' && rec.Impact_Survey_Filled__c == false);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
	public static String getARRSum(Id oppId){
		String res = '';
		Map <String, object> mso = new Map <String, object>();
		mso.put('opportunityARR', getOpportunityARR(oppId));
        // mso.put('quote', getQuote(oppId));
		System.debug('iCloudius - Initial Parameters:\n' + JSON.serializePretty(mso));
		res = JSON.serialize(mso);
		return res;
    }
    
    @AuraEnabled
    public static Opportunity getOpportunityARR(Id recordId){
        system.debug('@@@ recordId_v3: ' + recordId);

        List<Opportunity> opp = [SELECT Id, Green_Bucket_ARR_V2__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
        system.debug('@@@ opp:_v2 ' + opp);
        
        return opp[0];
    }

    public static List <Map<String, Object>> InternalOpportunity_Lost_NotExpansion(){
		System.debug('### Tal Test');
		List<String> ls = new List<String>();
		List <Map<String, Object>> lmss = new List <Map<String, Object>>();
		for(Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.InternalOpportunity_Lost_NotExpansion.getFields()) {
            Map<String, Object> tmp = new Map<String, Object>();
			tmp.put('name', f.getFieldPath());
			tmp.put('required', (f.getDbRequired() || f.getRequired()));
			lmss.add(tmp);
			ls.add(f.getFieldPath());
		}
		System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
		return lmss;
    }

    public static List <Map<String, Object>> InternalOpportunity_Won_Expansion(){
		System.debug('### Tal Test');
		List<String> ls = new List<String>();
		List <Map<String, Object>> lmss = new List <Map<String, Object>>();
		for(Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.InternalOpportunity_Won_Expansion.getFields()) {
			Map<String, Object> tmp = new Map<String, Object>();
			tmp.put('name', f.getFieldPath());
			tmp.put('required', (f.getDbRequired() || f.getRequired()));
			lmss.add(tmp);
			ls.add(f.getFieldPath());
		}
		System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
		return lmss;
    }

    public static List <Map<String, Object>> InternalOpportunity_Won_NotExpansion(){
		System.debug('### Tal Test');
		List<String> ls = new List<String>();
		List <Map<String, Object>> lmss = new List <Map<String, Object>>();
		for(Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.InternalOpportunity_Won_NotExpansion.getFields()) {
			Map<String, Object> tmp = new Map<String, Object>();
			tmp.put('name', f.getFieldPath());
			tmp.put('required', (f.getDbRequired() || f.getRequired()));
			lmss.add(tmp);
			ls.add(f.getFieldPath());
		}
		System.debug('### Tal - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
		return lmss;
    }

    public static List <Map<String, Object>> PartnerOpportunity_WonLost_NotExpansion(){
		System.debug('### Tal Test');
		List<String> ls = new List<String>();
		List <Map<String, Object>> lmss = new List <Map<String, Object>>();
		for(Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.PartnerOpportunity_WonLost_NotExpansion.getFields()) {
            system.debug('### f.getRequired(): ' + f.getRequired());
            system.debug('### f.getFieldPath(): ' + f.getFieldPath());
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
    public static Opportunity getOpportunityData(Id recordId){
        system.debug('### recordId_v3: ' + recordId);

        List<Opportunity> opp = [SELECT Id, Manual_Signature_Reason__c, Should_be_handed_over_to_AM__c, Passed_AM_Threshold__c, Passed_CSM_Threshold__c, Passed_Onboarding_Threshold__c, Company_Employees__c, Green_Bucket_ARR_V2__c, RecordType.Name, Is_Primary_SO_Signed__c, AccountId, StageName,
                                        Total_PS_Hours__c, Total_PS_Expended_Hours__c , Expected_Plan_Seats__c, Expected_Plan_Tier__c, Account.CSM_Function__c, Close_Process_Path__c, Total_Training_Hours__c,
                                        SyncedQuoteId, SyncedQuote.DH_Tier__c, SyncedQuote.Total_Seats__c, SyncedQuote.DH_Period__c, Account.Name, SyncedQuote.OwnerId, SyncedQuote.Name, Handed_Over__c,
                                        SyncedQuote.Owner.Name, What_Would_You_Like_To_Claim__c, Is_SO_Signed__c, Close_Process_Sys_Admin__c, RecordType.DeveloperName, Type, Is_Potential_GB_Opportunity__c,
                                        Account.Co_Sell_Leader__c, Co_Sell_Opportunity__c, Main_Co_Sell_Opportunity__c, Co_Sell_Request__c, Co_Sell_Request__r.Status__c, Co_Sell_Request__r.Impact_Survey_Filled__c
                                FROM Opportunity WHERE Id =: recordId LIMIT 1];
        system.debug('### opp:_v2 ' + opp);
        
        return opp[0];
    }

    @AuraEnabled
    public static Boolean getSubscription(Id recordId){
        system.debug('### recordId: ' + recordId);
        Boolean isOppNull = false;
        Boolean hasWonSO_SubClaimCC = false;
        Map<Id, Subscription__c> subs;

        Opportunity opp = [SELECT Id, StageName, AccountId, Is_Primary_SO_Signed__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
            subs = new Map<Id, Subscription__c>([
                SELECT Id, Name, Seats__c, Product_Code__c, Name_for_CC_Claim__c, Claimed_On_Opportunity__r.Co_Sell_Opportunity__c,Is_Claimed__c
                FROM Subscription__c 
                WHERE Monday_Account__c =: opp.AccountId AND 
                (Is_Claimed__c = false OR (Claimed_On_Opportunity__r.Co_Sell_Opportunity__c =: opp.Id AND Claimed_On_Opportunity_Co_Sell__c = null)) 
                AND Status__c != 'DELETED' AND (Payment_Method__c LIKE '%BLUESNAP%' OR Include_In_CC_Claim__c = true)
                ORDER BY CreatedDate DESC
            ]);
        
        if(!subs.isEmpty()){
            system.debug('### subs: ' + subs);
            isOppNull = true;
        }

        else{
            system.debug('### opp null');
            isOppNull = false;
        }
        
        hasWonSO_SubClaimCC = isOppNull;
        system.debug('### hasWonSO_SubClaimCC: ' + hasWonSO_SubClaimCC);
        return hasWonSO_SubClaimCC;
    }

    @AuraEnabled
    public static Opportunity saveInnerPicklistPath(Id recordId, String innerPicklistPath){
        system.debug('### innerPicklistPath: ' + innerPicklistPath);
        Opportunity opp = [SELECT Id, Close_Process_Path__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
        system.debug('### opp9' + opp);
        opp.Close_Process_Path__c = innerPicklistPath;
        system.debug('### opp10' + opp);
        update opp;
        return opp;
    }

    @AuraEnabled
    public static Opportunity updateProbability(Id recordId, String oppStageName){
        Map<String, Decimal> stageMap = new Map<String, Decimal>();
        for(OpportunityStage oStage : [SELECT MasterLabel, DefaultProbability FROM OpportunityStage WHERE isActive = true AND MasterLabel =: oppStageName]){
            stageMap.put(oStage.MasterLabel, oStage.DefaultProbability);
        }
        
        Opportunity opp = [SELECT Name, StageName, Probability FROM Opportunity WHERE Id =: recordId];
                                        
        opp.Probability = stageMap.get(opp.StageName);
        update opp;
        return opp;
    }

    @AuraEnabled(Cacheable=true)
    public static String getFieldsFromFieldSet(String objectName, String fieldSetName){
        system.debug('### objectName: ' + objectName);
        system.debug('### fieldSetName: ' + fieldSetName);
        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(ObjectName).getDescribe();

        Schema.FieldSet fieldSet = sObjectDescribe.FieldSets.getMap().get(fieldSetName);

        System.debug('fields => '+fieldSet.getFields());
        return JSON.serialize(fieldSet.getFields()); 
    }

    @AuraEnabled
    public static void recalcHandoverThreshold(Id recordId){
        System.debug('Entered recalcHandoverThreshold');
        Opportunity updatedOpp = new Opportunity(Id = recordId, Manual_Trigger__c = 'Calculate HO Thresholds');
        update updatedOpp;
        // This was implemented with manual trigger so the call to the threshold calculation method will come from the trigger with all the relevant fields, rather than directrly from which will require maintanance of the fields being sent
    }

    @AuraEnabled
    public static void updateCompanySize(Id recordId){
        System.debug('Entered updateCompanySize');
        Opportunity oppRecord = [SELECT Id, Company__c, Company_Employees__c, Company_Size__c FROM Opportunity WHERE Id =:recordId];
        if (oppRecord.Company_Employees__c != oppRecord.Company_Size__c) {
            Account acc = [SELECT Id, NumberOfEmployees FROM Account WHERE Id =: oppRecord.Company__c];
            acc.NumberOfEmployees = Integer.valueOf(oppRecord.Company_Size__c);
            try {
                update acc;
            } catch (Exception e) {
                System.debug('Opportunity_ClosingProcess updateCompanySize Faild to update acc: ' + e.getMessage());
            }
        }
    }
}