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
                    console.log('### storeResponse_v1: ' + storeResponse);
					if (storeResponse.hasOwnProperty('opportunity')){
                        component.set("v.oppData", storeResponse.opportunity);
                        console.log('### oppData: ' + component.get("v.oppData"));
                        console.log('### What_Would_You_Like_To_Claim__c: ' + storeResponse.opportunity.What_Would_You_Like_To_Claim__c);
                        console.log('### Close_Process_Path__c: ' + storeResponse.opportunity.Close_Process_Path__c);
                        console.log('### is SO init: ' + component.get('v.isPrioritySO'));
                        helper.checkHandover_InternalOpp(component, event, helper);
                        if(storeResponse.opportunity.Is_Primary_SO_Signed__c == true){
                            component.set('v.showWhatSigned', true);
                            component.set('v.innerPathValue', 'SO Information');
                            var innerValue = component.get('v.innerPathValue');
                        }

                        else{
                            console.log('^%^%^');
                            component.set('v.innerPathValue', 'Claim');
                        }
                    }
                    
					if (storeResponse.hasOwnProperty('subscription')) {
                        component.set('v.hasWonSO_SubClaimCC', storeResponse.subscription);
                    }
                    
                    console.log('### showWhatSigned: ' + component.get('v.showWhatSigned'));
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

    handleSuccessFieldSets : function(component, event, helper){
        console.log('### handleSuccessFieldSets: ');
        component.set('v.showValidation', false);
    },

    //Start - Save Field Sets to prevent validation
    handleSubmitValidation_SOWon : function(component, event, helper){
        console.log('### handleSubmitValidation_SOWon');
        
        event.preventDefault();
        component.find("validationSOFields").submit();
    },

    handleSubmitValidation_ClaimWon : function(component, event, helper){
        console.log('### handleSubmitValidation_ClaimWon');
        
        event.preventDefault();
        component.find("validationClaimFields").submit();
    },

    handleSubmitValidation_Lost : function(component, event, helper){
        console.log('### handleSubmitValidation_Lost');
        
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

    savePrioritySO : function(component, event, helper){
        var manualSign = event.getParam('value');
        component.set('v.isPrioritySO', manualSign);
        if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
            helper.saveManualFields(component, event, helper);
        }
    },

    saveManual : function(component, event, helper){
        console.log('### saveManual: ');
        if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
            helper.saveManualFields(component, event, helper);
        }
    },

    setClaim : function(component, event, helper){
        console.log('### setClaim' + event.getParam('value'));
        var claim = event.getParam('value');
        event.preventDefault();
        var fields = event.getParam();
        // component.find('closedWonFields').submit(fields);
        console.log('### what claim: ' + component.get('v.closedFields.What_Would_You_Like_To_Claim__c'));
        component.set("v.closedFields.What_Would_You_Like_To_Claim__c", claim);
        if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
            helper.saveManualFields(component, event, helper);
        }
    },

    handleStatusChange_OpportunityCloseSummary : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED" ){
            if(component.get('v.closedFields.StageName') == 'Closed Won'){
                console.log('### forceData won_v1: ' + component.get("v.closedFields.StageName"));
                component.set('v.confetti', true);
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Stage changed succesfully."                      
                });
            }

            else if(component.get('v.closedFields.StageName') == 'Closed Lost'){
                console.log('### forceData lost_v1: ' + component.get("v.closedFields.StageName"));
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Stage changed succesfully."                      
                });
            }

            if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                console.log('### Close_Process_Sys_Admin__c: ' + component.get('v.oppData.Close_Process_Sys_Admin__c'));
                component.set('v.closedFields.Close_Process_Path__c', 'Done');
                helper.savefields(component, event, helper);
                console.log('### done: ' + component.get('v.closedFields.Close_Process_Path__c'));
                
            }
            helper.updateProbability(component, event, helper);
            console.log('### before close');
            component.set('v.isModalOpen', false);
            
        }
    },
    
    handleSelect_TestPath : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        if(stepName != 'Closed' && stepName != 'Closed Won' && stepName != 'Closed Lost'){
            // component.set('v.hideUpdateButton', true);
            // component.set('v.showPrimaryPath', false);
        }

        else{
            component.set('v.hideUpdateButton_ClosedProcess', true);
        }
    },

    closeModal : function(component, event, helper) {
        console.log('### v.innerPathValue: ' + component.get('v.innerPathValue'));
        component.set("v.isModalOpen", false);
        window.location.reload()
    },

    handleSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        var oppId = component.get('v.recordId');

        if(stepName != 'Closed Lost' && stepName != 'Closed Won'){
            component.set('v.hideUpdateButton', false);
            component.set('v.hideUpdateButton_ClosedProcess', false)
        }

        if(stepName === 'Closed Lost'){
            component.set('v.isModalOpen', true);
            component.set('v.isClosedLost', true);
            component.set('v.innerPathValue', 'LostInfo');
            component.set('v.lostStage', 'Closed Lost');

            var fieldSetReferance;
            var isRetreiveFieldSet = false;
            if(component.get('v.oppData.StageName') != 'Qualified'){
                if(component.get('v.oppData.Type') != 'Expansion'){
                    if(component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity' && component.get('v.oppData.Is_Potential_GB_Opportunity__c')){
                        fieldSetReferance = "InternalOpportunity_Lost_NotExpansion";
                        isRetreiveFieldSet = true;
                        console.log('@@@ fieldSetReferance: ');
                    }
    
                    else if(component.get('v.oppData.RecordType.DeveloperName') == 'Partner_Opportunity'){
                        fieldSetReferance = "PartnerOpportunity_WonLost_NotExpansion";
                        isRetreiveFieldSet = true;
                        console.log('@@@ fieldSetReferance_v1: ');
                    }

                    if(isRetreiveFieldSet == true){
                        let action1 = component.get("c.getFieldsFromFieldSet");
                        action1.setParams({
                            objectName: "Opportunity",
                            fieldSetName: fieldSetReferance
                        });
                        action1.setCallback(this, function(response){
                            let state = response.getState();
                            if(state==="SUCCESS"){
                                let fieldsStr = response.getReturnValue();
                                console.log("fields => ",fieldsStr);
                                let fields = JSON.parse(fieldsStr);
                                component.set("v.fields", fields);
                            } else {
                                alert("error");
                            }
                        });
                        $A.enqueueAction(action1);
                    }

                    else if(isRetreiveFieldSet == false){
                        component.set('v.showValidation', false);
                    }
                }

                else{
                    component.set('v.showValidation', false);
                }
            }

            else{
                component.set('v.showValidation', false);
            }
        }
        
        else if(stepName === 'Closed Won'){
            var fieldSetReferance;
            var isRetreiveFieldSet;
            if(component.get('v.oppData.Type') != 'Expansion'){
                if(component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity' && component.get('v.oppData.Is_Potential_GB_Opportunity__c')){
                    fieldSetReferance = "InternalOpportunity_Won_NotExpansion";
                    isRetreiveFieldSet = true;
                    console.log('### fieldSetReferance: ');
                }

                else if(component.get('v.oppData.RecordType.DeveloperName') == 'Partner_Opportunity'){
                    fieldSetReferance = "PartnerOpportunity_WonLost_NotExpansion";
                    isRetreiveFieldSet = true;
                    console.log('### fieldSetReferance_v1: ');
                }
            }

            else if(component.get('v.oppData.Type') == 'Expansion' && component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity'){
                fieldSetReferance = "InternalOpportunity_Won_Expansion";
                isRetreiveFieldSet = true;
                console.log('### fieldSetReferance_v2: ');
            }
            console.log('### showValidation: ' + component.get('v.showValidation'));
            if(isRetreiveFieldSet == true){
                let action1 = component.get("c.getFieldsFromFieldSet");
                action1.setParams({
                    objectName: "Opportunity",
                    fieldSetName: fieldSetReferance
                });
                action1.setCallback(this, function(response){
                    let state = response.getState();
                    if(state==="SUCCESS"){
                        let fieldsStr = response.getReturnValue();
                        console.log("fields => ",fieldsStr);
                        let fields = JSON.parse(fieldsStr);
                        component.set("v.fields", fields);
                        console.log('### showValidation_v1: ' + component.get('v.showValidation'));
                    } else {
                        alert("error");
                    }
                });
                $A.enqueueAction(action1);
            }

            else{
                component.set('v.showValidation', false);
            }

            component.set('v.isModalOpen', true);
            component.set('v.isClosedWon', true);
            
            if(component.get('v.showWhatSigned')){ //if Is_Primary_SO_Signed__c = true -> don't show manual signed fields
                component.set('v.innerPathValue', 'SOInfo');
                var innerValue = 'SO Information';
                if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                    helper.setInnerPicklistPath(component, event, helper, innerValue);
                }
            }
    
            else{ //if Is_Primary_SO_Signed__c = false -> show manual signed fields
                console.log('### what: ' + component.get('v.innerPathValue'));
                if(component.get('v.innerPathValue') == 'Claim'){
                    console.log('### populate: ' + component.get('v.innerPathValue'));
                    var innerValue = component.get('v.innerPathValue');
                    if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                        helper.setInnerPicklistPath(component, event, helper, innerValue);
                    }
                }

                if(component.get('v.oppData.Close_Process_Path__c') == 'Claim'){
                    component.set('v.innerPathValue', 'Claim');
                }
                
                else if(component.get('v.oppData.Close_Process_Path__c') == 'SO Information'){
                    component.set('v.innerPathValue', 'SOInfo');
                }
        
                else if(component.get('v.oppData.Close_Process_Path__c') == 'Manual Signature'){
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
            }
        }
    },

    handleStatusChange_Handover : function (component, event, helper) {
        console.log('###  handover finish: ' + event.getParam("status"));
        if(event.getParam("status") === "FINISHED") {
            component.set("v.closedFields.StageName", 'Closed Won');
            
            if(component.get('v.oppData.Green_Bucket_ARR__c') >= 10000){
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
                            console.log("User is offline, device doesn't support drafts.");
                        }

                        else if(saveResult.state === "ERROR") {
                            for (var i = 0; i < saveResult.error.length; i++) {
                                errMsg += saveResult.error[i].message + "\n";
                            }
                            console.log('ERROR---'+errMsg)
                            component.set('v.recordSaveError', errMsg);
                            if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
                                console.log('### in notice');
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
                console.log('### innerPathValue_v3:' + component.get('v.innerPathValue'));
                var innerValue = "Done";
                helper.setInnerPicklistPath(component, event, helper, innerValue);
            }

            else{
                console.log('### in else_v3:' + component.get('v.oppData.Green_Bucket_ARR__c'));
                if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                    component.set('v.closedFields.Close_Process_Path__c', 'Done');
                    component.set('v.closedFields.StageName', 'Closed Won');
                    helper.savefields(component, event, helper);
                    helper.updateProbability(component, event, helper);
                }
            }
        }
    },

    previousStep : function (component, event, helper){
        event.preventDefault();
        helper.setPreviousStep(component, event, helper);
    },

    finishModal : function (component, event, helper){
        console.log('### finishModal');
        if(component.get('v.closedFields.StageName') == 'Closed Won'){
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
                console.log('### oppSummary_v3:' + component.get('v.innerPathValue'));
                helper.getOpportunitySummary(component, event, helper);
            }
        }

        if(component.get('v.isClosedWon')){
            if(component.get('v.innerPathValue') == 'Claim'){
                console.log('### tal: ' + component.get('v.innerPathValue'));
                // var claim_ClosedWon = component.find("newOpportunityClaimField");
                // var vaildation_ClosedWon = 'Please choose what would you like to claim.';
                // var vaildationBoolean_ClosedWon = false;

                // claim_ClosedWon.forEach(function (field) {
                //     if($A.util.isEmpty(field.get("v.value"))){
                //         vaildationBoolean_ClosedWon = true;
                //     }
                // });
    
                // if(vaildationBoolean_ClosedWon == true) { //if NOT all the fields are populated
                //     console.log('### tal_v2: ' + vaildation_ClosedWon);
                //     component.find('claimMessage').setError(vaildation_ClosedWon);
                // }

                // else{
                    console.log('### tal_v3: ' + component.get('v.closedFields.What_Would_You_Like_To_Claim__c'));
                    if(component.get('v.closedFields.What_Would_You_Like_To_Claim__c') == 'CC Payments'){
                        console.log('### tal_v4: ' + component.get('v.closedFields.What_Would_You_Like_To_Claim__c'));
                        component.set('v.innerPathValue', 'CCClaim');
                        console.log('### tal_v5: ' + component.get('v.innerPathValue'));

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
                // }
            }

            else if(component.get('v.innerPathValue') == 'ManualSignature'){ // manualy signed
                var fields_ClosedWon = component.find("newOpportunityField");
                var vaildation_ClosedWon = 'Please fill in all the required fields.';
                var vaildationBoolean_ClosedWon = false;

                fields_ClosedWon.forEach(function (field) {
                    if($A.util.isEmpty(field.get("v.value"))){
                        vaildationBoolean_ClosedWon = true;
                    }
                });
    
                if(vaildationBoolean_ClosedWon == true) { //if NOT all the fields are populated
                    component.find('oppMessage').setError(vaildation_ClosedWon);
                }

                else{
                    console.log('### closedFields.Manual_Signature_Reason__c: ' + component.get('v.closedFields.Manual_Signature_Reason__c'));
                    console.log('### isPrioritySO: ' + component.get('v.isPrioritySO'));
                    
                    if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                        component.set('v.closedFields.Is_SO_Signed__c', true);
                        console.log('### Is_SO_Signed__c: ' + component.get('v.closedFields.Is_SO_Signed__c'));
                        helper.saveManualFields(component, event, helper);
                    }
                    if(component.get('v.recordSaveError') == undefined || component.get('v.recordSaveError') == ""){
                        if(component.get('v.isPrioritySO') == 'Priority SO' || component.get('v.closedFields.Manual_Signature_Reason__c') == 'Priority SO'){
                            console.log('### in BBPicker');
                            component.set('v.innerPathValue', 'BBPickers');
                            
                            var innerValue = "BigBrain Pickers";
                            if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                                helper.setInnerPicklistPath(component, event, helper, innerValue);
                            }
                        }
        
                        else{
                            console.log('### else: ');
                            component.set('v.innerPathValue', 'CCClaim');
                            console.log('### else innerPathValue: ' + component.get('v.innerPathValue'));
                            if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                                console.log('### else Close_Process_Sys_Admin__c: ' + component.get('v.oppData.Close_Process_Sys_Admin__c'));
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
                    console.log('### in else:' + component.get('v.oppData.Green_Bucket_ARR__c'));
                    if(component.get('v.oppData.Green_Bucket_ARR__c') >= 10000){
                        console.log('### in else_v2:' + component.get('v.oppData.Green_Bucket_ARR__c'));
                        console.log('### oppSummary:' + component.get('v.innerPathValue'));
                        console.log('### see: ' + component.get('v.oppData.Close_Process_Sys_Admin__c'));
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
                                    console.log("User is offline, device doesn't support drafts.");
                                }

                                else if(saveResult.state === "ERROR") {
                                    for (var i = 0; i < saveResult.error.length; i++) {
                                        errMsg += saveResult.error[i].message + "\n";
                                    }
                                    console.log('ERROR---'+errMsg)
                                    component.set("v.recordSaveError", errMsg);
                                    
                                    if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
                                        console.log('### in notice');
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
                        console.log('### innerPathValue_v3:' + component.get('v.innerPathValue'));
                        var innerValue = "Done";
                        helper.setInnerPicklistPath(component, event, helper, innerValue);
                    }

                    else{
                        console.log('### in else_v3:' + component.get('v.oppData.Green_Bucket_ARR__c'));
                        component.set('v.showSpinner', true);
                        console.log('### showSpinner:' + component.get('v.showSpinner'));
                        console.log('### innerPathValue_v3:' + component.get('v.innerPathValue'));
                        if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                            component.set('v.closedFields.Close_Process_Path__c', 'Done');
                            component.set('v.closedFields.StageName', 'Closed Won');
                            helper.savefields(component, event, helper);
                            helper.updateProbability(component, event, helper);
                            // window.location.reload()
                        }
                    }
                }
            }

            else if(component.get('v.innerPathValue') == 'continueToSummary'){
                component.set('v.innerPathValue', 'OppSummary');
                console.log('### oppSummary_v3:' + component.get('v.innerPathValue'));
                var innerValue = "Done";
                helper.setInnerPicklistPath(component, event, helper, innerValue);
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
                console.log('### innerPathValue lost: ' + component.get('v.innerPathValue'));
                if(component.get('v.innerPathValue') != 'continueToSummary'){
                    if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                        component.set('v.showSpinner', true);
                        component.set('v.closedFields.StageName', 'Closed Lost');
                        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                            var errMsg = "";
                            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                if(component.get('v.oppData.Green_Bucket_ARR__c') >= 10000){
                                    component.set('v.showSpinner', false);
                                    console.log('### 111111_v12');
                                    helper.updateProbability(component, event, helper);
                                    component.set('v.innerPathValue', 'continueToSummary');
                                    var innerValue = "Done";
                                    helper.setInnerPicklistPath(component, event, helper, innerValue);
                                }
                                
                                else{
                                    console.log('### no GB');
                                    component.set('v.isModalOpen', false);
                                    component.set("v.closedFields.Close_Process_Path__c", 'Done');
                                    component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
                                        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                            console.log('### succes before bb');
                                            helper.updateProbability(component, event, helper);
                                        }
        
                                        else {
                                            console.log('### not succes before bb');
                                            console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                                        }
                                    }));
                                    helper.setStageUpdateToast(component, event, helper);
                                }
                            }

                            else if (saveResult.state === "INCOMPLETE") {
                                console.log("User is offline, device doesn't support drafts.");
                                // component.set("v.recordSaveError", errMsg);
                            }

                            else if(saveResult.state === "ERROR") {
                                for (var i = 0; i < saveResult.error.length; i++) {
                                    errMsg += saveResult.error[i].message + "\n";
                                }
                                console.log('ERROR---'+errMsg)
                                component.set("v.recordSaveError", errMsg);
                            }
                            
                            else {
                                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                                // component.set("v.recordSaveError", errMsg);
                            }

                            if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
                                console.log('### in notice');
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
    }
})