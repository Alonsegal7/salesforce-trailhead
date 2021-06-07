({
    init : function(component, event, helper) {
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

					if (storeResponse.hasOwnProperty('hasPermissionToForm')) {
						console.log('### hasPermissionToForm:' + storeResponse.hasPermissionToForm);
						component.set('v.hasPermission', storeResponse.hasPermissionToForm);
					}
				}
				
				else{
                }   
			}
			
			else{
				console.log('### response.getError(): ' + response.getError());
				var errors = response.getError();
				console.log('### error messsge: ' + errors[0].message);
			}
            var spinner = component.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = component.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
		$A.enqueueAction(action);

		
	},

	closeModal : function(component, event, helper) {
        console.log('### v.innerPathValue: ' + component.get('v.innerPathValue'));
		component.set('v.openModal', false);
		window.location.reload()
    },
	
	handleLoad : function(component, event, helper) {
		component.set("v.showSpinner", false);   
	},

	handleSubmit : function(component, event, helper) {
		component.set('v.showSpinner', true);
		console.log('### in submit: ');
		console.log('### openModal: ' + component.get("v.openModal"));
		// component.set("v.openModal",false);
		event.preventDefault();
		var fields = event.getParam();
		console.log('### fields: ');
		component.find('recordEditForm').submit(fields);
		console.log('### fields_v2: ');
	},

	handleSuccess : function(component, event, helper) {
		console.log('### in success: ');
		component.set('v.showSpinner', false);
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
				
				//if Partner Profile and Deal Reg = approved and in Sandbox --> Link to Sandbox Community
				if(component.get('v.dealRegStatus') == 'Approved'){
					component.set('v.showNotice', true);
					console.log('### showNotice: ' + component.get('v.showNotice'));
				}

				/*//if Partner Profile and Deal Reg = approved and in Production --> Link to Production Community
				else if(component.get('v.dealRegStatus') == 'Approved' && component.get('v.userProfile') == 'Partner Community Custom' && component.get('v.isSandbox') == false){
					component.set('v.showNotice', true);
					console.log('### showNotice: ' + component.get('v.showNotice'));
					component.set('v.relatedOppLink', 'https://monday--partial.lightning.force.com/lightning/r/Opportunity/');
				}*/

				//if Partner Profile and Deal Reg = Pending Review and in Production --> Link to Sandbox Community
				else if(component.get('v.dealRegStatus') == 'Pending Review'){
					component.set('v.showNotice', true);
					console.log('### showNotice: ' + component.get('v.showNotice'));
				}

				/*if Partner Profile and Deal Reg = Pending Review and in Production --> Link to Production Community
				else if(component.get('v.dealRegStatus') == 'Pending Review' && component.get('v.userProfile') == 'Partner Community Custom' && component.get('v.isSandbox') == false){
					component.set('v.showNotice', true);
					console.log('### showNotice: ' + component.get('v.showNotice'));
					component.set('v.relatedDealRegLink', 'partial-monday.cs173.force.com/partners/s/detail/');
				}*/
				// if(component.get('v.userProfile') == 'Partner Community Custom' && component.get('v.isSandbox') == true){
					// component.set('v.showNotice', true);
					// console.log('### showNotice: ' + component.get('v.showNotice'));
					// component.set('v.relatedDealRegLink', 'detail/');
					// console.log('### relatedDealRegLink: ' + component.get('v.relatedDealRegLink'));
				// }
			}
			
			else {
				console.log('### event_v1: ' + console.log(event));
				var errors = response.getError();
				console.log('### error messsge_v1: ' + errors[0].message);
			}
		});
		$A.enqueueAction(action);
	},

	openDealRegForm : function(component, event, helper){
		console.log('### openModal: ' + component.get('v.openModal'));
		component.set('v.openModal', true);
		console.log('### openModal: ' + component.get('v.openModal'));
		var action = component.get("c.getProfileInfo");
		action.setCallback(this, function(response) {
			console.log('### in action: ');
			var state = response.getState();
			console.log('### actionProfile: ' + response.getReturnValue().Name);
			if(state == "SUCCESS" && component.isValid()){
				console.log("successProfile") ;
				var result = response.getReturnValue().Name;
				component.set('v.userProfile', result);
		
			}
			
			else{
				console.error("fail:" + response.getError()[0].message); 
			}
		});
		$A.enqueueAction(action);

		var action1 = component.get("c.runningInASandbox");
		action1.setCallback(this, function(response) {
			console.log('### in action: ');
			var state = response.getState();
			console.log('### actionSanbox: ' + response.getReturnValue());
			if(state == "SUCCESS" && component.isValid()){
				console.log("successSandbox") ;
				var result = response.getReturnValue();
				component.set('v.isSandbox', result);
		
			}
			
			else{
				console.error("fail:" + response.getError()[0].message); 
			}
		});
		$A.enqueueAction(action1);
	},
})