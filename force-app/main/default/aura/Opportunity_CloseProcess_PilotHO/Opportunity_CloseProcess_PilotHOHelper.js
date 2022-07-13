({

    callback_closedStageSelected : function (component, event, helper){
        console.log('opp close proc ho: entered callback_closedStageSelected');
		component.set("v.showSpinner", true);
        var action = component.get("c.closedStageSelected");
        action.setParams({ 
			oppId: component.get('v.recordId') 
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
				console.log('opp close proc ho: callback_closedStageSelected SUCCESS');
                var storeResponse = response.getReturnValue();
				if (storeResponse != null){
                    storeResponse = JSON.parse(storeResponse);
					if (storeResponse.hasOwnProperty('opportunity')){
                        component.set("v.oppData", storeResponse.opportunity);
                        console.log('opp close proc ho: close stage selected: opp data: '+ JSON.stringify(storeResponse.opportunity));
                        helper.checkHandover_InternalOpp(component, event, helper);
                    }
                    if (storeResponse.hasOwnProperty('fieldsStr')){
                        let fieldsStr = storeResponse.fieldsStr;
                        if(fieldsStr != null && fieldsStr != ''){
                            let fields = JSON.parse(fieldsStr);
                            component.set("v.fields", fields);
                            //component.set('v.showFieldSetForm', true);
                            console.log('opp close proc ho: close stage selected: fields from field set: '+JSON.stringify(component.get("v.fields")));
                        }
                    }
					if(component.get('v.isClosedWon')){
						if(component.get('v.oppData.Co_Sell_Opportunity__c') != null 
                        && component.get('v.oppData.Co_Sell_Opportunity__c') != ''
                        && component.get('v.oppData.Account.Co_Sell_Leader__c') != '' 
                        && component.get('v.oppData.Account.Co_Sell_Leader__c') != null
                        && component.get('v.oppData.Co_Sell_Request__c') != null 
                        && component.get('v.oppData.Co_Sell_Request__c') != '' 
                        && component.get('v.oppData.Co_Sell_Request__r.Status__c') == 'Approved'
                        && component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c') == false){
                        helper.callback_coSellSurvey(component, event, helper);
                    	} else {
							helper.handleClosedWonStageSelected(component, event, helper);
						}
					} else {
						helper.handleClosedLostStageSelected(component, event, helper);
					}
                }  else {
					errMsg = 'Oops... Server issue loading opportunity data (storeResponse is null in callbackInit). Please reach out to Biz Ops.';
					component.set("v.errMsg", errMsg);
				}
            } else {
				console.log('opp close proc ho: callbackInit ERROR');
				let err = response.getError();
				helper.callbackErrorHander(component, event, helper, err);
            }
			component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },

    handleClosedWonStageSelected : function (component, event, helper){
		console.log('opp close proc ho: handleClosedWonStageSelected');
        
        //if Close_Process_Path__c is not empty we set the path step to where it stopped last time by Close_Process_Path__c value (Claim, SOInfo, ManualSignature, CCClaim, Handover, OppSummary)
        if(component.get('v.oppData.Close_Process_Path__c') != null && component.get('v.oppData.Close_Process_Path__c') != ''){
            component.set('v.innerPathValue', component.get('v.oppData.Close_Process_Path__c'));
        } else { // Close_Process_Path__c is empty - first time to run close process
            if(component.get('v.oppData.Is_Primary_SO_Signed__c')){
                //component.set('v.showWhatSigned', true);
                component.set('v.innerPathValue', 'SOInfo');
            } else {
                component.set('v.innerPathValue', 'Claim');
            }
        }

        //steps to load field set form on       
        if(component.get('v.fields').length > 0 &&
            (component.get('v.innerPathValue') == 'Claim' || component.get('v.innerPathValue') == 'SOInfo')){ 
                component.set('v.showFieldSetForm', true);
        }

        //launch opp summary flow if the saved path step is opp summary
        if(component.get('v.innerPathValue') == 'OppSummary'){ 
            helper.callFlow_getOpportunitySummary(component, event, helper);
        }

		component.set('v.isModalOpen', true);
	},

	handleClosedLostStageSelected : function (component, event, helper){
		console.log('opp close proc ho: handleClosedLostStageSelected');
		component.set('v.innerPathValue', 'LostInfo');
		component.set('v.isModalOpen', true);
	},

	callback_saveInnerPicklistPath : function(component, event, helper, innerValue){ //save the innerPicklistPath
		console.log('opp close proc ho: entered callback_saveInnerPicklistPath');
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
					console.log('opp close proc ho: callback_saveInnerPicklistPath save inner path successfully! value: ' + storeResponse.Close_Process_Path__c);
				} else {
					console.log('opp close proc ho: entered callback_saveInnerPicklistPath ERROR');
					let err = response.getError();
					helper.callbackErrorHander(component, event, helper, err);
				}
				component.set("v.showSpinner", false);
			});
			$A.enqueueAction(action);
		}
	},

	callback_coSellSurvey : function (component, event, helper){
		console.log('opp close proc ho: callback_coSellSurvey');
		component.set("v.showSpinner", true);
		var action = component.get("c.getOpportunityData");
		action.setParams({ 
			recordId: component.get('v.recordId') 
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == "SUCCESS") {
				console.log('opp close proc ho: callback_coSellSurvey SUCCESS');
				var storeResponse = response.getReturnValue();
				console.log('opp close proc ho: response.getReturnValue: '+JSON.stringify(response.getReturnValue()));
				if (storeResponse != null){
					component.set("v.oppData", storeResponse);
					console.log('opp close proc ho: init opp data: '+JSON.stringify(storeResponse));
					console.log('opp close proc ho: survey filled: '+component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c'));
					if(component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c') == false){
						var cosellErrMsg = '';
						if(component.get('v.oppData.Account.Co_Sell_Leader__c') == 'Sales' && component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity'){
							cosellErrMsg = 'You must fill the Co-Sell Impact Survey before closing the Co-Sell opportunity.';
						} else if(component.get('v.oppData.Account.Co_Sell_Leader__c') == 'Partners' && component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity'){
							cosellErrMsg = 'You can not close won this opportunity before Co-Sell Impact Survey is filled by the Partner. Please ask the CPM/Partner to answer the survey on their opportunity to allow you to close won the deal.';
						}
						component.set('v.hideUpdateButton', false);
						component.set('v.hideStagePathUpdateBtn', false);
						component.find('notifLib').showToast({
							"variant": "error",
							"title": cosellErrMsg                      
						});
					} else {
						helper.handleClosedWonStageSelected(component, event, helper);
					}
				}
			} else {
				console.log('opp close proc ho: callback_coSellSurvey state=ERROR');
				let err = response.getError();
				helper.callbackErrorHander(component, event, helper, err);
			}
			component.set("v.showSpinner", false);
		});
		$A.enqueueAction(action);
	},

	callback_saveManualFields : function(component, event, helper){
		if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
			console.log('opp close proc ho: entered callback_saveManualFields');
			component.set('v.showSpinner', true);
			component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
				if (saveResult.state == "SUCCESS" || saveResult.state == "DRAFT") {
					console.log('opp close proc ho: callback_saveManualFields SUCCESS');
					if((component.get('v.recordSaveError') == undefined || component.get('v.recordSaveError') == "")){
						if(component.get('v.innerPathValue') == 'ManualSignature'){
							component.set('v.innerPathValue', 'CCClaim');
						} else if(component.get('v.innerPathValue') == 'Claim'){
							if(component.get('v.closedFields.What_Would_You_Like_To_Claim__c') == 'CC Payments'){
								component.set('v.innerPathValue', 'CCClaim');
							}else{
								component.set('v.innerPathValue', 'ManualSignature');
							}
						}
					} else { //tbd
						console.log('opp close proc ho: callback_saveManualFields error');
						helper.callbackErrorHander(component, event, helper, saveResult.error);
					}
				} else if(saveResult.state == "ERROR") {
					console.log('opp close proc ho: callback_saveManualFields state=ERROR');
					helper.callbackErrorHander(component, event, helper, saveResult.error);
				}
				component.set('v.showSpinner', false);
			}));
		}
	},

	callback_closeOpp : function(component, event, helper, stageToUpdate){
		console.log('opp close proc ho: entered callback_closeOpp');
		component.set("v.showSpinner", true);
		var action = component.get("c.closeOpp");
		action.setParams({ 
			recordId: component.get('v.recordId'),
			oppStageName: stageToUpdate
	 	});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == "SUCCESS") {
				console.log('opp close proc ho: callback_closeOpp SUCCESS');
				var storeResponse = response.getReturnValue();
				if (storeResponse != null){
					storeResponse = JSON.parse(storeResponse);
					if (storeResponse.hasOwnProperty('opportunity')){
						component.set('v.oppData', storeResponse.opportunity);
						console.log('opp close proc ho: callback_closeOpp result ARR: '+ storeResponse.opportunity.Green_Bucket_ARR_V2__c);
						if(component.get('v.isClosedWon')) { //CLOSE WON
							component.set('v.confetti', true); //we turn on the confetti flag and it will pop when process ends (by endProcess func)
							helper.checkHandover_InternalOpp(component, event, helper); //showHandover is updated
						}else if(component.get('v.isClosedLost')){ //CLOSE LOST
							component.find('notifLib').showToast({
								"variant": "success",
								"title": "Opportunity stage changed succesfully to Closed Lost!"                      
							});
						}
						if(component.get('v.showHandover') == true){
							component.set('v.innerPathValue', 'Handover');
						}else{
							helper.postHandoverActions(component, event, helper); //this checks if opp summary is needed otherwise ends the process
						}
					}
				}
			} else {
				console.log('opp close proc ho: callback_closeOpp state=ERROR');
				let err = response.getError();
				helper.callbackErrorHander(component, event, helper, err);
			}
			component.set("v.showSpinner", false);
		});
		$A.enqueueAction(action);
	},

	postHandoverActions : function(component, event, helper){
		if(component.get('v.oppData.Green_Bucket_ARR_V2__c') >= 10000){
            console.log('opp close proc ho: postHandoverActions continueToSummary');
            component.set('v.innerPathValue', 'continueToSummary');
        }else{
            component.set('v.innerPathValue', 'Done');
            console.log('opp close proc ho: postHandoverActions close modal');
            helper.endProcess(component, event, helper);
        }
	},

	endProcess : function (component, event, helper, fieldSetRef){
        var innerPathValue = component.get('v.innerPathValue');
        helper.callback_saveInnerPicklistPath(component, event, helper, innerPathValue);
		if(component.get('v.confetti') == true){
			component.find('notifLib').showToast({
				"variant": "success",
				"title": "Opportunity stage changed succesfully to Closed Won!"                      
			});
		}
		component.set("v.errMsg", "");
		component.set("v.isModalOpen", false);
        component.set('v.hideStagePathUpdateBtn', false);
        component.set('v.isClosedLost', false);
        component.set('v.isClosedWon', false);
		component.set('v.innerPathValue', '');
        component.set('v.hideStagePathUpdateBtn', false);
        $A.get('e.force:refreshView').fire();
	},
	
	callbackErrorHander : function(component, event, helper, respErr){
		let err = respErr;
		console.log('callbackErrorHander error: '+JSON.stringify(err));
		let errMsg = '';
		if (err && Array.isArray(err)) {
			let errObj = JSON.parse(JSON.stringify(err));
			errMsg = errObj[0].message;
			if(errMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') != -1){
				var index1 = errMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
				errMsg = errMsg.replace('FIELD_CUSTOM_VALIDATION_EXCEPTION, ','');
				errMsg = errMsg.replace(': []','');
				errMsg = errMsg.substring(index1);
			}
		} else {
			errMsg = 'Unknown error occured. Please contact Biz Ops team.';
		}
		component.find('notifLib').showToast({
			"variant": "error",
			"mode" : "sticky",
			"title": errMsg         
		});
		component.set("v.errMsg", errMsg);
	},

	checkHandover_InternalOpp : function (component, event, helper){
		console.log('opp close proc ho: entered #checkHandover_InternalOpp');
		if (component.get('v.oppData.Passed_AM_Threshold__c') || component.get('v.oppData.Passed_CSM_Threshold__c') || component.get('v.oppData.Passed_Onboarding_Threshold__c')) {
			component.set('v.showHandover', true);
			console.log('opp close proc ho: #checkHandover_InternalOpp v.showHandover is true - thresholds logic');
		}else {
			component.set('v.showHandover', false);
			console.log('opp close proc ho: #checkHandover_InternalOpp v.showHandover is false - thresholds logic');
		}
	},

	checkFilesUploaded : function(component, event, helper){
		var fileLWC = component.find("fileUploadImp");
        var validateFileUpload = fileLWC.validate();
		console.log('opp close proc ho: checkFilesUploaded validateFileUpload res: '+ JSON.stringify(validateFileUpload));
		var fileUploaded = validateFileUpload.isValid;
		console.log('opp close proc ho: checkFilesUploaded fileUploaded: '+ fileUploaded);
        if(fileUploaded) fileLWC.clearSessionStorage();
		else component.set("v.errMsg", validateFileUpload.errorMessage);
        return fileUploaded;
    },

	submit_closedWon : function(component, event, helper){ //from next step
		console.log('opp close proc ho: submit_closedWon path value: '+component.get('v.innerPathValue'));
		if(component.get('v.innerPathValue') == 'Claim'){ 
			helper.callback_saveManualFields(component, event, helper);
		} else if(component.get('v.innerPathValue') == 'ManualSignature'){ // manualy signed
			console.log('opp close proc ho: submit_closedWon is so manually signed marked?: '+component.get('v.closedFields.Is_SO_Signed__c'));
			console.log('opp close proc ho: submit_closedWon entered manually signed input validation');
			var manualSignatureInputValid = true;
			component.find('manuallySignedFields').forEach(function (field) {
				if (!field.get("v.value") || !component.get('v.closedFields.Is_SO_Signed__c')) {
					manualSignatureInputValid = false;
				}
				field.reportValidity();
			});
			console.log('opp close proc ho: submit_closedWon checkFilesUploaded result: ' + helper.checkFilesUploaded(component, event, helper));
			var filesUploaded = helper.checkFilesUploaded(component, event, helper);
			if(manualSignatureInputValid && filesUploaded){
				console.log('opp close proc ho: submit_closedWon Manual Signature valid input');
				helper.callback_saveManualFields(component, event, helper);
			} else {
				console.log('opp close proc ho: submit_closedWon Manual Signature invalid input!');
			}
		}else if(component.get('v.innerPathValue') == 'CCClaim'){ // cc claim - here we do save stage
			helper.callback_closeOpp(component, event, helper, "Closed Won");
			// the apex method sets opp.Close_Process_Path__c = 'Done' so no need to call callback_saveInnerPicklistPath here
		}else if(component.get('v.innerPathValue') == 'continueToSummary'){
			component.set('v.innerPathValue', 'OppSummary');
			helper.callFlow_getOpportunitySummary(component, event, helper);
		}else if(component.get('v.innerPathValue') == 'SOInfo'){ 
			if(component.get('v.oppData.Is_SO_Signed__c') == true){
				component.set('v.innerPathValue', 'ManualSignature');
			} else {
				component.set('v.innerPathValue', 'CCClaim');
			}
		}else if(component.get('v.innerPathValue') == 'Handover') {
			if(component.get('v.hasExistingHandover') == true) {
				helper.postHandoverActions(component, event, helper);
			}
			else {
				component.find('handoverScreen').handleSubmit(); // need to add here to continue to summary or close
			}
		}
	},

	submit_closedLost : function(component, event, helper){
		console.log('opp close proc ho: entered submit_closedLost');
		component.set('v.showSpinner', true);
		component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
			if (saveResult.state == "SUCCESS" || saveResult.state == "DRAFT") {
				console.log('opp close proc ho: saveRecord result SUCCESS');
				if(component.get('v.innerPathValue') == 'continueToSummary'){
					component.set('v.innerPathValue', 'OppSummary');
					helper.callFlow_getOpportunitySummary(component, event, helper);
				} else {
					component.set('v.innerPathValue', 'continueToSummary');
					helper.callback_closeOpp(component, event, helper, "Closed Lost");
				}
			} else if(saveResult.state == "ERROR") {
				console.log('opp close proc ho: saveRecord result ERROR');
				helper.callbackErrorHander(component, event, helper, saveResult.error);
			}
			component.set('v.showSpinner', false);
		}));
	},

	callFlow_getOpportunitySummary : function(component, event, helper){
		var flow = component.find("closedOppSumFlowData");
		var inputVariables = [{
			name : "CurrOppID",
			type : "String",
			value : component.get("v.recordId")}
		];
		flow.startFlow("Closed_Won_Opportunity_Summary", inputVariables);
	},

	setPreviousStep : function (component, event, helper){    
        if(component.get('v.fields').length > 0 &&
            (component.get('v.innerPathValue') == 'Claim' || component.get('v.innerPathValue') == 'SOInfo')){ 
                component.set('v.showFieldSetForm', true);
        }
		if(component.get('v.innerPathValue') == 'ManualSignature'){
            component.set('v.innerPathValue', 'Claim');
        }else if(component.get('v.innerPathValue') == 'CCClaim'){
            if(component.get('v.showWhatSigned') == true){
                component.set('v.innerPathValue', 'SOInfo');
            }else if(component.get('v.showWhatSigned') == false){
                if(component.get('v.closedFields.What_Would_You_Like_To_Claim__c') == 'CC Payments'){
                    component.set('v.innerPathValue', 'Claim');
                }else{
                    component.set('v.innerPathValue', 'ManualSignature');
                }
            }
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