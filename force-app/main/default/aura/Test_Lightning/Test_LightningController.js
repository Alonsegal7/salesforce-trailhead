({
    doInit : function(component, event, helper){
		var oppId = component.get('v.recordId');
        var action = component.get("c.getInitialParameters");
        action.setParams({ "oppId" : oppId });
        action.setCallback(this, function(response) {
            console.log('### callback');
            var state = response.getState();
            console.log('### state' + state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse != null){
                    storeResponse = JSON.parse(storeResponse);
					if (storeResponse.hasOwnProperty('opportunity')){
                        component.set("v.oppData", storeResponse.opportunity);
                        console.log('### oppData: ' + component.get("v.oppData"));
                        console.log('### What_Would_You_Like_To_Claim__c: ' + storeResponse.opportunity.What_Would_You_Like_To_Claim__c);
                        console.log('### is SO init: ' + component.get('v.isPrioritySO'));
                        helper.checkHandover_InternalOpp(component, event, helper);
                        if(storeResponse.opportunity.Is_Primary_SO_Signed__c == true){
                            component.set('v.showWhatSigned', true);
                        }

                        else{
                            console.log('^%^%^');
                            component.set('v.innerPathValue', 'Claim');
                        }
                    }
                    
					if (storeResponse.hasOwnProperty('subscription')) {
                        component.set('v.hasWonSO_SubClaimCC', storeResponse.subscription);
                    }
                    console.log('### hasWonSO_SubClaimCC: ' + component.get('v.hasWonSO_SubClaimCC'));
                    console.log('### showWhatSigned: ' + component.get('v.showWhatSigned'));
                    // console.log('check quote: ' + comppnent.get('v.quoteUserId'));
                }
                
                else{
                    
                }   
            }

            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
                
                else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    savePrioritySO : function(component, event, helper){
        var manualSign = event.getParam('value');
        component.set('v.isPrioritySO', manualSign);
    },

    setClaim : function(component, event, helper){
        var claim = event.getParam('value');
        component.set('v.claimPath', claim);
        console.log('### claim: ' + component.get('v.claimPath'));
        component.set("v.closedFields.StageName", 'Closed Won');
        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log('### succes before bb');
            }

            else {
                console.log('### not succes before bb');
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            }
        }));
        console.log('### forceData won: ' + component.get("v.closedFields.StageName"));
        console.log('### forceData: ' + component.get("v.closedFields.What_Would_You_Like_To_Claim__c"));
        console.log('### claim field: ' + component.get('v.oppData.What_Would_You_Like_To_Claim__c'));

        if(component.get('v.claimPath') == 'Sales Order ARR + CC Payments' || component.get('v.claimPath') == 'Sales Order ARR'){
            var innerValueVar = 'ManualSignature';
            var innerValuePath = 'Manual Signature';
            component.set('v.innerPathValue', innerValueVar);
            helper.setInnerPicklistPath(component, event, helper, innerValuePath);
        }

        else if(component.get('v.claimPath') == 'CC Payments'){
            var innerValueVar = 'CCClaim';
            var innerValuePath = 'CC Claim';
            component.set('v.innerPathValue', innerValueVar);
            helper.setInnerPicklistPath(component, event, helper, innerValuePath);
        }
    },

    handleStatusChange_OpportunityCloseSummary : function (component, event) {
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED" ){
            if(component.get('v.closedFields.StageName') == 'Closed Won'){
                console.log('### forceData won_v1: ' + component.get("v.closedFields.StageName"));
                console.log('### forceData won_v2: ' + component.get("v.oppData.StageName"));
                component.set('v.confetti', true);
                console.log('### show toast');
                // var resultsToast = $A.get("e.force:showToast");
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Stage changed succesfully."                      
                });
                $A.get('e.force:refreshView').fire();
            }

            component.set("v.closedFields.Close_Process_Path__c", 'Done');
            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    console.log('### succes before bb');
                }

                else {
                    console.log('### not succes before bb');
                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                }
            }));
            
            component.set('v.isModalOpen', false);
            
        }
        // helper.setStageUpdateToast(component, event, helper);
    },

    handleClick : function(component, event, helper){
        if(component.get('v.oppData.Close_Process_Path__c') == 'Claim'){
            component.set('v.innerPathValue', 'ManualSignature');
        }

        if(component.get('v.oppData.Close_Process_Path__c') == 'Manual Signature'){
            component.set('v.innerPathValue', 'ManualSignature');
        }

        else if(component.get('v.oppData.Close_Process_Path__c') == 'BigBrain Pickers'){
            component.set('v.innerPathValue', 'BBPickers');
        }

        else if(component.get('v.oppData.Close_Process_Path__c') == 'CC Claim'){
            component.set('v.innerPathValue', 'CCClaim');
        }

        else if(component.get('v.oppData.Close_Process_Path__c') == 'Handover'){
            component.set('v.innerPathValue', 'Handover');
        }

        else if(component.get('v.oppData.Close_Process_Path__c') == 'Opportunity Summary'){
            component.set('v.innerPathValue', 'OppSummary');
        }

        else if(component.get('v.oppData.Close_Process_Path__c') == 'Lost Information'){
            component.set('v.innerPathValue', 'LostInfo');
        }
        
        component.set('v.isModalOpen', true);
        component.set('v.isClosedWon', true);
    },
    
    handleSelect_TestPath : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        if(stepName != 'Closed' && stepName != 'Closed Won' && stepName != 'Closed Lost'){
            // component.set('v.hideUpdateButton', true);
            component.set('v.showPrimaryPath', false);
        }

        else{
            component.set('v.hideUpdateButton_ClosedProcess', true);
            component.set('v.showPrimaryPath', false);
        }
    },

    closeModal : function(component, event, helper) {
        console.log('### v.innerPathValue: ' + component.get('v.innerPathValue'));
        component.set("v.isModalOpen", false);
    },

    handleSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        var oppId = component.get('v.recordId');
        component.set('v.chooseStage', stepName);

        if(stepName !== 'Closed Lost' && stepName !== 'Closed Won'){
            component.set('v.hideUpdateButton', false);
            component.set('v.showPrimaryPath', true);
            component.set('v.hideUpdateButton_ClosedProcess', false)
        }

        if(stepName === 'Closed Lost'){
            component.set('v.isModalOpen', true);
            component.set('v.isClosedLost', true);
            component.set('v.stage_ClosedLost', 'Closed Lost');
            component.set('v.innerPathValue', 'LostInfo');
        }
        
        else if(stepName === 'Closed Won'){
            component.set('v.isModalOpen', true);
            component.set('v.isClosedWon', true);
            component.set('v.stage_ClosedWon', 'Closed Won');
            
            if(component.get('v.showWhatSigned')){ //if Is_Primary_SO_Signed__c = true -> don't show manual signed fields
                component.set('v.innerPathValue', 'SOInfo');
                var action = component.get("c.fetchUserDetail");
                action.setParams({ "quoteUserId" : component.get('v.quoteUserId')});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var res = response.getReturnValue();
                        component.set('v.quoteUser', res);
                    }
                    else if (state === "INCOMPLETE") {
                        console.log('### in INCOMPLETE');
                    }

                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +  errors[0].message);
                            }
                        }
                        
                        else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
    
            else{ //if Is_Primary_SO_Signed__c = false -> show manual signed fields
                console.log('### what: ' + component.get('v.innerPathValue'));
                if(component.get('v.innerPathValue') == 'Claim'){
                    console.log('### populate: ' + component.get('v.innerPathValue'));
                    var innerValue = component.get('v.innerPathValue');
                    helper.setInnerPicklistPath(component, event, helper, innerValue);
                }
            }
        }
    },

    handleStatusChange_Handover : function (component, event) {
        console.log('###  handover finish: ' + event.getParam("status"));
        if(event.getParam("status") === "FINISHED") {
            component.set('v.showHandoverFlow', false);
            component.set('v.isOpen', false);
            component.set("v.closedFields.StageName", 'Closed Won');

            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                console.log('### in save: ' + component.get('v.closedFields.StageName'));
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    if(component.get('v.oppData.Green_Bucket_ARR__c') >= 10000){
                        component.set("v.oppData.StageName", 'Closed Won');
                        component.set('v.GBarr10K', true);
                        component.set('v.innerPathValue', 'OppSummary');
                        var flow = component.find("closedOppSumFlowData");
                        var inputVariables = [{
                            name : "CurrOppID",
                            type : "String",
                            value : component.get("v.recordId")}
                        ];
                        flow.startFlow("Closed_Won_Opportunity_Summary", inputVariables);
                    }
                    
                    else{
                        console.log('### in save_v1: ' + component.get('v.closedFields.StageName'));
                        component.set('v.confetti', true);
                        component.set('v.isModalOpen', false);
                        component.set("v.closedFields.Close_Process_Path__c", 'Done');
                        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                console.log('### succes before bb');
                            }

                            else {
                                console.log('### not succes before bb');
                                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                            }
                        }));
                    }
                    helper.setStageUpdateToast(component, event, helper);
                }

                else {
                    console.log('Not Success Save');
                }
            }));
        }
    },

    previousStep : function (component, event, helper){
        event.preventDefault();
        helper.setPreviousStep(component, event, helper);
    },

    submitDetails : function(component, event, helper) {
        event.preventDefault();
        var oppId = component.get('v.recordId');
        if(component.get('v.isClosedWon')){
            if(component.get('v.innerPathValue') == 'Claim'){
                component.set("v.closedFields.StageName", 'Closed Won');
                component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        console.log('### succes before bb');
                    }

                    else {
                        console.log('### not succes before bb');
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                    }
                }));

                if(component.get('v.closedFields.What_Would_You_Like_To_Claim__c') == 'CC Payments'){
                    component.set('v.showCCClaim', true);
                    component.set('v.innerPathValue', 'CCClaim');
                    helper.getCCClaim(component, event, helper);
                }

                else{
                    component.set('v.showCCClaim', true);
                    component.set('v.innerPathValue', 'ManualSignature');
                    hhelper.setInnerPicklistPath(component, event, helper, innerValuePath);
                }
            }

            else if(component.get('v.innerPathValue') == 'ManualSignature'){ // manualy signed
                var showValidationError = false;
                var fields = component.find("newOpportunityField");
                var vaildationFailReason = 'Please fill in all the required fields: ';
                var isClosedWon = false;
                var updateStageName = 'Please update the Stage to be: Closed Won';
                
                fields.forEach(function (field) {
                    if(field.get("v.fieldName") == 'StageName' && field.get("v.value") != 'Closed Won'){
                        console.log('## check won:' + field.get("v.value"));
                        isClosedWon = true;
                    }

                    if($A.util.isEmpty(field.get("v.value"))){
                        showValidationError = true;
                    }
                });
                
                if (!showValidationError && !isClosedWon) { //if all the fields are populated
                    component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                            console.log('### succes before bb');
                        }

                        else {
                            console.log('### not succes before bb');
                            console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        }
                    }));
                    if(component.get('v.isPrioritySO') == 'Priority SO' || (component.get('v.isPrioritySO') == '' && component.get('v.oppData.Manual_Signature_Reason__c') == 'Priority SO')){
                        component.set('v.innerPathValue', 'BBPickers');
                        
                        var innerValue = "BigBrain Pickers";
                        helper.setInnerPicklistPath(component, event, helper, innerValue);
                    }
    
                    else{
                        component.set('v.showCCClaim', true);
                        component.set('v.innerPathValue', 'CCClaim');
                        helper.getCCClaim(component, event, helper);
                    }
                }
                else { //if NOT all the fields are populated
                    if(isClosedWon == true){
                        console.log('## isClosedWon: ' + isClosedWon);
                        component.find('oppMessage').setError(updateStageName);
                    }

                    if(showValidationError == true){
                        vaildationFailReason += '* Date of Signature \n * Signer Name \n * Signer Title \n * Manual Signature Reason';
                        component.find('oppMessage').setError(vaildationFailReason);
                    }
                }
            }

            else if(component.get('v.innerPathValue') == 'BBPickers'){ // manualy signed
                component.set('v.showCCClaim', true);
                component.set('v.innerPathValue', 'CCClaim');
                helper.getCCClaim(component, event, helper);
            }

            else if(component.get('v.innerPathValue') == 'CCClaim'){ // manualy signed
                if(component.get('v.showHandover') == true){
                    component.set('v.innerPathValue', 'Handover');
                    helper.getHandover(component, event, helper);
                }

                else{
                    if(component.get('v.oppData.Green_Bucket_ARR__c') >= 10000){
                        component.set("v.oppData.StageName", 'Closed Won');
                        component.set('v.GBarr10K', true);
                        component.set('v.innerPathValue', 'OppSummary');
                        helper.getOpportunitySummary(component, event, helper);
                    }

                    else{
                        component.set('v.confetti', true);
                        component.set('v.isModalOpen', false);
                        component.set("v.closedFields.Close_Process_Path__c", 'Done');
                        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                console.log('### succes before bb');
                            }

                            else {
                                console.log('### not succes before bb');
                                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                            }
                        }));
                        helper.setStageUpdateToast(component, event, helper);
                    }
                }
            }

            else if(component.get('v.innerPathValue') == 'SOInfo'){ // manualy signed
                component.set("v.closedFields.StageName", 'Closed Won');
                component.find("recordEditor").saveRecord($A.getCallback(function(saveResult){
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT"){
                        console.log('### success');
                    }
                    
                    else{
                        console.log('### error: ');
                    }
                }));
                component.set('v.showCCClaim', true);
                component.set('v.innerPathValue', 'CCClaim');
                helper.getCCClaim(component, event, helper);
            }
        }
        
        if(component.get('v.isClosedLost') == true){
            console.log('### is lost: ' + component.get('v.isClosedLost'));
            var showValidationError_ClosedLost = false;
            var showValidationError_WhichTool = false;
            var showValidationError_WhichFeature = false;
            var fields_ClosedLost = component.find("ClosedLostFieldCheck");
            var vaildationFailReason_ClosedLost = 'Please fill in all the required fields: ';
            var lostReason_WhichTool = false;
            var lostReason_WhichFeature = false;

            fields_ClosedLost.forEach(function (field) {
                if(field.get("v.fieldName") == 'Lost_Reason__c' && (field.get("v.value") == 'Sticking with internal tool' || field.get("v.value") == 'Lost to Competitor')){
                    lostReason_WhichTool = true;
                }

                if(field.get("v.fieldName") == 'Lost_Reason__c' && field.get("v.value") == 'Missing features'){
                    lostReason_WhichFeature = true;
                }
                
                if($A.util.isEmpty(field.get("v.value"))){
                    if(field.get("v.fieldName") == 'Lost_Reason__c'){//&& lostReason == true
                        showValidationError_ClosedLost = true;
                    }

                    if(field.get("v.fieldName") == 'Which_competitor__c' && lostReason_WhichTool){//&& lostReason == true
                        showValidationError_WhichTool = true;
                    }

                    if(field.get("v.fieldName") == 'Which_features_were_missing__c' && lostReason_WhichFeature){//&& lostReason == true
                        showValidationError_WhichFeature = true;
                    }
                }
            });

            if(showValidationError_ClosedLost === true) { //if NOT all the fields are populated
                vaildationFailReason_ClosedLost += '* Why Closed Lost? \n * Which Tool? \n * Which features are missing?';
                component.find('lostMessage').setError(vaildationFailReason_ClosedLost);
            }

            else if(showValidationError_WhichTool === true) { //if NOT all the fields are populated
                vaildationFailReason_ClosedLost += '* Which Tool?';
                component.find('lostMessage').setError(vaildationFailReason_ClosedLost);
            }

            else if(showValidationError_WhichFeature === true) { //if NOT all the fields are populated
                vaildationFailReason_ClosedLost += '* Which features are missing?';
                component.find('lostMessage').setError(vaildationFailReason_ClosedLost);
            }

            else{
                // component.find("closedLostFields").submit();
                console.log('### check lost: ' + component.get('v.stage_ClosedLost'));
                component.set('v.closedFields.StageName', 'Closed Lost');
                component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        if(component.get('v.oppData.Green_Bucket_ARR__c') >= 10000){
                            console.log('### 111111_v12');
                            // component.set("v.oppData.StageName", 'Closed Lost');
                            component.set('v.GBarr10K', true);
                            component.set('v.innerPathValue', 'OppSummary');
                            helper.getOpportunitySummary(component, event, helper);
                        }
                        
                        else{
                            console.log('### no GB');
                            component.set('v.isModalOpen', false);
                            component.set("v.closedFields.Close_Process_Path__c", 'Done');
                            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                    console.log('### succes before bb');
                                }

                                else {
                                    console.log('### not succes before bb');
                                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                                }
                            }));
                            helper.setStageUpdateToast(component, event, helper);
                        }
                    }

                    else {
                        console.log('### FAILED' + saveResult.state);
                        var errors = "";
                        for (var i = 0; saveResult.error.length > i; i++){
                            errors = errors + saveResult.error[i].message;
                        }            
                        console.log('### errors: ' + errors);
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type":"error",
                            "title": "Error!",
                            "message": errors                        
                        });
                        resultsToast.fire();
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                    }
                        
                }));
            }
        }
    }
})