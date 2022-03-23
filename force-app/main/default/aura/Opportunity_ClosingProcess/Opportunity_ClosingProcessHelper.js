({
	// start of refactored callback methods
	callbackInit : function(component, event, helper) {   
		console.log('opp close proc: entered callbackInit');
		component.set("v.showSpinner", true);
        var action = component.get("c.getInitialParameters");
        action.setParams({ 
			oppId: component.get('v.recordId') 
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
				console.log('opp close proc: callbackInit SUCCESS');
                var storeResponse = response.getReturnValue();
				if (storeResponse != null){
                    storeResponse = JSON.parse(storeResponse);
					if (storeResponse.hasOwnProperty('opportunity')){
                        component.set("v.oppData", storeResponse.opportunity);
                        console.log('opp close proc: init opp data: '+ JSON.stringify(storeResponse.opportunity));
                        helper.checkHandover_InternalOpp(component, event, helper);
                        helper.checkIfPrimarySoSigned(component, event, helper);
                    }
                }  else {
					errMsg = 'Oops... Server issue loading opportunity data (storeResponse is null in callbackInit). Please reach out to Biz Ops.';
					component.set("v.errMsg", errMsg);
				}
            } else {
				console.log('opp close proc: callbackInit ERROR');
				let err = response.getError();
				helper.callbackErrorHander(component, event, helper, err);
            }
			component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },

	callback_saveInnerPicklistPath : function(component, event, helper, innerValue){
		console.log('opp close proc: entered callback_saveInnerPicklistPath');
		if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
			if(innerValue != 'Handover') component.set("v.showSpinner", true);
			var action = component.get("c.saveInnerPicklistPath");
			action.setParams({ 
				recordId : component.get('v.recordId'),
				innerPicklistPath : innerValue
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state == "SUCCESS") {
					var storeResponse = response.getReturnValue();
					console.log('opp close proc: callback_saveInnerPicklistPath save inner path successfully! value: ' + storeResponse.Close_Process_Path__c);
				} else {
					console.log('opp close proc: entered callback_saveInnerPicklistPath ERROR');
					let err = response.getError();
					helper.callbackErrorHander(component, event, helper, err);
				}
				component.set("v.showSpinner", false);
			});
			$A.enqueueAction(action);
		}
	},

	callback_handover_updateCompSizeRecalcTH : function(component, event, helper){
		console.log('opp close proc: entered callback_handover_updateCompSizeRecalcTH');
		var updateSizeAction = component.get("c.handover_updateCompSizeRecalcTH");
		component.set("v.showSpinner", true);
		updateSizeAction.setParams({
			recordId: component.get("v.recordId")
		});
		updateSizeAction.setCallback(this, function(response){
			var state = response.getState();
			if (state == "SUCCESS") {
				console.log('opp close proc: entered callback_handover_updateCompSizeRecalcTH SUCCESS');
				var storeResponse = response.getReturnValue();
				if (storeResponse != null){
					storeResponse = JSON.parse(storeResponse);
					if (storeResponse.hasOwnProperty('opportunityHO')){
						component.set('v.oppData.Passed_AM_Threshold__c', storeResponse.opportunityHO.Passed_AM_Threshold__c);
						component.set('v.oppData.Passed_CSM_Threshold__c', storeResponse.opportunityHO.Passed_CSM_Threshold__c);
						component.set('v.oppData.Passed_Onboarding_Threshold__c', storeResponse.opportunityHO.Passed_Onboarding_Threshold__c);
						helper.checkHandover_InternalOpp(component, event, helper);
					} else {
						component.set("v.errMsg", "Error occured in callback_handover_updateCompSizeRecalcTH (storeResponse has not property called opportunityHO). Please reach out to Biz Ops.");
					}
				} else {
					component.set("v.errMsg", "Error occured in callback_handover_updateCompSizeRecalcTH (storeResponse is null). Please reach out to Biz Ops.");
				}
			} else {
				console.log('opp close proc: entered callback_handover_updateCompSizeRecalcTH ERROR');
				let err = response.getError();
				helper.callbackErrorHander(component, event, helper, err);
			}
			component.set("v.showSpinner", false);
		});
		$A.enqueueAction(updateSizeAction);
	},

	callback_coSellSurvey : function (component, event, helper){
		console.log('opp close proc: callback_coSellSurvey');
		component.set("v.showSpinner", true);
		var action = component.get("c.getOpportunityData");
		action.setParams({ 
			recordId: component.get('v.recordId') 
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == "SUCCESS") {
				console.log('opp close proc: callback_coSellSurvey SUCCESS');
				var storeResponse = response.getReturnValue();
				console.log('opp close proc: response.getReturnValue: '+JSON.stringify(response.getReturnValue()));
				if (storeResponse != null){
					component.set("v.oppData", storeResponse);
					console.log('opp close proc: init opp data: '+JSON.stringify(storeResponse));
					console.log('opp close proc: survey filled: '+component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c'));
					if(component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c') == false){
						component.set('v.hideUpdateButton', false);
						component.set('v.hideStagePathUpdateBtn', false);
						component.find('notifLib').showToast({
							"variant": "error",
							"title": "You must fill the Co-Sell Impact Survey before closing the opportunity."                      
						});
					} else {
						helper.handleClosedWonStageSelected(component, event, helper);
					}
				}
			} else {
				console.log('opp close proc: callback_coSellSurvey state=ERROR');
				let err = response.getError();
				helper.callbackErrorHander(component, event, helper, err);
			}
			component.set("v.showSpinner", false);
		});
		$A.enqueueAction(action);
	},

	showConfettiClosedWon : function(component, event, helper){
		component.set('v.confetti', true);
		component.find('notifLib').showToast({
			"variant": "success",
			"title": "Opportunity stage changed succesfully to Closed Won!"                      
		});
		component.set('v.wonCompletedSuccess', true);
	},

	callback_saveManualFields : function(component, event, helper){
		if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
			console.log('opp close proc: entered callback_saveManualFields');
			component.set('v.showSpinner', true);
			component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
				if (saveResult.state == "SUCCESS" || saveResult.state == "DRAFT") {
					console.log('opp close proc: callback_saveManualFields SUCCESS');
					if(component.get('v.innerPathValue') == 'ManualSignature' 
						&& (component.get('v.recordSaveError') == undefined || component.get('v.recordSaveError') == "")){
                        if(component.get('v.isPrioritySO') == 'Priority SO' || component.get('v.closedFields.Manual_Signature_Reason__c') == 'Priority SO'){
                            component.set('v.innerPathValue', 'BBPickers');
                            helper.callback_saveInnerPicklistPath(component, event, helper, "BigBrain Pickers");
                        }else{
                            component.set('v.innerPathValue', 'CCClaim');
                            helper.callback_saveInnerPicklistPath(component, event, helper, "CC Claim");
                        }
                    }
				} else if(saveResult.state == "ERROR") {
					console.log('opp close proc: callback_saveManualFields state=ERROR');
					console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
					component.set("v.errMsg", JSON.stringify(saveResult.error));
				}
				component.set('v.showSpinner', false);
			}));
		}
	},

	callback_closeOpp : function(component, event, helper, stageToUpdate){
		console.log('opp close proc: entered callback_closeOpp');
		if(component.get('v.innerPathValue') != 'Handover') component.set("v.showSpinner", true);
		var action = component.get("c.closeOpp");
		action.setParams({ 
			recordId: component.get('v.recordId'),
			oppStageName: stageToUpdate
	 	});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == "SUCCESS") {
				console.log('opp close proc: callback_closeOpp SUCCESS');
				var storeResponse = response.getReturnValue();
				if (storeResponse != null){
					storeResponse = JSON.parse(storeResponse);
					if (storeResponse.hasOwnProperty('opportunityARR')){
						component.set('v.greenBucketData', storeResponse.opportunityARR);
						console.log('opp close proc: callback_closeOpp result ARR: '+ storeResponse.opportunityARR.Green_Bucket_ARR_V2__c);
						if(component.get('v.isClosedWon')) helper.showConfettiClosedWon(component, event, helper);
						else if(component.get('v.isClosedLost')){
							component.find('notifLib').showToast({
								"variant": "success",
								"title": "Opportunity stage changed succesfully to Closed Lost!"                      
							});
						}
						if(storeResponse.opportunityARR.Green_Bucket_ARR_V2__c >= 10000){
							console.log('opp close proc: callback_closeOpp continueToSummary');
							component.set('v.innerPathValue', 'continueToSummary');
						}else{
							console.log('opp close proc: callback_closeOpp close modal');
							helper.endProcess(component, event, helper);
						}
					}
				}
			} else {
				console.log('opp close proc: callback_closeOpp state=ERROR');
				let err = response.getError();
				helper.callbackErrorHander(component, event, helper, err);
			}
			component.set("v.showSpinner", false);
		});
		$A.enqueueAction(action);
	},

	endProcess : function (component, event, helper, fieldSetRef){
		component.set("v.errMsg", "");
		component.set("v.isModalOpen", false);
        component.set('v.hideStagePathUpdateBtn', false);
        component.set('v.isClosedLost', false);
        component.set('v.isClosedWon', false);
        //component.set('v.confetti', false);
		component.set('v.innerPathValue', '');
        component.set('v.hideStagePathUpdateBtn', false);
        $A.get('e.force:refreshView').fire();
	},

	callback_getFieldsFromFieldSet : function (component, event, helper, fieldSetRef){
		console.log('opp close proc: entered callback_getFieldsFromFieldSet');
		component.set("v.showSpinner", true);
		var action1 = component.get("c.getFieldsFromFieldSet");
		action1.setParams({
			objectName: "Opportunity",
			fieldSetName: fieldSetRef
		});
		action1.setCallback(this, function(response){
			let state = response.getState();
			if(state == "SUCCESS"){
				console.log('opp close proc: callback_getFieldsFromFieldSet state=SUCCESS');
				let fieldsStr = response.getReturnValue();
				let fields = JSON.parse(fieldsStr);
				component.set("v.fields", fields);
			} else {
				console.log('opp close proc: callback_getFieldsFromFieldSet state=ERROR');
				let err = response.getError();
				helper.callbackErrorHander(component, event, helper, err);
			}
			component.set("v.showSpinner", false);
		});
		$A.enqueueAction(action1);
	},
	
	// end of refactored callback methods

	// start of refactored non-callback methods
	
	callbackErrorHander : function(component, event, helper, respErr){
		let err = respErr;
		let errMsg = '';
		console.log()
		if (err && Array.isArray(err)) {
			errMsg = 'Error: ' + err[0].message;
		} else {
			errMsg = 'Unknown error occured.';
		}
		component.set("v.errMsg", errMsg);
	},

	checkHandover_InternalOpp : function (component, event, helper){
		if (component.get('v.oppData.Passed_AM_Threshold__c') || component.get('v.oppData.Passed_CSM_Threshold__c') || component.get('v.oppData.Passed_Onboarding_Threshold__c')) {
			component.set('v.showHandover', true);
			console.log('opp close proc: #checkHandover_InternalOpp v.showHandover is true - thresholds logic');
		}else {
			component.set('v.showHandover', false);
			console.log('opp close proc: #checkHandover_InternalOpp v.showHandover is false - thresholds logic');
		}
	},

	checkIfPrimarySoSigned : function(component, event, helper){
		if(component.get('v.oppData.Is_Primary_SO_Signed__c')){
			component.set('v.showWhatSigned', true);
			component.set('v.innerPathValue', 'SO Information');
		}else{
			if(component.get('v.oppData.Close_Process_Path__c') != null && component.get('v.oppData.Close_Process_Path__c') != ''){
				component.set('v.innerPathValue', component.get('v.oppData.Close_Process_Path__c'));
			}else{
				component.set('v.innerPathValue', 'Claim');
			}
		}
		if(component.get('v.oppData.Is_SO_Signed__c') == true){
			component.set('v.isSoManuallySigned', true);
		}
	},

	checkFilesUploaded : function(component, event, helper){
		var fileLWC = component.find("fileUploadImp");
        var validateFileUpload = fileLWC.validate();
		console.log('opp close proc: checkFilesUploaded validateFileUpload res: '+ JSON.stringify(validateFileUpload));
		var fileUploaded = validateFileUpload.isValid;
		console.log('opp close proc: checkFilesUploaded fileUploaded: '+ fileUploaded);
        if(fileUploaded) fileLWC.clearSessionStorage();
		else component.set("v.errMsg", validateFileUpload.errorMessage);
        return fileUploaded;
    },

	submit_closedWon : function(component, event, helper){
		console.log('opp close proc: submit_closedWon path value: '+component.get('v.innerPathValue'));
		if(component.get('v.innerPathValue') == 'Claim'){
			if(component.get('v.closedFields.What_Would_You_Like_To_Claim__c') == 'CC Payments'){
				component.set('v.innerPathValue', 'CCClaim');
				helper.callback_saveInnerPicklistPath(component, event, helper, "CC Claim");
			}else{
				component.set('v.innerPathValue', 'ManualSignature');
				helper.callback_saveInnerPicklistPath(component, event, helper, 'Manual Signature');
			}
		} else if(component.get('v.innerPathValue') == 'ManualSignature'){ // manualy signed
			console.log('opp close proc: submit_closedWon isSoManuallySigned: '+component.get('v.isSoManuallySigned'));
			console.log('opp close proc: submit_closedWon entered manually signed input validation');
			var manualSignatureInputValid = true;
			component.find('manuallySignedFields').forEach(function (field) {
				if (!field.get("v.value") || component.get('v.isSoManuallySigned') == false) {
					manualSignatureInputValid = false;
				}
				field.reportValidity();
			});
			console.log('opp close proc: submit_closedWon checkFilesUploaded result: ' + helper.checkFilesUploaded(component, event, helper));
			var filesUploaded = helper.checkFilesUploaded(component, event, helper);
			if(manualSignatureInputValid && filesUploaded){
				console.log('opp close proc: submit_closedWon Manual Signature valid input');
				helper.callback_saveManualFields(component, event, helper);
			} else {
				console.log('opp close proc: submit_closedWon Manual Signature not valid input');
			}
		}else if(component.get('v.innerPathValue') == 'BBPickers'){ // manualy signed
			component.set('v.innerPathValue', 'CCClaim');
			helper.callback_saveInnerPicklistPath(component, event, helper, "CC Claim");
		}else if(component.get('v.innerPathValue') == 'CCClaim'){ // cc claim - here we do save stage
			if(component.get('v.showHandover') == true){
				component.set('v.innerPathValue', 'Handover');
				helper.callFlow_getHandover(component, event, helper);
			}else{
				helper.callback_closeOpp(component, event, helper, "Closed Won");
			}
		}else if(component.get('v.innerPathValue') == 'continueToSummary'){
			component.set('v.innerPathValue', 'OppSummary');
			helper.callFlow_getOpportunitySummary(component, event, helper);
		}else if(component.get('v.innerPathValue') == 'SOInfo'){ // manualy signed
			component.set('v.innerPathValue', 'CCClaim');
			helper.callback_saveInnerPicklistPath(component, event, helper, "CC Claim");
		}
	},

	submit_closedLost : function(component, event, helper){
		console.log('opp close proc: entered submit_closedLost');
		component.set('v.showSpinner', true);
		component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
			if (saveResult.state == "SUCCESS" || saveResult.state == "DRAFT") {
				console.log('opp close proc: saveRecord result SUCCESS');
				if(component.get('v.innerPathValue') == 'continueToSummary'){
					component.set('v.innerPathValue', 'OppSummary');
					helper.callFlow_getOpportunitySummary(component, event, helper);
				} else {
					component.set('v.innerPathValue', 'continueToSummary');
					helper.callback_closeOpp(component, event, helper, "Closed Lost");
				}
			} else if(saveResult.state == "ERROR") {
				console.log('opp close proc: saveRecord result ERROR');
				console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
				component.set("v.errMsg", JSON.stringify(saveResult.error));
			}
			component.set('v.showSpinner', false);
		}));
		/*
		var closeLostInputValid = true;
		component.find("ClosedLostFieldCheck").forEach(function (field) {
			if (!field.get("v.value")) {
				closeLostInputValid = false;
			}
			//field.reportValidity();
		});
		if(closeLostInputValid){
			console.log('submitDetails valid input');
			if(component.get('v.innerPathValue') == 'continueToSummary'){
				component.set('v.innerPathValue', 'OppSummary');
				helper.callFlow_getOpportunitySummary(component, event, helper);
			} else {
				component.set('v.innerPathValue', 'continueToSummary');
				helper.callback_closeOpp(component, event, helper, "Closed Lost");
			}
		} else {
			console.log('submitDetails not valid input');
		}*/
	},

	handleClosedWonStageSelected : function (component, event, helper){
		console.log('opp close proc: handleClosedWonStageSelected');
		var fieldSetReferance;
		var isRetreiveFieldSet;
		if(component.get('v.oppData.Opportunity_Type__c') != 'Expansion'){
			if(component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity' && component.get('v.oppData.Is_Potential_GB_Opportunity__c')){
				fieldSetReferance = "InternalOpportunity_Won_NotExpansion";
				isRetreiveFieldSet = true;
			}else if(component.get('v.oppData.RecordType.DeveloperName') == 'Partner_Opportunity'){
				fieldSetReferance = "PartnerOpportunity_WonLost_NotExpansion";
				isRetreiveFieldSet = true;
			}
		}else if(component.get('v.oppData.Opportunity_Type__c') == 'Expansion' && component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity'){
			fieldSetReferance = "InternalOpportunity_Won_Expansion";
			isRetreiveFieldSet = true;
		}

		if(isRetreiveFieldSet == true){
			helper.callback_getFieldsFromFieldSet(component, event, helper, fieldSetReferance);
		}else{
			component.set('v.showValidation', false);
		}

		component.set('v.isModalOpen', true);
		component.set('v.isClosedWon', true);
		
		if(component.get('v.showWhatSigned')){ //if Is_Primary_SO_Signed__c = true -> don't show manual signed fields
			component.set('v.innerPathValue', 'SOInfo');
			helper.callback_saveInnerPicklistPath(component, event, helper, "SO Information");
		}else{ //if Is_Primary_SO_Signed__c = false -> show manual signed fields
			if(component.get('v.innerPathValue') == 'Claim'){
				helper.callback_saveInnerPicklistPath(component, event, helper, "Claim");
			}

			if(component.get('v.oppData.Close_Process_Path__c') == 'Claim'){
				component.set('v.innerPathValue', 'Claim');
			}else if(component.get('v.oppData.Close_Process_Path__c') == 'SO Information'){
				component.set('v.innerPathValue', 'SOInfo');
			}else if(component.get('v.oppData.Close_Process_Path__c') == 'Lost Information'){
				component.set('v.innerPathValue', 'LostInfo');
			}
	
			if(component.get('v.oppData.Close_Process_Path__c') != 'Claim' && component.get('v.oppData.Close_Process_Path__c') != 'SO Information' && component.get('v.oppData.Close_Process_Path__c') != 'Lost Information'){
				component.set('v.showValidation', false);
				if(component.get('v.oppData.Close_Process_Path__c') == 'Manual Signature'){
					component.set('v.innerPathValue', 'ManualSignature');
				}else if(component.get('v.oppData.Close_Process_Path__c') == 'BigBrain Pickers'){
					component.set('v.innerPathValue', 'BBPickers');
				}else if(component.get('v.oppData.Close_Process_Path__c') == 'CC Claim'){
					component.set('v.innerPathValue', 'CCClaim');
				}else if(component.get('v.oppData.Close_Process_Path__c') == 'Handover'){
					component.set('v.innerPathValue', 'Handover');
					helper.callFlow_getHandover(component, event, helper);
				}else if(component.get('v.oppData.Close_Process_Path__c') == 'Opportunity Summary'){
					component.set('v.innerPathValue', 'OppSummary');
					helper.callFlow_getOpportunitySummary(component, event, helper);
				}
			}
		}
	},

	handleClosedLostStageSelected : function (component, event, helper){
		console.log('opp close proc: handleClosedLostStageSelected');
		component.set('v.isClosedLost', true);
		component.set('v.innerPathValue', 'LostInfo');
		component.set('v.isModalOpen', true);

		// check if need to get fields from field set
		var fieldSetReferance;
		var isRetreiveFieldSet = false;
		if(component.get('v.oppData.StageName') != 'Qualified'){
			if(component.get('v.oppData.Opportunity_Type__c') != 'Expansion'){
				if(component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity' && component.get('v.oppData.Is_Potential_GB_Opportunity__c')){
					fieldSetReferance = "InternalOpportunity_Lost_NotExpansion";
					isRetreiveFieldSet = true;
				}else if(component.get('v.oppData.RecordType.DeveloperName') == 'Partner_Opportunity'){
					fieldSetReferance = "PartnerOpportunity_WonLost_NotExpansion";
					isRetreiveFieldSet = true;
				}
				console.log('opp close proc: handleClosedLostStageSelected isRetreiveFieldSet: '+isRetreiveFieldSet);
				if(isRetreiveFieldSet){
					helper.callback_getFieldsFromFieldSet(component, event, helper, fieldSetReferance);
				}else{
					component.set('v.showValidation', false);
				}
			}else{
				component.set('v.showValidation', false);
			}
		}else{
			component.set('v.showValidation', false);
		}
	},
	// end of refactored non-callback methods

	
	// start of refactored call flow methods
	callFlow_getHandover : function(component, event, helper){
		helper.callback_saveInnerPicklistPath(component, event, helper, "Handover");
		var flow = component.find("handoverFlowData");
		var inputVariables = [{
			name : "recordId",
			type : "String",
			value : component.get("v.recordId")}
		];
		flow.startFlow("Opportunity_Handover_Flow_Refactored", inputVariables);
	},

	callFlow_getOpportunitySummary : function(component, event, helper){
		helper.callback_saveInnerPicklistPath(component, event, helper, "Opportunity Summary");
		var flow = component.find("closedOppSumFlowData");
		var inputVariables = [{
			name : "CurrOppID",
			type : "String",
			value : component.get("v.recordId")}
		];
		flow.startFlow("Closed_Won_Opportunity_Summary", inputVariables);
	},

	// end of refactored call flow methods

	setPreviousStep : function (component, event, helper){
		if(component.get('v.innerPathValue') == 'SOInfo' || component.get('v.innerPathValue') == 'Claim'){
			component.set('v.showValidation', true);
			if(component.get('v.oppData.Opportunity_Type__c') != 'Expansion'){
				if(component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity' && component.get('v.oppData.Is_Potential_GB_Opportunity__c')){
					fieldSetReferance = "InternalOpportunity_Won_NotExpansion";
					isRetreiveFieldSet = true;
				}else if(component.get('v.oppData.RecordType.DeveloperName') == 'Partner_Opportunity'){
					fieldSetReferance = "PartnerOpportunity_WonLost_NotExpansion";
					isRetreiveFieldSet = true;
				}
			}else if(component.get('v.oppData.Opportunity_Type__c') == 'Expansion' && component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity'){
				fieldSetReferance = "InternalOpportunity_Won_Expansion";
				isRetreiveFieldSet = true;
			}
			if(isRetreiveFieldSet == true){
				helper.callback_getFieldsFromFieldSet(component, event, helper, fieldSetReferance);
			}
		}
		if(component.get('v.innerPathValue') == 'ManualSignature'){
            component.set('v.innerPathValue', 'Claim');
        }else if(component.get('v.innerPathValue') == 'BBPickers'){
            component.set('v.innerPathValue', 'ManualSignature');
        }else if(component.get('v.innerPathValue') == 'CCClaim'){
            if(component.get('v.showWhatSigned') == true){
                component.set('v.innerPathValue', 'SOInfo');
            }else if(component.get('v.showWhatSigned') == false){
                if(component.get('v.closedFields.What_Would_You_Like_To_Claim__c') == 'CC Payments'){
                    component.set('v.innerPathValue', 'Claim');
                }else{
                    if(component.get('v.closedFields.Manual_Signature_Reason__c') == 'Priority SO'){
                        component.set('v.innerPathValue', 'BBPickers');
                    }else if(component.get('v.isPrioritySO') != 'Priority SO' && component.get('v.closedFields.Manual_Signature_Reason__c') != 'Priority SO'){
                        component.set('v.innerPathValue', 'ManualSignature');
                    }
                }
            }
        }else if(component.get('v.innerPathValue') == 'Handover'){
            component.set('v.innerPathValue', 'CCClaim');
        }else if(component.get('v.innerPathValue') == 'OppSummary'){
            if(component.get('v.oppData.StageName') == 'Closed Lost'){
                component.set('v.isClosedLost', true);
            }else if(component.get('v.oppData.StageName') == 'Closed Won'){
                if(component.get('v.showHandover') == true){
                    component.set('v.innerPathValue', 'Handover');
                }else{
                    component.set('v.innerPathValue', 'CCClaim');
                }
            }
        }
	},
})