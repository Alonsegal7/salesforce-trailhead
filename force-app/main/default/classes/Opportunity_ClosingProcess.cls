public without sharing class Opportunity_ClosingProcess {

    @AuraEnabled
	public static String getInitialParameters(Id oppId){
        try{
            String res = '';
            Map <String, object> mso = new Map <String, object>();
            updateCompSize_opp(oppId);
            mso.put('opportunity', getOpportunityData(oppId));
            System.debug('Opportunity_ClosingProcess - Initial Parameters:\n' + JSON.serializePretty(mso));
            res = JSON.serialize(mso);
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string closedStageSelected(Id oppId){
        try {
            String res = '';
            Map <String, object> mso = new Map <String, object>();
            updateCompSize_opp(oppId);
            Opportunity opp = getOpportunityData(oppId);
            mso.put('opportunity', opp);
            String fieldsStr = getFieldSet(opp);
            mso.put('fieldsStr', fieldsStr);
            System.debug('Opportunity_ClosingProcess - closedStageSelected:\n' + JSON.serializePretty(mso));
            res = JSON.serialize(mso);
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getFieldSet(Opportunity opp){
        String oppType = opp.Type == 'Renewal' ? 'Renewal' : opp.Opportunity_Type__c;
        String fs_name = '';
        if(opp.RecordType.DeveloperName == 'Internal_Opportunity' && opp.Is_Potential_GB_Opportunity__c){
            if(oppType == 'New Business') fs_name = 'CloseProcess_RequiredFields_NewBusiness';
            else if(oppType == 'Expansion'){
                if(opp.Green_Bucket_ARR_V2__c >= 5000) fs_name = 'CloseProcess_RequiredFields_Exp_above5K';
                else fs_name = 'CloseProcess_RequiredFields_Exp_under5K';
            }
        }
        if(fs_name != '') return getFieldsFromFieldSet('Opportunity', fs_name);
        else return null;
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
    public static Opportunity getOpportunityData(Id recordId){
        try{
            system.debug('### recordId_v3: ' + recordId);
            List<Opportunity> opp = [SELECT Id, Manual_Signature_Reason__c, Should_be_handed_over_to_AM__c, Passed_AM_Threshold__c, Passed_CSM_Threshold__c, Passed_Onboarding_Threshold__c, Company_Employees__c, Green_Bucket_ARR_V2__c, RecordType.Name, Is_Primary_SO_Signed__c, AccountId, StageName,
                                            Total_PS_Hours__c, Account.CSM__c, Total_PS_Expended_Hours__c , Onboarding_Hours__c, Expected_Plan_Seats__c, Expected_Plan_Tier__c, Account.CSM_Function__c, Close_Process_Path__c, Total_Training_Hours__c,
                                            SyncedQuoteId, SyncedQuote.DH_Tier__c, SyncedQuote.Total_Seats__c, SyncedQuote.DH_Period__c, Account.Name, SyncedQuote.OwnerId, SyncedQuote.Name, Handed_Over__c,
                                            SyncedQuote.Owner.Name, What_Would_You_Like_To_Claim__c, Is_SO_Signed__c, Close_Process_Sys_Admin__c, RecordType.DeveloperName, Type, Opportunity_Type__c, Is_Potential_GB_Opportunity__c,
                                            Account.Co_Sell_Leader__c, Co_Sell_Opportunity__c, Main_Co_Sell_Opportunity__c, Co_Sell_Request__c, Co_Sell_Request__r.Status__c, Co_Sell_Request__r.Impact_Survey_Filled__c
                                    FROM Opportunity WHERE Id =: recordId LIMIT 1];
            system.debug('### opp:_v2 ' + opp);
            return opp[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Opportunity saveInnerPicklistPath(Id recordId, String innerPicklistPath){
        try{
            Opportunity opp = new Opportunity(Id = recordId, Close_Process_Path__c = innerPicklistPath);
            update opp;
            return opp;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String closeOpp(Id recordId, String oppStageName){
        try {
            String res = '';
            Map<String, Decimal> stageMap = new Map<String, Decimal>();
            for(OpportunityStage oStage : [SELECT MasterLabel, DefaultProbability FROM OpportunityStage WHERE isActive = true AND MasterLabel =: oppStageName]){
                stageMap.put(oStage.MasterLabel, oStage.DefaultProbability);
            }
            if(oppStageName == 'Closed Won') updateCompSize_account(recordId);
            Opportunity opp = new Opportunity(Id = recordId); 
            opp.StageName = oppStageName;
            opp.Close_Process_Path__c = 'Done';
            opp.Probability = stageMap.get(oppStageName);
            update opp;
            opp = getOpportunityData(recordId);
            Map <String, object> mso = new Map <String, object>();
            mso.put('opportunityARR', opp); //for old cmp - remove after pilot is done
            mso.put('opportunity', opp);
            res = JSON.serialize(mso);
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled(Cacheable=true)
    public static String getFieldsFromFieldSet(String objectName, String fieldSetName){
        try{
            Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
            Schema.FieldSet fieldSet = sObjectDescribe.FieldSets.getMap().get(fieldSetName);
            return JSON.serialize(fieldSet.getFields()); 
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void updateCompSize_opp(Id recordId){
        Opportunity oppRecord = [SELECT Id, Company__c, Company_Employees__c, Company_Size__c FROM Opportunity WHERE Id =:recordId];
        if (oppRecord.Company_Employees__c != oppRecord.Company_Size__c) {
            Opportunity opp = new Opportunity(
                Id = recordId,
                Company_Size__c = Integer.valueOf(oppRecord.Company_Employees__c)
            );
            update opp;
        }
    }

    public static void updateCompSize_account(Id recordId){
        Opportunity oppRecord = [SELECT Id, Company__c, Company_Employees__c, Company_Size__c FROM Opportunity WHERE Id =:recordId];
        if (oppRecord.Company_Employees__c != oppRecord.Company_Size__c) {
            Account acc = [SELECT Id, NumberOfEmployees FROM Account WHERE Id =: oppRecord.Company__c];
            acc.NumberOfEmployees = Integer.valueOf(oppRecord.Company_Size__c);
            System.debug('updating comp size to '+ acc.NumberOfEmployees);
            update acc;
        }
    }

    @AuraEnabled
    public static String handover_updateCompSizeRecalcTH(Id recordId){ //for old cmp - remove after pilot is done
        /* 
        this method is called after submit form of field set fields for close won
        opp.Company_Employees__c is updated by the form 
        then we check if Company_Employees__c is not equal to Company_Size__c (formula)
        if so - we update the NumberOfEmployees of the company (opp.Company__c) to be equal to opp.Company_Size__c
        then we query the HO thresholds and return them to aura

        NOTE: if we remove this method we loose the update of the company (!)
        */
        try {
            String res = '';
            System.debug('Entered handover_updateCompSizeRecalcTH');
            System.debug('checking if comp size update required...');
            Opportunity oppRecord = [SELECT Id, Company__c, Company_Employees__c, Company_Size__c FROM Opportunity WHERE Id =:recordId];
            if (oppRecord.Company_Employees__c != oppRecord.Company_Size__c) {
                Account acc = [SELECT Id, NumberOfEmployees FROM Account WHERE Id =: oppRecord.Company__c];
                acc.NumberOfEmployees = Integer.valueOf(oppRecord.Company_Size__c);
                System.debug('updating comp size to '+ acc.NumberOfEmployees);
                update acc;
            }
            System.debug('Going to recalc HO THs');
            Opportunity updatedOpp = new Opportunity(Id = recordId, Manual_Trigger__c = 'Calculate HO Thresholds'); //This was implemented with manual trigger so the call to the threshold calculation method 
                                                                                                                    //will come from the trigger with all the relevant fields, rather than directrly from which will 
                                                                                                                    //require maintanance of the fields being sent
            update updatedOpp;
            updatedOpp = [select Id, Passed_AM_Threshold__c, Passed_CSM_Threshold__c, Passed_Onboarding_Threshold__c from Opportunity where Id =: recordId];
            Map <String, object> mso = new Map <String, object>();
		    mso.put('opportunityHO', updatedOpp);
            System.debug('Exiting handover_updateCompSizeRecalcTH');
            res = JSON.serialize(mso);
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}