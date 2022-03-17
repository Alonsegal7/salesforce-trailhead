({
	getHandover : function(component, event, helper){
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
				}
			});
			$A.enqueueAction(action);
		}

		var flow = component.find("handoverFlowData");
		// In that component, start your flow. Reference the flow's API Name.
		var inputVariables = [
			{
				name : "recordId",
				type : "String",
				value : component.get("v.recordId")
			},
		];
		flow.startFlow("Opportunity_Handover_Flow_Refactored", inputVariables);
	},

	getOpportunitySummary : function(component, event, helper){
		var oppId = component.get('v.recordId');
		if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
			var action = component.get("c.saveInnerPicklistPath");
			action.setParams({ 
				recordId : oppId,
				innerPicklistPath : "Opportunity Summary"

			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
				}
			});
			$A.enqueueAction(action);
		}
		
		var flow = component.find("closedOppSumFlowData");

		// In that component, start your flow. Reference the flow's API Name.
		var inputVariables = [{
			name : "CurrOppID",
			type : "String",
			value : component.get("v.recordId")}
		];
		flow.startFlow("Closed_Won_Opportunity_Summary", inputVariables);
	},

	checkHandover_InternalOpp : function (component, event, helper){
		if (component.get('v.oppData.Passed_AM_Threshold__c') || component.get('v.oppData.Passed_CSM_Threshold__c') || component.get('v.oppData.Passed_Onboarding_Threshold__c')) {
			component.set('v.showHandover', true);
			console.log('#checkHandover_InternalOpp v.showHandover is true - thresholds logic');
		}
		else {
			component.set('v.showHandover', false);
			console.log('#checkHandover_InternalOpp v.showHandover is false - thresholds logic');
		}
	},

	recalcHandoverThreshold : function(component, event, helper){
		var oppId = component.get("v.recordId");
		console.log('entered recalcHandoverThreshold. OppId: '+oppId);
		let recalcAction = component.get("c.recalcHandoverThreshold");
		recalcAction.setParams({
			recordId: oppId
		});
		recalcAction.setCallback(this, function(response){
			let state = response.getState();
			console.log('entered checkifpass AM response');
			if(state==="SUCCESS"){
				console.log('#entered recalcAction and got success, running refreshOppData');
				helper.refreshOppData(component, event, helper);			
			} else {
				console.log('#entered recalcAction error');
				alert("error");
			}
		});
		$A.enqueueAction(recalcAction);
	},

	/*
	Order of actions, each action is called after a response is recieved from the last action: 
	1. [updateCompanySize] company size alignment between oppty and company (in case the size was changes)
	2. [recalcHandoverThreshold] will check again which handover threshold match this oppty
	*/
	updateCompanySize : function(component, event, helper){
		var oppId = component.get("v.recordId");
		console.log('entered updateCompanySize. OppId: '+oppId);
		let updateSizeAction = component.get("c.updateCompanySize");
		updateSizeAction.setParams({
			recordId: oppId
		});
		updateSizeAction.setCallback(this, function(response){
			let state = response.getState();
			console.log('entered updateCompanySize response');
			if(state==="SUCCESS"){
				console.log('#entered updateCompanySize and got success ');
				helper.recalcHandoverThreshold(component, event, helper);
			} else {
				console.log('#entered updateCompanySize error');
				alert("error");
			}
		});
		$A.enqueueAction(updateSizeAction);
	},

	setInnerPicklistPath : function(component, event, helper, innerValue){
		var oppId = component.get('v.recordId');
		var action = component.get("c.saveInnerPicklistPath");
		action.setParams({ 
			recordId : oppId,
			innerPicklistPath : innerValue

		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
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
					});
				}
			}
		});
		$A.enqueueAction(action);
	},

	setStageUpdateToast : function (component, event, helper){
		component.set('v.isModalOpen', false);
		component.find('notifLib').showToast({
			"variant": "success",
			"title": "Stage changed succesfully."                      
		});
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
		var errMsg = "";
		component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state == "SUCCESS" || saveResult.state == "DRAFT") {
				component.set('v.showSpinner', false);
				component.set('v.confetti', true);
				component.find('notifLib').showToast({
					"variant": "success",
					"title": "Stage changed succesfully."                      
				});
				component.set('v.wonCompletedSuccess', true);
				component.set('v.recordSaveError', '');
				var oppId = component.get('v.recordId');
				var action = component.get("c.getARRSum");
				action.setParams({ "oppId" : oppId });
				action.setCallback(this, function(response) {
					var state = response.getState();
					if (state === "SUCCESS") {
						helper.updateProbability(component, event, helper);
						var storeResponse = response.getReturnValue();
						if (storeResponse != null){
							storeResponse = JSON.parse(storeResponse);
							if (storeResponse.hasOwnProperty('opportunityARR')){
								component.set('v.greenBucketData', storeResponse.opportunityARR);
								if(storeResponse.opportunityARR.Green_Bucket_ARR_V2__c >= 10000){
									component.set('v.innerPathValue', 'continueToSummary');
								}else{
									component.set('v.isModalOpen', false);
								}
							}
						}
					}else if (state === "ERROR") {
						var errors = response.getError();
						if (errors) {
							if (errors[0] && errors[0].message) {
								console.log("Error message in Opportunity_ClosingProcess Helper: " + errors[0].message);
							}
						}else {
							console.log("Unknown error in Opportunity_ClosingProcess Helper:");
						}
					}
				});
				$A.enqueueAction(action)
            }else if (saveResult.state == "INCOMPLETE") {
			}else if(saveResult.state == "ERROR") {
				for (var i = 0; i < saveResult.error.length; i++) {
					errMsg += saveResult.error[i].message + "\n";
				}
				component.set('v.recordSaveError', errMsg);

				if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
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
		}));
	},

	saveManualFields : function(component, event, helper){
		component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
			var errMsg = "";
            if (saveResult.state == "SUCCESS" || saveResult.state == "DRAFT") {
				component.set('v.showSpinner', false);
            }
			
			else if (saveResult.state === "INCOMPLETE") {
			}

			else if(saveResult.state === "ERROR") {
				for (var i = 0; i < saveResult.error.length; i++) {
					errMsg += saveResult.error[i].message + "\n";
				}
				component.set("v.recordSaveError", errMsg);
			}
			
			if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
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

	coSellSurvey : function (component, event, helper){
		console.log('coSellSurvey');
		var oppId = component.get('v.recordId');
		var action = component.get("c.getOpportunityData");
		action.setParams({ "recordId" : oppId });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log('getOpportunityData SUCCESS');
				var storeResponse = response.getReturnValue();
				console.log('response.getReturnValue: '+JSON.stringify(response.getReturnValue()));
				if (storeResponse != null){
					component.set("v.oppData", storeResponse);
					console.log('init opp data: '+JSON.stringify(storeResponse));
					console.log('survey filled: '+component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c'));
					if(component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c') == false){
						component.set('v.hideUpdateButton', false);
						component.set('v.hideUpdateButton_ClosedProcess', false);
						component.find('notifLib').showToast({
							"variant": "error",
							"title": "You must fill the Co-Sell Impact Survey before closing the opportunity."                      
						});
					} else {
						helper.handleClosedWon(component, event, helper);
					}
				}
			}
		});
		$A.enqueueAction(action);
	},

	refreshOppData : function (component, event, helper){
		console.log('refreshOppData');
		var oppId = component.get('v.recordId');
		var action = component.get("c.getOpportunityData");
		action.setParams({ "recordId" : oppId });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log('getOpportunityData SUCCESS');
				var storeResponse = response.getReturnValue();
				console.log('response.getReturnValue: '+JSON.stringify(response.getReturnValue()));
				if (storeResponse != null){
					component.set("v.oppData", storeResponse);
					console.log('init opp data: '+JSON.stringify(storeResponse));
					console.log('# refreshOppData ran, running checkHandover_InternalOpp');
					helper.checkHandover_InternalOpp(component, event, helper);	
				}
			}
		});
		$A.enqueueAction(action);
	},

	handleClosedWon : function (component, event, helper){
		console.log('handleClosedWon');
		var fieldSetReferance;
		var isRetreiveFieldSet;
		if(component.get('v.oppData.Type') != 'Expansion'){
			if(component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity' && component.get('v.oppData.Is_Potential_GB_Opportunity__c')){
				fieldSetReferance = "InternalOpportunity_Won_NotExpansion";
				isRetreiveFieldSet = true;
			}

			else if(component.get('v.oppData.RecordType.DeveloperName') == 'Partner_Opportunity'){
				fieldSetReferance = "PartnerOpportunity_WonLost_NotExpansion";
				isRetreiveFieldSet = true;
			}
		}

		else if(component.get('v.oppData.Type') == 'Expansion' && component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity'){
			fieldSetReferance = "InternalOpportunity_Won_Expansion";
			isRetreiveFieldSet = true;
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
					let fields = JSON.parse(fieldsStr);
					component.set("v.fields", fields);
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
			if(component.get('v.innerPathValue') == 'Claim'){
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

			else if(component.get('v.oppData.Close_Process_Path__c') == 'Lost Information'){
				component.set('v.innerPathValue', 'LostInfo');
			}
	
			if(component.get('v.oppData.Close_Process_Path__c') != 'Claim' && component.get('v.oppData.Close_Process_Path__c') != 'SO Information' && component.get('v.oppData.Close_Process_Path__c') != 'Lost Information'){
				component.set('v.showValidation', false);
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
					helper.getHandover(component, event, helper);
				}
		
				else if(component.get('v.oppData.Close_Process_Path__c') == 'Opportunity Summary'){
					component.set('v.innerPathValue', 'OppSummary');
					helper.getOpportunitySummary(component, event, helper);
				}
			}
		}
	},

	handleClosedLost : function (component, event, helper){
		console.log('handleClosedLost');
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
				}

				else if(component.get('v.oppData.RecordType.DeveloperName') == 'Partner_Opportunity'){
					fieldSetReferance = "PartnerOpportunity_WonLost_NotExpansion";
					isRetreiveFieldSet = true;
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
	},

	setPreviousStep : function (component, event, helper){
		if(component.get('v.innerPathValue') == 'SOInfo' || component.get('v.innerPathValue') == 'Claim'){
			component.set('v.showValidation', true);
			if(component.get('v.oppData.Type') != 'Expansion'){
				if(component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity' && component.get('v.oppData.Is_Potential_GB_Opportunity__c')){
					fieldSetReferance = "InternalOpportunity_Won_NotExpansion";
					isRetreiveFieldSet = true;
				}

				else if(component.get('v.oppData.RecordType.DeveloperName') == 'Partner_Opportunity'){
					fieldSetReferance = "PartnerOpportunity_WonLost_NotExpansion";
					isRetreiveFieldSet = true;
				}
			}
			
			else if(component.get('v.oppData.Type') == 'Expansion' && component.get('v.oppData.RecordType.DeveloperName') == 'Internal_Opportunity'){
				fieldSetReferance = "InternalOpportunity_Won_Expansion";
				isRetreiveFieldSet = true;
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
						let fields = JSON.parse(fieldsStr);
						component.set("v.fields", fields);
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
		if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
			var action = component.get("c.updateProbability");
			action.setParams({ 
				recordId : oppId,
				oppStageName : component.get('v.closedFields.StageName')

			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				var errMsg = "";
				if (state == "SUCCESS") {
					component.set('v.checkARR', true);
				}
				else if (saveResult.state == "INCOMPLETE") {
				}
	
				else if(saveResult.state == "ERROR") {
					for (var i = 0; i < saveResult.error.length; i++) {
						errMsg += saveResult.error[i].message + "\n";
					}
					component.set("v.recordSaveError", errMsg);
				}
				
				if(component.get('v.recordSaveError') != "" && component.get('v.recordSaveError') != undefined){
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