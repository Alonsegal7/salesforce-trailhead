({
    doInit : function(component, event, helper){
		var oppId = component.get('v.recordId');
        var action = component.get("c.getInitialParameters");
        action.setParams({ "oppId" : oppId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse != null){
                    storeResponse = JSON.parse(storeResponse);
					if (storeResponse.hasOwnProperty('opportunity')){
                        component.set("v.oppData", storeResponse.opportunity);
                        console.log('init opp data: '+JSON.stringify(storeResponse.opportunity));
                        helper.checkHandover_InternalOpp(component, event, helper);
                        
                        if(storeResponse.opportunity.Is_Primary_SO_Signed__c == true){
                            component.set('v.showWhatSigned', true);
                            component.set('v.innerPathValue', 'SO Information');
                        }

                        else{
                            if(component.get('v.oppData.Close_Process_Path__c') != null && component.get('v.oppData.Close_Process_Path__c') != ''){
                                component.set('v.innerPathValue', component.get('v.oppData.Close_Process_Path__c'));
                            }

                            else{
                                component.set('v.innerPathValue', 'Claim');
                            }
                        }
                    }
                }  
            }

            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('Error init entered');
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message in Opportunity_ClosingProcess Controller: " + errors[0].message);
                    }
                }
                
                else {
                    console.log("Unknown error in Opportunity_ClosingProcess Controller:");
                }
            }
        });
        $A.enqueueAction(action);
    },

    checkboxSelect : function(component, event, helper) {
        component.set('v.selectCheckbox', event.getSource().get('v.value'));
    },

    onCheck: function(cmp, evt) {
        var checkCmp = cmp.find("checkbox");
        resultCmp = cmp.find("checkResult");
        resultCmp.set("v.value", ""+checkCmp.get("v.value"));

    },

    handleSuccessFieldSets : function(component, event, helper){
        component.set('v.showValidation', false);
        helper.updateCompanySize(component, event, helper);
    },

    //Start - Save Field Sets to prevent validation
    handleSubmitValidation_SOWon : function(component, event, helper){
        event.preventDefault();
        component.find("validationSOFields").submit();
    },

    handleSubmitValidation_ClaimWon : function(component, event, helper){
        event.preventDefault();
        component.find("validationClaimFields").submit();
    },

    handleSubmitValidation_Lost : function(component, event, helper){
        event.preventDefault();
        component.find("validationLostFields").submit();
        
    },
    //End - Save Field Sets to prevent validation

    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        var fileName = uploadedFiles[0].name;
        
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Files uploaded successfully!",
            "message": "File Name: " + fileName
        });

        // Get the file name
        uploadedFiles.forEach(file => console.log(file.name));
    },

    prioritySO : function(component, event, helper){
        var manualSign = event.getParam('value');
        component.set('v.isPrioritySO', manualSign);
    },

    saveManual : function(component, event, helper){
        if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
            helper.saveManualFields(component, event, helper);
        }
    },

    setClaim : function(component, event, helper){
        var claim = event.getParam('value');
        event.preventDefault();
        component.set("v.closedFields.What_Would_You_Like_To_Claim__c", claim);
        if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
            helper.saveManualFields(component, event, helper);
        }
    },

    handleStatusChange_OpportunityCloseSummary : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED" ){
            if(component.get('v.closedFields.StageName') == 'Closed Won'){
                component.set('v.confetti', true);
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Stage changed succesfully."                      
                });
            }

            else if(component.get('v.closedFields.StageName') == 'Closed Lost'){
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Stage changed succesfully."                      
                });
            }

            if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                component.set('v.closedFields.Close_Process_Path__c', 'Done');
                
            }
            if(component.get('v.wonCompletedSuccess') == true){
                helper.updateProbability(component, event, helper);
                component.set('v.isModalOpen', false);
            }
        }
    },
    
    handleSelect_TestPath : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        if(stepName != 'Closed' && stepName != 'Closed Won' && stepName != 'Closed Lost'){
        }

         else{
            component.set('v.hideUpdateButton_ClosedProcess', true);
        }
    },

    closeModal : function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    handleSelect : function (component, event, helper) {
        console.log('handleSelect');
        var stepName = event.getParam("detail").value;
        if(stepName == 'Closed Won'){
            //check for co-sell 2.0 survey
            if(component.get('v.oppData.Co_Sell_Opportunity__c') != null && component.get('v.oppData.Co_Sell_Opportunity__c') != ''
                && component.get('v.oppData.Main_Co_Sell_Opportunity__c') == true 
                && component.get('v.oppData.Co_Sell_Request__c') != null && component.get('v.oppData.Co_Sell_Request__c') != ''
                && component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c') == false){
                    helper.coSellSurvey(component, event, helper);
            } else {
                helper.handleClosedWon(component, event, helper);
            } 
        } else if(stepName === 'Closed Lost'){
            helper.handleClosedLost(component, event, helper);
        } else { //not closed won and not closed lost
            component.set('v.hideUpdateButton', false);
            component.set('v.hideUpdateButton_ClosedProcess', false)
        }
    },

    handleStatusChange_Handover : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.closedFields.StageName", 'Closed Won');
            
            if(component.get('v.oppData.Green_Bucket_ARR_V2__c') >= 10000){
                component.set('v.showSpinner', true);
                if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                    component.set('v.closedFields.StageName', 'Closed Won');
                    component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                        var errMsg = "";
                        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                            component.set('v.showSpinner', false);
                            helper.updateProbability(component, event, helper);
                        }

                        else if (saveResult.state === "INCOMPLETE") {
                        }

                        else if(saveResult.state === "ERROR") {
                            for (var i = 0; i < saveResult.error.length; i++) {
                                errMsg += saveResult.error[i].message + "\n";
                            }
                            
                            component.set('v.recordSaveError', errMsg);
                            if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
                                component.find('notifLib').showNotice({
                                    "variant": "error",
                                    "header": "Problem saving record:",
                                    "message": errMsg,
                                });
                            }
                        }
                        
                        else {
                            console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                        }
                    }));
                }
                component.set('v.innerPathValue', 'continueToSummary');
                var innerValue = "Done";
                helper.setInnerPicklistPath(component, event, helper, innerValue);
            }

            else{
                component.set('v.showSpinner', true);
                if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                    component.set('v.closedFields.Close_Process_Path__c', 'Done');
                    component.set('v.closedFields.StageName', 'Closed Won');
                    helper.savefields(component, event, helper);
                    helper.updateProbability(component, event, helper);
                    if(component.get('v.wonCompletedSuccess') == true){
                        if(component.get('v.checkARR') == true){
                            var oppId = component.get('v.recordId');
                            var action = component.get("c.getARRSum");
                            action.setParams({ "oppId" : oppId });
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var storeResponse = response.getReturnValue();
                                    if (storeResponse != null){
                                        storeResponse = JSON.parse(storeResponse);
                                        if (storeResponse.hasOwnProperty('opportunityARR')){
                                            if(storeResponse.opportunity.Green_Bucket_ARR_V2__c >= 10000){
                                                component.set('v.showSpinner', false);
                                                component.set('v.innerPathValue', 'continueToSummary');
                                            }
                    
                                            else{
                                                component.set('v.isModalOpen', false);
                                            }
                                        }
                                    }
                                }
                    
                                else if (state === "ERROR") {
                                    var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                            console.log("Error message in Opportunity_ClosingProcess Controller_v2: " + errors[0].message);
                                        }
                                    }
                                    
                                    else {
                                        console.log("Unknown error in Opportunity_ClosingProcess Controller_v1:");
                                    }
                                }
                            });
                            $A.enqueueAction(action)
                        }
                    }
                }
            }
        }
    },

    previousStep : function (component, event, helper){
        event.preventDefault();
        helper.setPreviousStep(component, event, helper);
    },

    finishModal : function (component, event, helper){
        if(component.get('v.closedFields.StageName') == 'Closed Won'){
            helper.updateProbability(component, event, helper);
            component.set('v.confetti', true);
        }
        component.set('v.isModalOpen', false);
        helper.setStageUpdateToast(component, event, helper);
        window.location.reload()
    },

    submitDetails : function(component, event, helper) {
        event.preventDefault();
        var oppId = component.get('v.recordId');
        if(component.get('v.isClosedLost')){
            if(component.get('v.innerPathValue') == 'continueToSummary'){
                component.set('v.innerPathValue', 'OppSummary');
                helper.getOpportunitySummary(component, event, helper);
            }
        }

        if(component.get('v.isClosedWon')){
            if(component.get('v.innerPathValue') == 'Claim'){
                if(component.get('v.closedFields.What_Would_You_Like_To_Claim__c') == 'CC Payments'){
                    component.set('v.innerPathValue', 'CCClaim');

                    if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                        var innerValue = "CC Claim";
                        helper.setInnerPicklistPath(component, event, helper, innerValue);
                    }
                }

                else{
                    component.set('v.innerPathValue', 'ManualSignature');
                    if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                        helper.setInnerPicklistPath(component, event, helper, 'Manual Signature');
                    }
                }
            }

            else if(component.get('v.innerPathValue') == 'ManualSignature'){ // manualy signed
                var fields_ClosedWon = component.find("newOpportunityField");
                var vaildation_ClosedWon = 'Please fill in all the required fields.';
                var vaildationBoolean_ClosedWon = false;

                fields_ClosedWon.forEach(function (field) {
                    if(component.get('v.oppData.Is_SO_Signed__c') == true){
                        component.set('v.selectCheckbox', true);
                    }
                    if($A.util.isEmpty(field.get("v.value")) || component.get('v.selectCheckbox') == false){
                        vaildationBoolean_ClosedWon = true;
                    }
                });
    
                if(vaildationBoolean_ClosedWon == true) { //if NOT all the fields are populated
                    component.find('oppMessage').setError(vaildation_ClosedWon);
                }

                else{
                    component.set('v.showSpinner', true);
                    if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                        helper.saveManualFields(component, event, helper);
                    }
                    if(component.get('v.recordSaveError') == undefined || component.get('v.recordSaveError') == ""){
                        if(component.get('v.isPrioritySO') == 'Priority SO' || component.get('v.closedFields.Manual_Signature_Reason__c') == 'Priority SO'){
                            component.set('v.innerPathValue', 'BBPickers');
                            
                            var innerValue = "BigBrain Pickers";
                            if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                                helper.setInnerPicklistPath(component, event, helper, innerValue);
                            }
                        }
        
                        else{
                            component.set('v.innerPathValue', 'CCClaim');
                            if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                                var innerValue = "CC Claim";
                                helper.setInnerPicklistPath(component, event, helper, innerValue);
                            }
                        }
                    }
                }
            }

            else if(component.get('v.innerPathValue') == 'BBPickers'){ // manualy signed
                component.set('v.innerPathValue', 'CCClaim');
                if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                    var innerValue = "CC Claim";
                    helper.setInnerPicklistPath(component, event, helper, innerValue);
                }
            }

            else if(component.get('v.innerPathValue') == 'CCClaim'){ // manualy signed
                if(component.get('v.showHandover') == true){
                    component.set('v.innerPathValue', 'Handover');

                    helper.getHandover(component, event, helper);
                }

                else{
                    if(component.get('v.oppData.Green_Bucket_ARR_V2__c') >= 10000){
                        if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                            component.set('v.showSpinner', true);
                            component.set('v.closedFields.StageName', 'Closed Won');
                            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                                var errMsg = "";
                                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                    component.set('v.showSpinner', false);
                                    helper.updateProbability(component, event, helper);
                                }

                                else if (saveResult.state === "INCOMPLETE") {
                                }

                                else if(saveResult.state === "ERROR") {
                                    for (var i = 0; i < saveResult.error.length; i++) {
                                        errMsg += saveResult.error[i].message + "\n";
                                    }
                                    component.set("v.recordSaveError", errMsg);
                                    
                                    if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
                                        component.find('notifLib').showNotice({
                                            "variant": "error",
                                            "header": "Problem saving record:",
                                            "message": errMsg,
                                            closeCallback: function() {
                                                component.set('v.innerPathValue', 'CCClaim');
                                                component.set('v.showSpinner', false);
                                                component.set("v.recordSaveError", '');
                                                var innerValue = "CC Claim";
                                                helper.setInnerPicklistPath(component, event, helper, innerValue);
                                            }
                                        });
                                    }
                                }

                                else {
                                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                                }
                            }));
                        }
                        component.set('v.innerPathValue', 'continueToSummary');
                        var innerValue = "Done";
                        helper.setInnerPicklistPath(component, event, helper, innerValue);
                    }

                    else{
                        component.set('v.showSpinner', true);
                        if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                            component.set('v.closedFields.Close_Process_Path__c', 'Done');
                            component.set('v.closedFields.StageName', 'Closed Won');
                            helper.savefields(component, event, helper);
                            helper.updateProbability(component, event, helper);
                            if(component.get('v.wonCompletedSuccess') == true){
                                if(component.get('v.checkARR') == true){
                                    var oppId = component.get('v.recordId');
                                    var action = component.get("c.getARRSum");
                                    action.setParams({ "oppId" : oppId });
                                    action.setCallback(this, function(response) {
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            var storeResponse = response.getReturnValue();
                                            if (storeResponse != null){
                                                storeResponse = JSON.parse(storeResponse);
                                                if (storeResponse.hasOwnProperty('opportunityARR')){
                                                    if(storeResponse.opportunityARR.Green_Bucket_ARR_V2__c >= 10000){
                                                        component.set('v.innerPathValue', 'continueToSummary');
                                                    }
                            
                                                    else{
                                                        component.set('v.isModalOpen', false);
                                                    }
                                                }
                                            }
                                        }
                            
                                        else if (state === "ERROR") {
                                            var errors = response.getError();
                                            if (errors) {
                                                if (errors[0] && errors[0].message) {
                                                    console.log("Error message in Opportunity_ClosingProcess Controller_v3: " + errors[0].message);
                                                }
                                            }
                                            
                                            else {
                                                console.log("Unknown error in Opportunity_ClosingProcess Controller_v2:");
                                            }
                                        }
                                    });
                                    $A.enqueueAction(action)
                                }
                            }
                        }
                    }
                }
            }

            else if(component.get('v.innerPathValue') == 'continueToSummary'){
                component.set('v.innerPathValue', 'OppSummary');
                helper.getOpportunitySummary(component, event, helper);
            }

            else if(component.get('v.innerPathValue') == 'SOInfo'){ // manualy signed
                component.set('v.closedFields.StageName', 'Closed Won');
                component.set('v.innerPathValue', 'CCClaim');
                if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                    var innerValue = "CC Claim";
                    helper.setInnerPicklistPath(component, event, helper, innerValue);
                }
            }
        }
        
        if(component.get('v.isClosedLost') == true){
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

            if(showValidationError_ClosedLost == true) { //if NOT all the fields are populated
                vaildationFailReason_ClosedLost += '* Why Closed Lost? \n * Which Tool? \n * Which features are missing?';
                component.find('lostMessage').setError(vaildationFailReason_ClosedLost);
            }

            else if(showValidationError_WhichTool == true) { //if NOT all the fields are populated
                vaildationFailReason_ClosedLost += '* Which Tool?';
                component.find('lostMessage').setError(vaildationFailReason_ClosedLost);
            }

            else if(showValidationError_WhichFeature == true) { //if NOT all the fields are populated
                vaildationFailReason_ClosedLost += '* Which features are missing?';
                component.find('lostMessage').setError(vaildationFailReason_ClosedLost);
            }

            else{
                if(component.get('v.innerPathValue') != 'continueToSummary'){
                    component.set('v.innerPathValue', 'continueToSummary');
                    if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                        component.set('v.showSpinner', true);
                        component.set('v.closedFields.StageName', 'Closed Lost');
                        component.set("v.closedFields.Close_Process_Path__c", 'Done');
                        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                            var errMsg = "";
                            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                component.set("v.closedFields.Close_Process_Path__c", 'Done');
                                component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                        component.set('v.showSpinner', false);
                                        component.set('v.innerPathValue', 'continueToSummary');
                                        helper.updateProbability(component, event, helper);
                                    }
                                }));
                            }

                            else if (saveResult.state === "INCOMPLETE") {
                            }

                            else if(saveResult.state === "ERROR") {
                                for (var i = 0; i < saveResult.error.length; i++) {
                                    errMsg += saveResult.error[i].message + "\n";
                                }
                                component.set("v.recordSaveError", errMsg);
                            }
                            
                            else {
                                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                            }

                            if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
                                component.find('notifLib').showNotice({
                                    "variant": "error",
                                    "header": "Problem saving record:",
                                    "message": errMsg,
                                });
                            }
                        }));
                    }
                }
            }
        }
    },

    recordUpdated : function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ 
        }
        else if (changeType === "LOADED") { /* handle record load */ 
        }
        else if (changeType === "REMOVED") { /* handle record removal */ 
        }
        else if (changeType === "CHANGED") { /* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */ 
          component.find("recordEditor").reloadRecord();}
        }
})