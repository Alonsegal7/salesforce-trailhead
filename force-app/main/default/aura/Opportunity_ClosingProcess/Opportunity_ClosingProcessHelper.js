({
	getCCClaim : function(component, event, helper){
		var oppId = component.get('v.recordId');
		component.set('v.showCCClaim', true);
		component.set('v.innerPathValue', 'CCClaim');
		var action = component.get("c.saveInnerPicklistPath");
		action.setParams({ 
			recordId : oppId,
			innerPicklistPath : "CC Claim"

		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log('### state');
			}
		});
		$A.enqueueAction(action);
	},

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
					console.log('### state_1111111: ' + response.getReturnValue());
				}
			});
			$A.enqueueAction(action);
		}

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
		if(component.get('v.oppData.RecordType.Name') == 'Internal Opportunity'){
			if(component.get('v.oppData.Should_be_handed_over_to_AM__c')
			|| component.get('v.oppData.Total_PS_Hours__c') > 0 
			|| component.get('v.oppData.Total_PS_Extended_Hours__c') > 0 ||
			(
			component.get('v.oppData.Expected_Plan_Seats__c') != undefined && component.get('v.oppData.Expected_Plan_Seats__c') >= 100
			&&
			(component.get('v.oppData.Expected_Plan_Tier__c') != undefined && (component.get('v.oppData.Expected_Plan_Tier__c') == 'enterprise' || component.get('v.oppData.Expected_Plan_Tier__c') == 'Enterprise'))
			&&
			component.get('v.oppData.Account.CSM_Function__c') != undefined && component.get('v.oppData.Account.CSM_Function__c') != 'Enterprise CSM' && component.get('v.oppData.Account.CSM_Function__c') != 'Mid-Market CSM')){
				// component.set('v.innerPathValue', 'Handover');
				component.set('v.showHandover', true);
				console.log('showHandover_v1: ' + component.get('v.showHandover'));
			}
		}
	},

	setInnerPicklistPath : function(component, event, helper, innerValue){
		console.log('### in helper: ' + innerValue);
		var oppId = component.get('v.recordId');
		var action = component.get("c.saveInnerPicklistPath");
		action.setParams({ 
			recordId : oppId,
			innerPicklistPath : innerValue

		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log('### state');
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
				component.set('v.isModalOpen', false);
				console.log('### ok');
				component.set('v.isModalOpen', false);
				component.find('notifLib').showToast({
					"variant": "success",
					"title": "Stage changed succesfully."                      
				});
            }

            else if (saveResult.state == "INCOMPLETE") {
				console.log("User is offline, device doesn't support drafts.");
				// component.set("v.recordSaveError", errMsg);
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
				});
			}
		}));
		
	},

	setPreviousStep : function (component, event, helper){
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
				var errMsg = "";
				if (state == "SUCCESS") {
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