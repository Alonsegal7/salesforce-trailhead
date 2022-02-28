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
		var inputVariables = [{
			name : "recordId",
			type : "String",
			value : component.get("v.recordId")}
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
		if(component.get('v.oppData.RecordType.Name') == 'Internal Opportunity'){
			if(component.get('v.oppData.Should_be_handed_over_to_AM__c')
			|| component.get('v.oppData.Total_PS_Hours__c') > 0 
			|| component.get('v.oppData.Total_PS_Expended_Hours__c') > 0
			|| component.get('v.oppData.Onboarding_Hours__c') > 0
			|| component.get('v.oppData.Total_Training_Hours__c') >= 3 ||
			(
			component.get('v.oppData.Expected_Plan_Seats__c') != undefined && component.get('v.oppData.Expected_Plan_Seats__c') >= 100
			&&
			(component.get('v.oppData.Expected_Plan_Tier__c') != undefined && (component.get('v.oppData.Expected_Plan_Tier__c') == 'enterprise' || component.get('v.oppData.Expected_Plan_Tier__c') == 'Enterprise'))
			&&
			component.get('v.oppData.Account.CSM_Function__c') != undefined && component.get('v.oppData.Account.CSM_Function__c') != 'Enterprise CSM' && component.get('v.oppData.Account.CSM_Function__c') != 'Mid-Market CSM')){
				component.set('v.showHandover', true);
				console.log('v.showHandover is true');
			}
			else console.log('v.showHandover is false');
		}
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
						var storeResponse = response.getReturnValue();
						if (storeResponse != null){
							storeResponse = JSON.parse(storeResponse);
							if (storeResponse.hasOwnProperty('opportunityARR')){
								component.set('v.greenBucketData', storeResponse.opportunityARR);
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
								console.log("Error message in Opportunity_ClosingProcess Helper: " + errors[0].message);
							}
						}
						
						else {
							console.log("Unknown error in Opportunity_ClosingProcess Helper:");
						}
					}
				});
				$A.enqueueAction(action)
            }

            else if (saveResult.state == "INCOMPLETE") {
			}

			else if(saveResult.state == "ERROR") {
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