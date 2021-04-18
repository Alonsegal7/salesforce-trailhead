({
    init : function(component, event, helper) {
		var action = component.get("c.getInitialParameters");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				console.log('### state: ' + state);
				var storeResponse = response.getReturnValue();
				console.log('### storeResponse: ' + storeResponse);
				console.log('### this: ' + this);
                if (storeResponse != null){
					storeResponse = JSON.parse(storeResponse);
					console.log('### storeResponse_v1: ' + storeResponse);
					console.log('### hasOwnProperty: ' + storeResponse.hasOwnProperty('partnerFieldSet'));
					console.log('### partnerFieldSet: ' + storeResponse.partnerFieldSet.length);
					if (storeResponse.hasOwnProperty('partnerFieldSet') && storeResponse.partnerFieldSet.length > 0) {
						var theLeadFields = new Array();
						console.log('### theLeadFields_v1: ' + theLeadFields);
						for (var i = 0; i < storeResponse.partnerFieldSet.length; i++){
							var f = {};
							f.name = storeResponse.partnerFieldSet[i].name;
							f.req = storeResponse.partnerFieldSet[i].required;
							theLeadFields.push(JSON.parse(JSON.stringify(f)));
							console.log('### theLeadFields: ' + theLeadFields);
						}
						component.set('v.partnerFieldSetForm', theLeadFields);
						console.log('### partnerFieldSetForm: ' + component.get('v.partnerFieldSetForm'));
					}
				}
				
				else{
                }   
            }
            var spinner = component.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = component.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
		$A.enqueueAction(action);
	},
	
	handleLoad : function(component, event, helper) {
		component.set("v.showSpinner", false);   
	},

	handleSubmit : function(component, event, helper) {
		console.log('### in submit');
		event.preventDefault();
        var fields = event.getParam();
		component.find('recordEditForm').submit(fields);
		// $A.get('e.force:refreshView').fire();
	},

	handleSuccess : function(component, event, helper) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"message": "The property's info has been updated.",
			"type": "success"
		});
		toastEvent.fire();
		// $A.get('e.force:refreshView').fire();
		window.location.reload()
	},

	runCallout_Test_V2 : function(component, event) {
		console.log('@@@@@@@@@@@@@');
		var param = event.getParams('fields'); //get event params
        var fields_v2 = param.response.fields; //get all field info
        console.log('=======================');
        // console.log('Param - ' + JSON.stringify(param)); 
        // console.log('Fields - ' + JSON.stringify(fields_v2));
         
        //get Record Edit Form Field Values
        // console.log('Email - ' + fields_v2.Registered_Email__c.value);
        // console.log('Name - ' + fields_v2.Lead_Name__c.value);
		// console.log('Company - ' + fields_v2.Company__c.value);
		// console.log('Company Size - ' + fields_v2.Company_Size__c.value);
		console.log('Company Website - ' + fields_v2.Company_Website__c.value);
			var action = component.get("c.getSalesforceData");
			action.setParams({
				"email": fields_v2.Registered_Email__c.value,
				"companySize": fields_v2.Company_Size__c.value,
				"companyWebsite": fields_v2.Company_Website__c.value,
				"cpm": fields_v2.CPM__m.value,
				"companyName": fields_v2.Company__c.value,
			});
			action.setCallback(component, function(response) {
				var state = response.getState();
				if (component.isValid() && state === "SUCCESS") {
					// set the response(return Map<String,object>) to response attribute.
					$A.get('e.force:refreshView').fire(); 
					//component.set("v.response", response.getReturnValue());
					console.log('### check response: ' + component.get('v.response'));
				}
			});
	 
			$A.enqueueAction(action);
		// }
	},

	//=========================Do Not Delete - API call to BB for data
	runCallout_Test : function(component, event) {
		var param = event.getParams(); //get event params
        var fields_v2 = param.response.fields; //get all field info
        console.log('=======================');
        // console.log('Param - ' + JSON.stringify(param)); 
        // console.log('Fields - ' + JSON.stringify(fields_v2));
         
        //get Record Edit Form Field Values
        console.log('Email - ' + fields_v2.Registered_Email__c.value);
        console.log('Name - ' + fields_v2.Lead_Name__c.value);
		console.log('Company - ' + fields_v2.Company__c.value);

		var target = event.getSource();
		//var txtValField = target.get("v.fieldName");
		// var toggleValue = component.get("v.toggleChecked");

		// if(toggleValue == true){
			// create a server side action.       
			var action = component.get("c.getCalloutResponseContents");
			// set the url parameter for getCalloutResponseContents method (to use as endPoint) 
			action.setParams({
				"url": 'https://data.bigbrain.me/graphql/v1',
				"email": fields_v2.Registered_Email__c.value
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (component.isValid() && state === "SUCCESS") {
					// set the response(return Map<String,object>) to response attribute.      
					component.set("v.response", response.getReturnValue());
					console.log('### check response: ' + component.get('v.response'));
				}
			});
	 
			$A.enqueueAction(action);
		// }
	},
	//======================================

	handleSuccess_Test : function(component, event, helper) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"message": "The property's info has been updated.",
			"type": "success"
		});
		toastEvent.fire();

		var rid = component.get("v.recordId");
		var navService = component.find("navService");

		var pageReference = {
			type: 'standard__recordPage',
			attributes: {
				"recordId": rid,
				"objectApiName": 'component.get("v.sObjectName")',
				"actionName": "view"
			}
		}
		event.preventDefault();
		navService.navigate(pageReference);		
	}
})