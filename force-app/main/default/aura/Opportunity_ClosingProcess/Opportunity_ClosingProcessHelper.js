({
	// getCCClaim : function(component, event, helper){
	// 	var oppId = component.get('v.recordId');
	// 	// component.set('v.showCCClaim', true);
	// 	component.set('v.innerPathValue', 'CCClaim');
	// 	var action = component.get("c.saveInnerPicklistPath");
	// 	action.setParams({ 
	// 		recordId : oppId,
	// 		innerPicklistPath : "CC Claim"

	// 	});
	// 	action.setCallback(this, function(response) {
	// 		var state = response.getState();
	// 		if (state === "SUCCESS") {
	// 			console.log('### state');
	// 		}
	// 	});
	// 	$A.enqueueAction(action);
	// },

	getHandover : function(component, event, helper){
		console.log('### handover helper');
		var oppId = component.get('v.recordId');
		if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
			var action = component.get("c.saveInnerPicklistPath");
			action.setParams({ 
				recordId : oppId,
				innerPicklistPath : "Handover"

			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					console.log('### state');
				}
			});
			$A.enqueueAction(action);
		}

		var flow = component.find("handoverFlowData");
		// In that component, start your flow. Reference the flow's API Name.
		var inputVariables = [{
			name : "recordId",
			type : "String",
			value : component.get("v.recordId")}
		];
		console.log('### testyyyyy');
		flow.startFlow("Handover", inputVariables);
	},

	getOpportunitySummary : function(component, event, helper){
		var oppId = component.get('v.recordId');
		console.log('### in summary');
		if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
			var action = component.get("c.saveInnerPicklistPath");
			action.setParams({ 
				recordId : oppId,
				innerPicklistPath : "Opportunity Summary"

			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				console.log('### hello' + state);
				if (state === "SUCCESS") {
					console.log('### state_22222: ' + response.getReturnValue());
				}
			});
			$A.enqueueAction(action);
		}
		console.log('### Close_Process_Path__c: ' + component.get('v.closedFields.Close_Process_Path__c'));
		var flow = component.find("closedOppSumFlowData");
		console.log('$$$ 111111_v12');
		console.log('### oppSummaryPath_v3:' + component.get('v.closedFields.Close_Process_Path__c'));
		// In that component, start your flow. Reference the flow's API Name.
		var inputVariables = [{
			name : "CurrOppID",
			type : "String",
			value : component.get("v.recordId")}
		];
		flow.startFlow("Closed_Won_Opportunity_Summary", inputVariables);
	},

	checkHandover_InternalOpp : function (component, event, helper){
		console.log('### 1: ' + component.get('v.oppData.RecordType.Name'));
		console.log('### 2: ' + component.get('v.oppData.Should_be_handed_over_to_AM__c'));
		console.log('### 3: ' + component.get('v.oppData.Total_PS_Hours__c'));
		console.log('### 4: ' + component.get('v.oppData.Total_PS_Expended_Hours__c'));
		console.log('### 5: ' + component.get('v.oppData.Total_Training_Hours__c'));
		console.log('### 6: ' + component.get('v.oppData.Expected_Plan_Seats__c'));
		console.log('### 7: ' + component.get('v.oppData.Expected_Plan_Tier__c'));
		console.log('### 8: ' + component.get('v.oppData.Account.CSM_Function__c'));
		if(component.get('v.oppData.RecordType.Name') == 'Internal Opportunity'){
			console.log('@@@ 1');
			if(component.get('v.oppData.Should_be_handed_over_to_AM__c')
			|| component.get('v.oppData.Total_PS_Hours__c') > 0 
			|| component.get('v.oppData.Total_PS_Expended_Hours__c') > 0
			|| component.get('v.oppData.Total_Training_Hours__c') >= 3 ||
			(
			component.get('v.oppData.Expected_Plan_Seats__c') != undefined && component.get('v.oppData.Expected_Plan_Seats__c') >= 100
			&&
			(component.get('v.oppData.Expected_Plan_Tier__c') != undefined && (component.get('v.oppData.Expected_Plan_Tier__c') == 'enterprise' || component.get('v.oppData.Expected_Plan_Tier__c') == 'Enterprise'))
			&&
			component.get('v.oppData.Account.CSM_Function__c') != undefined && component.get('v.oppData.Account.CSM_Function__c') != 'Enterprise CSM' && component.get('v.oppData.Account.CSM_Function__c') != 'Mid-Market CSM')){
				
				console.log('@@@ 2');
				component.set('v.showHandover', true);
				console.log('showHandover_v1: ' + component.get('v.showHandover'));
			}
		}
	},

	setInnerPicklistPath : function(component, event, helper, innerValue){
		console.log('### tal_v6: ' + innerValue);
		var oppId = component.get('v.recordId');
		var action = component.get("c.saveInnerPicklistPath");
		action.setParams({ 
			recordId : oppId,
			innerPicklistPath : innerValue

		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log('### tal_v7');
				// if(innerValue == 'Opportunity Summary'){
				// 	console.log('### tal_v77');
				// 	helper.getOpportunitySummary(component, event, helper);
				// }
			}

			else if (saveResult.state === "INCOMPLETE") {
				console.log("### Incomplete");
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
		});
		$A.enqueueAction(action);

		
	},

	setStageUpdateToast : function (component, event, helper){
		console.log('### show toast');
		component.set('v.isModalOpen', false);
		component.find('notifLib').showToast({
			"variant": "success",
			"title": "Stage changed succesfully."                      
		});
		// $A.get("e.force:refreshView").fire();
	},

	showSpinner: function(component) {
		var spinnerMain = component.find("Spinner");
		$A.util.removeClass(spinnerMain, "slds-hide");
	},

	hideSpinner : function(component) {
		var spinnerMain =  component.find("Spinner");
		$A.util.addClass(spinnerMain, "slds-hide");
	},

	savefields : function(component, event, helper){
		console.log('### save save:' + component.get('v.showSpinner'));
		var errMsg = "";
		component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
			console.log('### saveFields_v1: ' + saveResult.state);
            if (saveResult.state == "SUCCESS" || saveResult.state == "DRAFT") {
				component.set('v.showSpinner', false);
				component.set('v.confetti', true);
				// component.set('v.isModalOpen', false);
				component.find('notifLib').showToast({
					"variant": "success",
					"title": "Stage changed succesfully."                      
				});
				component.set('v.wonCompletedSuccess', true);
				console.log('### wonCompletedSuccess' + component.get('v.wonCompletedSuccess'));
				component.set('v.recordSaveError', '');
				console.log('### recordSaveError' + component.get('v.recordSaveError'));
				// window.location.reload()
				var oppId = component.get('v.recordId');
				var action = component.get("c.getARRSum");
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
							console.log('@@@ storeResponse_v2: ' + storeResponse.hasOwnProperty('opportunityARR'));
							if (storeResponse.hasOwnProperty('opportunityARR')){
								component.set('v.greenBucketData', storeResponse.opportunityARR);
								console.log('### Green_Bucket_ARR_V2__c: ' + storeResponse.opportunityARR.Green_Bucket_ARR_V2__c);
								if(storeResponse.opportunityARR.Green_Bucket_ARR_V2__c >= 10000){
									console.log('### in first: ' + storeResponse.opportunityARR.Green_Bucket_ARR_V2__c);
									component.set('v.innerPathValue', 'continueToSummary');
									// helper.getOpportunitySummary(component, event, helper);
								}
		
								else{
									console.log('### in 2nd: ' + storeResponse.opportunityARR.Green_Bucket_ARR_V2__c);
									component.set('v.isModalOpen', false);
								}
							}
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
				$A.enqueueAction(action)
            }

            else if (saveResult.state == "INCOMPLETE") {
				console.log("User is offline, device doesn't support drafts.");
			}

			else if(saveResult.state == "ERROR") {
				console.log('### in ERROR: ');
				for (var i = 0; i < saveResult.error.length; i++) {
					console.log('### in ERROR_v1: ');
					errMsg += saveResult.error[i].message + "\n";
					console.log('### in ERROR_v2: ' + errMsg);
				}
				console.log('ERROR---'+errMsg);
				component.set('v.recordSaveError', errMsg);

				if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
					console.log('### in notice');
					component.find('notifLib').showNotice({
						"variant": "error",
						"header": "Problem saving record:",
						"message": errMsg,
						closeCallback: function() {
							component.set('v.innerPathValue', 'CCClaim');
							component.set('v.showSpinner', false);
							component.set("v.recordSaveError", '');
							var innerValue = "Claim";
							helper.setInnerPicklistPath(component, event, helper, innerValue);
						}
					});
				}
			}
			
			else {
				console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
			}
		}));
	},

	saveManualFields : function(component, event, helper){
		console.log('### saveManualFields:' + component.get('v.closedFields.Is_SO_Signed__c'));
		component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
			console.log('### saveResult.state: ' + saveResult.state);
			var errMsg = "";
            if (saveResult.state == "SUCCESS" || saveResult.state == "DRAFT") {
				component.set('v.showSpinner', false);
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
			console.log('### recordSaveError: ' + component.get('v.recordSaveError'));
			if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
				console.log('### in notice');
				component.find('notifLib').showNotice({
					"variant": "error",
					"header": "Problem saving record:",
					"message": errMsg,
					closeCallback: function() {
						component.set('v.innerPathValue', 'ManualSignature');
						component.set('v.showSpinner', false);
						component.set("v.recordSaveError", '');
						var innerValue = "Manual Signature";
						helper.setInnerPicklistPath(component, event, helper, innerValue);
					}
				});
			}
		}));
		
	},

	setPreviousStep : function (component, event, helper){
		console.log('### in previous' + component.get('v.innerPathValue'));
		if(component.get('v.innerPathValue') == 'SOInfo' || component.get('v.innerPathValue') == 'Claim'){
			console.log('### in previous claim');
			console.log('### v.oppData.Type' + component.get('v.oppData.Type'));
			component.set('v.showValidation', true);
			console.log('### record type' + component.get('v.oppData.RecordType.DeveloperName'));
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
				console.log('### v.oppData.Type1' + component.get('v.oppData.Type'));
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
		}
		
		if(component.get('v.innerPathValue') == 'ManualSignature'){
            component.set('v.innerPathValue', 'Claim');
        }

        if(component.get('v.innerPathValue') == 'BBPickers'){
            component.set('v.innerPathValue', 'ManualSignature');
        }

        else if(component.get('v.innerPathValue') == 'CCClaim'){
            if(component.get('v.showWhatSigned') == true){
                component.set('v.innerPathValue', 'SOInfo');
            }
           
            else if(component.get('v.showWhatSigned') == false){
                if(component.get('v.closedFields.What_Would_You_Like_To_Claim__c') == 'CC Payments'){
                    component.set('v.innerPathValue', 'Claim');
                }

                else{
                    if(component.get('v.closedFields.Manual_Signature_Reason__c') == 'Priority SO'){
                        component.set('v.innerPathValue', 'BBPickers');
                    }
    
                    else if(component.get('v.isPrioritySO') != 'Priority SO' && component.get('v.closedFields.Manual_Signature_Reason__c') != 'Priority SO'){
                        component.set('v.innerPathValue', 'ManualSignature');
                    }
                }
            }
        }

        else if(component.get('v.innerPathValue') == 'Handover'){
            component.set('v.innerPathValue', 'CCClaim');
        }

        else if(component.get('v.innerPathValue') == 'OppSummary'){
            console.log('### previous: ' + component.get('v.oppData.StageName'));
            if(component.get('v.oppData.StageName') == 'Closed Lost'){
                component.set('v.isClosedLost', true);
            }

            if(component.get('v.oppData.StageName') == 'Closed Won'){
                if(component.get('v.showHandover') == true){
                    component.set('v.innerPathValue', 'Handover');
                }

                else{
                    component.set('v.innerPathValue', 'CCClaim');
                }
            }
        }
	},

	updateProbability : function(component, event, helper){
		var oppId = component.get('v.recordId');
		console.log('### in probability');
		if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
			console.log('### in prob');
			var action = component.get("c.updateProbability");
			action.setParams({ 
				recordId : oppId,
				oppStageName : component.get('v.closedFields.StageName')

			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				console.log('### hello' + state);
				console.log('### hello2' + response.getParam());
				var errMsg = "";
				if (state == "SUCCESS") {
					component.set('v.checkARR', true);
					console.log('### state_1111111: ' + response.getReturnValue());
				}
				else if (saveResult.state == "INCOMPLETE") {
					console.log("User is offline, device doesn't support drafts.");
					// component.set("v.recordSaveError", errMsg);
				}
	
				else if(saveResult.state == "ERROR") {
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
				console.log('### recordSaveError: ' + component.get("v.recordSaveError"));
				if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
					console.log('### in notice');
					component.find('notifLib').showNotice({
						"variant": "error",
						"header": "Problem saving record:",
						"message": errMsg,
					});
				}
			});
			$A.enqueueAction(action);
		}
	}
})