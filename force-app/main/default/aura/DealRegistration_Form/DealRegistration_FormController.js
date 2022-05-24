({
    init : function(component, event, helper) {
		try{
			console.log('### in init');
			var action = component.get("c.getInitialParameters");
			action.setCallback(this, function(response) {
				var state = response.getState();
				console.log('### state: ' + state);
				
				if (state === "SUCCESS") {
					console.log('### state: ' + state);
					var storeResponse = response.getReturnValue();
					console.log('### storeResponse: ' + storeResponse);
					console.log('### this: ' + this);
					if (storeResponse != null){
						storeResponse = JSON.parse(storeResponse);
						console.log('### storeResponse_v1: ' + storeResponse);
						console.log('### hasOwnProperty: ' + storeResponse.hasOwnProperty('companyDetailsFieldSet'));
						if (storeResponse.hasOwnProperty('companyDetailsFieldSet') && storeResponse.companyDetailsFieldSet.length > 0) {
							var fieldSetFields = new Array();
							console.log('### theLeadFields_v1: ' + fieldSetFields);
							for (var i = 0; i < storeResponse.companyDetailsFieldSet.length; i++){
								var f = {};
								f.name = storeResponse.companyDetailsFieldSet[i].name;
								f.req = storeResponse.companyDetailsFieldSet[i].required;
								fieldSetFields.push(JSON.parse(JSON.stringify(f)));
								console.log('### fieldSetFields: ' + fieldSetFields);
							}
							component.set('v.companyDetailsFieldSet', fieldSetFields);
							console.log('### companyDetailsFieldSet: ' + component.get('v.companyDetailsFieldSet'));
						}
	
						if (storeResponse.hasOwnProperty('contactDetailsFieldSet') && storeResponse.contactDetailsFieldSet.length > 0) {
							var fieldSetFields = new Array();
							console.log('### fieldSetFields_v1: ' + fieldSetFields);
							for (var i = 0; i < storeResponse.contactDetailsFieldSet.length; i++){
								var f = {};
								f.name = storeResponse.contactDetailsFieldSet[i].name;
								f.req = storeResponse.contactDetailsFieldSet[i].required;
								fieldSetFields.push(JSON.parse(JSON.stringify(f)));
								console.log('### fieldSetFields: ' + fieldSetFields);
							}
							component.set('v.contactDetailsFieldSet', fieldSetFields);
							console.log('### contactDetailsFieldSet: ' + component.get('v.contactDetailsFieldSet'));
						}
						
						if (storeResponse.hasOwnProperty('opportunityInformationFieldSet') && storeResponse.opportunityInformationFieldSet.length > 0) {
							var fieldSetFields = new Array();
							console.log('### fieldSetFields_v1: ' + fieldSetFields);
							for (var i = 0; i < storeResponse.opportunityInformationFieldSet.length; i++){
								var f = {};
								f.name = storeResponse.opportunityInformationFieldSet[i].name;
								f.req = storeResponse.opportunityInformationFieldSet[i].required;
								fieldSetFields.push(JSON.parse(JSON.stringify(f)));
								console.log('### fieldSetFields: ' + fieldSetFields);
							}
							component.set('v.opportunityInformationFieldSet', fieldSetFields);
							console.log('### opportunityInformationFieldSet: ' + component.get('v.opportunityInformationFieldSet'));
						}
	
						if (storeResponse.hasOwnProperty('opportunityQualificationFieldSet') && storeResponse.opportunityQualificationFieldSet.length > 0) {
							var fieldSetFields = new Array();
							for (var i = 0; i < storeResponse.opportunityQualificationFieldSet.length; i++){
								var f = {};
								f.name = storeResponse.opportunityQualificationFieldSet[i].name;
								f.req = storeResponse.opportunityQualificationFieldSet[i].required;
								fieldSetFields.push(JSON.parse(JSON.stringify(f)));
								console.log('### fieldSetFields: ' + fieldSetFields);
							}
							component.set('v.opportunityQualificationFieldSet', fieldSetFields);
							console.log('### opportunityQualificationFieldSet: ' + component.get('v.opportunityQualificationFieldSet'));
						}
						if (storeResponse.hasOwnProperty('eventDetailsFieldSet') && storeResponse.eventDetailsFieldSet.length > 0) {
							var fieldSetFields = new Array();
							for (var i = 0; i < storeResponse.eventDetailsFieldSet.length; i++){
								var f = {};
								f.name = storeResponse.eventDetailsFieldSet[i].name;
								f.req = storeResponse.eventDetailsFieldSet[i].required;
								fieldSetFields.push(JSON.parse(JSON.stringify(f)));
								console.log('### fieldSetFields: ' + fieldSetFields);
							}
							component.set('v.eventDetailsFieldSet', fieldSetFields);
							console.log('### eventDetailsFieldSet: ' + component.get('v.eventDetailsFieldSet'));
						}
					}
				} else {
					console.log('### response.getError(): ' + response.getError());
					var errors = response.getError();
					console.log('### error messsge: ' + errors[0].message);
				}
			});
			$A.enqueueAction(action);
		}catch(e){
			console.error(e);
			console.error('e.name => ' + e.name );
			console.error('e.message => ' + e.message );
			console.error('e.stack => ' + e.stack );
		}
	},

	closeModal : function(component, event, helper) {
        console.log('### v.innerPathValue: ' + component.get('v.innerPathValue'));
		component.set('v.openModal', false);
		window.location.reload()
    },
	
	handleLoad : function(component, event, helper) {
		var spinner = component.find("cmspinner");
        $A.util.addClass(spinner, "slds-hide");
	},

	handleSubmit : function(component, event, helper) {
		console.log('### in handle submit: ');
		try{
			event.preventDefault();
			var pmaId = component.get('v.customLookup_selectedRecId');
			var pmaIsRequired = component.get('v.customLookup_isRequired');
			if(pmaIsRequired && (pmaId == '' || pmaId == null || pmaId == undefined)){
				console.log('### Partner Marketing Activity not selected');
				component.set('v.customLookup_error','Please select the relevant Marketing Activity. This is mandatory based on the source you chose for this deal.');
			} else {
				component.set('v.customLookup_error','');
				var spinner = component.find("cmspinner");
				$A.util.removeClass(spinner, "slds-hide");
				var fields = event.getParam('fields');
				fields.Partner_Marketing_Activity__c = pmaId;
				console.log('### Partner Marketing Activity Id: '+pmaId);
				console.log('### going to submit form...');
				component.find('recordEditForm').submit(fields);
			}
		}catch(e){
			console.error(e);
			console.error('e.name => ' + e.name );
			console.error('e.message => ' + e.message );
			console.error('e.stack => ' + e.stack );
		}
	},

	handleError: function(component, event) {
		console.log('### in error submit: ');
        var errors = event.getParams();
        console.log("submit form response error: ", JSON.stringify(errors));
		var spinner = component.find("cmspinner");
        $A.util.addClass(spinner, "slds-hide");
    },

	handleSuccess : function(component, event, helper) {
		console.log('### in success: ');
		var dealRegId = event.getParams().response;
		console.log('### dealRegId: ' + dealRegId.id);
		component.set('v.dealRegRecordId', dealRegId);
		
		var action = component.get("c.updateDealRegistration");
		action.setParams({ 
			recordId : dealRegId.id
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			console.log('### state: ' + state);
			if (state == "SUCCESS") {
				console.log('### returned data is: ' + JSON.stringify(response.getReturnValue()));
				console.log('### opportunity data is: ' + response.getReturnValue().Related_Opportunity__c);
				component.set('v.opportunityId', response.getReturnValue().Related_Opportunity__c);
				console.log('### opportunityId: ' + component.get('v.opportunityId'));
				component.set('v.dealRegStatus', response.getReturnValue().Status__c);
				console.log('### dealRegStatus: ' + component.get('v.dealRegStatus'));
				component.set('v.dealRegId', response.getReturnValue().Id);
				console.log('### dealRegId: ' + component.get('v.dealRegId'));
				component.set('v.formScreen', false);
				component.set('v.showNotice', true);
			}else {
				console.log('### event_v1: ' + console.log(event));
				var errors = response.getError();
				console.log('### error messsge_v1: ' + errors[0].message);
			}
			var spinner = component.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
		});
		$A.enqueueAction(action);
	},

	openDealRegForm : function(component, event, helper){
		component.set('v.openModal', true);
		var spinner = component.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");

		var action = component.get("c.getProfileInfo");
		action.setCallback(this, function(response) {
			console.log('### in action: ');
			var state = response.getState();
			console.log('### actionProfile: ' + response.getReturnValue().Name);
			if(state == "SUCCESS" && component.isValid()){
				console.log("successProfile") ;
				var result = response.getReturnValue().Name;
				component.set('v.userProfile', result);
		
			}else{
				console.error("fail:" + response.getError()[0].message); 
			}
			var spinner = component.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
		});
		$A.enqueueAction(action);

		//TBD - consolidate these two actions to one
		var spinner = component.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");

		var action1 = component.get("c.runningInASandbox");
		action1.setCallback(this, function(response) {
			console.log('### in action: ');
			var state = response.getState();
			console.log('### actionSanbox: ' + response.getReturnValue());
			if(state == "SUCCESS" && component.isValid()){
				console.log("successSandbox") ;
				var result = response.getReturnValue();
				component.set('v.isSandbox', result);
		
			}else{
				console.error("fail:" + response.getError()[0].message); 
			}
			var spinner = component.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
		});
		$A.enqueueAction(action1);
	},

	handleContactDetailsFieldChange : function(component, event){
		try{
			var fieldName = event.getSource().get("v.fieldName");
			var fieldValue = event.getSource().get("v.value");
			if(fieldName == 'Source__c'){
				var isCustomLookupDisplayed = component.get('v.customLookup_isDisplayed');
				if(isCustomLookupDisplayed){
					var customLookupLWC = component.find("customLookup");
					customLookupLWC.handleClose();
					component.set('v.customLookup_selectedRecId', '');
				}
				if(fieldValue == 'Event' || fieldValue == 'Webinar'){
					component.set("v.eventOrWebinarSelected", true);  
				} else {
					component.set("v.eventOrWebinarSelected", false);  
				}
				var pmaCondition = '';
				var displayPmaLookup = false;
				var pmaMandatory = false; //if source is Other - the marketing activity selection is not mandatory
				if(fieldValue != '' && fieldValue != 'None'){
					displayPmaLookup = true;
					if(fieldValue == 'Email Campaign' || fieldValue == 'LinkedIn Campaign' || fieldValue == 'Google Campaign'){
						pmaCondition = "Activity_Type__c = 'Online Campaign'";
					} else if(fieldValue == 'Webinar'){
						pmaCondition = "Activity_Type__c = 'Event - Online'";
					} else if(fieldValue == 'Event'){
						pmaCondition = "Activity_Type__c = 'Event - In Person'";
					} else {
						pmaCondition = "Activity_Type__c != 'Online Campaign' and Activity_Type__c != 'Event - Online' and Activity_Type__c != 'Event - In Person' and Activity_Type__c != 'Headcount'";
					}
					if(fieldValue == 'Other'){
						pmaMandatory = false;
					} else {
						pmaMandatory = true;
					}
				} else {
					displayPmaLookup = false;
				}
				//console.log('handleContactDetailsFieldChange pmaCondition:' + pmaCondition);
				//console.log('handleContactDetailsFieldChange displayPmaLookup:' + displayPmaLookup);
				console.log('handleContactDetailsFieldChange pmaMandatory:' + pmaMandatory);
				component.set('v.customLookup_isRequired', pmaMandatory);
				component.set('v.customLookup_whereCondition', pmaCondition);
				component.set('v.customLookup_isDisplayed', displayPmaLookup);
			}
		} catch(e){
			console.error(e);
			console.error('e.name => ' + e.name );
			console.error('e.message => ' + e.message );
			console.error('e.stack => ' + e.stack );
		}
	},

	//custom lookup of marketing activities
	handleLookup: function(component, event){
		console.log('entered handleLookup');
        console.log( JSON.stringify ( event.getParam('data')) );
		var selectedRecordId = event.getParam('data').recordId;
		component.set('v.customLookup_selectedRecId', selectedRecordId);
    }
})