({
	loadInitialParameters : function(cmp, evt){
		var oppId = cmp.get('v.recordId');
		var action = cmp.get("c.getInitialParameters");
        action.setParams({ "oppId" : oppId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
                if (!this.isEmpty(storeResponse)){
					//console.log('Init call response: ' + storeResponse);
					storeResponse = JSON.parse(storeResponse);
					if (storeResponse.hasOwnProperty('opportunity')){
						var lbe = {};
						cmp.set('v.loadedOpp', storeResponse.opportunity);
						if (!this.isEmpty(storeResponse.opportunity) && !this.isEmpty(storeResponse.opportunity.Billing_Entity__c)){
							lbe.val = storeResponse.opportunity.Billing_Entity__c;
							lbe.text = storeResponse.opportunity.Billing_Entity__r.Name;
							cmp.set('v.has_existing', true);
							if(!this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__c) && !this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__r)){
								cmp.set('v.showVATInEdtForm', (this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__r.VAT_Number__c)));
							}
						}
						cmp.set('v.latest_be', lbe);
					}
					if (storeResponse.hasOwnProperty('bestMatch')) {
						cmp.set('v.list_best_match', storeResponse.bestMatch);
						for (var i = 0; i < storeResponse.bestMatch.length; i++){
							if (storeResponse.bestMatch[i].selected){
								cmp.set('v.currently_selected', storeResponse.bestMatch[i].bEId);
							}
							console.log('Selected by default: ' + cmp.get('v.currently_selected'));
						}
					}
					if (storeResponse.hasOwnProperty('moreOptions')) {
						cmp.set('v.list_more_options', storeResponse.moreOptions);
					}
					if (storeResponse.hasOwnProperty('newFormFields') && storeResponse.newFormFields.length > 0) {
						var theFields = new Array();
						for (var i = 0; i < storeResponse.newFormFields.length; i++){
							var f = {};
							f.name = storeResponse.newFormFields[i].name;
							f.req = storeResponse.newFormFields[i].required;
							theFields.push(JSON.parse(JSON.stringify(f)));
						}
						cmp.set('v.form_new_fields', theFields);
						cmp.set('v.enable_form_new', true);
					}

					//Start Tal
					if (storeResponse.hasOwnProperty('newFormShippingFields') && storeResponse.newFormShippingFields.length > 0) {
						var theShippingFields = new Array();
						for (var i = 0; i < storeResponse.newFormShippingFields.length; i++){
							var f = {};
							f.name = storeResponse.newFormShippingFields[i].name;
							f.req = storeResponse.newFormShippingFields[i].required;
							theShippingFields.push(JSON.parse(JSON.stringify(f)));
						}
						cmp.set('v.form_new_shipping_fields', theShippingFields);
						cmp.set('v.enable_form_new', true);
						
					}
					//End Tal

					if (storeResponse.hasOwnProperty('editFormFields') && storeResponse.editFormFields.length > 0) {
						var theEditFields = new Array();
						for (var i = 0; i < storeResponse.editFormFields.length; i++){
							var ef = {};
							f.name = storeResponse.editFormFields[i].name;
							f.req = storeResponse.newFormFields[i].required;
							theEditFields.push(JSON.parse(JSON.stringify(f)));
						}
						cmp.set('v.form_edit_fields', theEditFields);
						//cmp.set('v.enable_form_new', true);
					}
					/**/
					if (storeResponse.hasOwnProperty('partnerSORequest') && storeResponse.hasOwnProperty('fieldMapping')){
						if (!this.isEmpty(storeResponse.partnerSORequest) && !this.isEmpty(storeResponse.fieldMapping)){
							var mappedFields = cmp.get('v.form_new_fields');
							if (!this.isEmpty(mappedFields)){
								for (var i = 0; i < mappedFields.length; i++){
									if (!this.isEmpty(storeResponse.fieldMapping[mappedFields[i].name])){
										mappedFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping[mappedFields[i].name]];
                                    }
								}
								//console.log('mappedFields: ' + JSON.stringify(mappedFields));
								cmp.set('v.form_new_fields', mappedFields);
								cmp.set('v.hasPartnerSO', true);
							}
							
							var mappedShippingFields = cmp.get('v.form_new_shipping_fields');
							if (!this.isEmpty(mappedShippingFields)){
								for (var i = 0; i < mappedShippingFields.length; i++){
									if (!this.isEmpty(storeResponse.fieldMapping[mappedFields[i].name])){
										mappedShippingFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping[mappedShippingFields[i].name]];
                                    }
								}
								//console.log('mappedFields: ' + JSON.stringify(mappedFields));
								cmp.set('v.form_new_shipping_fields', mappedShippingFields);
							} 
							cmp.set('v.hasPartnerSO', true);
						}
					}
					console.log('B1: ' + storeResponse.hasOwnProperty('fieldValidations'));
					if (storeResponse.hasOwnProperty('fieldValidations') && !this.isEmpty(storeResponse.fieldValidations.list_rules)){
						cmp.set('v.fieldValidations', storeResponse.fieldValidations.list_rules);
						console.log('Field validation rules found: ' + storeResponse.fieldValidations.list_rules.length);
						if (storeResponse.fieldValidations.list_rules.length > 15 && storeResponse.fieldValidations.list_rules.length < 21){
							cmp.set('v.validationRulesCloseToLimit', true);
						}
						if (storeResponse.fieldValidations.list_rules.length > 20){
							cmp.set('v.tooManyValidationRules', true);
						}
					}
					
					/**/
                }else{
                    
                }   
            }
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},

	callVatService : function(cmp, evt){
		console.log('--------------callVatService---------------')
		var fields = evt.getParam("fields");
		console.log('fields: ' + JSON.stringify(fields));
		console.log('--------------callVatService---------------+'+fields);
		var allowSubmit = cmp.get('v.allowSubmit');
		//Start Tal - VAT Logic
		var getVatNumber = fields.VAT_Number__c;
		if (!this.isEmpty(fields)){
			var action = cmp.get("c.CallVatService");
			action.setParams({
				"countryName": fields.Shipping_Country_G__c,           
                "vatNumber": getVatNumber
			});
			
		}
		//End Tal - VAT Logic
	
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS"){
				var storeResponse = response.getReturnValue();
				console.log('VAT-SERVICE----' + storeResponse);
				cmp.set('v.getServiceStatus', storeResponse);
				if (storeResponse=='invalid') {
					//Before all - Check vat number
					//Start Tal -VAT Logic - Remove this Toast
						// cmp.find('notifLib').showToast({
						// 	"title": 'Wrong VAT Number- ',
						// 	"variant": 'warning',
						// 	"mode":"sticky",
						// 	"message": 'Please check VAT and country information'
						// });
					//End Tal - VAT Logic - Remove this Toast
					//Start Tal - VAT Logic
					if(cmp.get('v.endPoint_duplicate') == false){
						cmp.set('v.showVatErrorCmp', true);
					}
					
					if(cmp.get('v.endPoint_duplicate') == true){
						cmp.set('v.showVatErrorCmp', true);
						cmp.set('v.invalidVATForm', true);
					}
					//End Tal - VAT Logic
				}
				//service is down
				else if (storeResponse=='unknown') {
					cmp.find('notifLib').showToast({
						"title": 'Wrong VAT Number- ',
						"variant": 'warning',
						"mode":"sticky",
						"message": 'Service is down - please contract bizops'
					});
				}
				else{//Vat number returned true - go next step
					this.testUniqu(cmp,evt);
				}
			}
		})
		
		$A.enqueueAction(action);
	},

	testUniqu : function(cmp, evt){
		console.log('submited')
		var fields = evt.getParam("fields");
		console.log('fields: ' + JSON.stringify(fields));
		var allowSubmit = cmp.get('v.allowSubmit');
		//Start Tal - VAT Logic
		var getVatNumber = fields.VAT_Number__c;
		//End Tal - VAT Logic
		if (!this.isEmpty(fields)){
			var action = cmp.get("c.testUniquness");
			action.setParams({
                "vatNumber": getVatNumber,
				"cBillingCurrency": fields.CurrencyIsoCode,
				"cCountry": fields.Country__c,
				"cCity": fields.City__c,
                "cName": fields.Name                
            });
            
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var storeResponse = response.getReturnValue();
					console.log('Uniquness test: ' + storeResponse);
					if (!this.isEmpty(storeResponse) && false){ // Rule currently down
						cmp.set('v.selected_be', JSON.parse(storeResponse));
						cmp.set('v.form_new', false);
					}else{
						var fieldValidations = cmp.get('v.fieldValidations');
						console.log('fieldValidations.length: ' + fieldValidations.length);
						console.log('allowSubmit: ' + allowSubmit);
						if (!this.isEmpty(fieldValidations) && fieldValidations.length > 0 && !allowSubmit){
							this.fieldValidations(cmp, evt);
						} else {
							console.log('Submit');
							var mainForm = cmp.find('mainBEForm');
							mainForm.submit(fields);
							//Start Tal - VAT Logic
							if(cmp.get('v.getVatServiceStatus') == 'Active'){
								this.updateBillingEntityFields(cmp, evt);
							}
							//End Tal - VAT Logic
						}
					}   
				}
				var spinner = cmp.find("cmspinnernew");
				$A.util.addClass(spinner, "slds-hide");
			});
			var spinner = cmp.find("cmspinnernew");
			$A.util.removeClass(spinner, "slds-hide");
			$A.enqueueAction(action);
		}
	},
	fieldValidations : function(cmp, evt){
		console.log('Initiating field validations');
		var fields = evt.getParam("fields");
		cmp.set('v.formFieldsToSubmit', fields);
		var action = cmp.get("c.fieldValidations");
		action.setParams({ "be": fields });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				console.log('Field validations response: ' + storeResponse);
				if (!this.isEmpty(storeResponse)){
					storeResponse = JSON.parse(storeResponse);
					console.log('Found existing records: ' + JSON.stringify(storeResponse.matchesFound));
					if (this.isEmpty(storeResponse.prevent) || storeResponse.prevent == false){
						cmp.set('v.allowSubmit', true);
					}
					if (this.isEmpty(storeResponse.matchesFound) || !Array.isArray(storeResponse.matchesFound) || storeResponse.matchesFound.length == 0){
						console.log('Submitting...' + cmp.get('v.invalidVATForm'));
						if(cmp.get('v.invalidVATForm') == false){
							var mainForm = cmp.find('mainBEForm');
							mainForm.submit(fields);
						}
						if(cmp.get('v.invalidVATForm') == true){
							var mainForm = cmp.find('invalidVATFormId');
							mainForm.submit(fields);
						}
						//Start Tal - VAT Logic
						if(cmp.get('v.billingEntityId') != null || cmp.get('v.beToUPdate') != null){
							this.updateBillingEntityFields(cmp, evt);
							this.relate(cmp, evt);
						}
						//End Tal - VAT Logic
					} else {
						console.log('Not Submitting...');
						cmp.set('v.altList', storeResponse.matchesFound);
						cmp.set('v.showAltPopup', true);
					}
				}
				/*
				if (!this.isEmpty(storeResponse)){
					cmp.set('v.selected_be', JSON.parse(storeResponse));
					cmp.set('v.form_new', false);
				}else{
					var fieldValidations = cmp.get('v.fieldValidations');
					if (!this.isEmpty(fieldValidations) && fieldValidations.length > 0){
						this.fieldValidations(cmp, evt);
					} else {
						var mainForm = cmp.find('mainBEForm');
						mainForm.submit(fields);
					}
				} 
				*/  
			}
			var spinner = cmp.find("cmspinnernew");
			$A.util.addClass(spinner, "slds-hide");
		});
		var spinner = cmp.find("cmspinnernew");
		$A.util.removeClass(spinner, "slds-hide");
		$A.enqueueAction(action);

	},
	relate : function(cmp, evt){
		var oppId = cmp.get('v.recordId');
		var beId = cmp.get('v.currently_selected');
		if (this.isEmpty(beId)){
			beId = cmp.get('v.selected_be');
			if (!this.isEmpty(beId)){
				beId = beId.val;
			}
			//Start Tal - VAT Logic
			if(cmp.get('v.getVatServiceStatus') == 'Active'){
				if(this.isEmpty(beId) && cmp.get('v.beIdAfterSuccess') != null && cmp.get('v.beIdAfterSuccess') != '' && cmp.get('v.beIdAfterSuccess') != undefined){
					beId = cmp.get('v.beIdAfterSuccess');
				}
			}
			//End Tal - VAT Logic
		}

		var action = cmp.get("c.doRelate");
        action.setParams({ "oppId" : oppId, "BEId" :  beId});
        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
                if (!this.isEmpty(storeResponse) && storeResponse.hasOwnProperty('status') && storeResponse.status == 'success'){
					cmp.set('v.latest_be', storeResponse.related_be);
					cmp.set('v.has_existing', true);
					cmp.set('v.endPoint_duplicate', false);
					$A.get("e.force:closeQuickAction").fire();
					$A.get('e.force:refreshView').fire();
					/*
					cmp.find('notifLib').showToast({
						"title": 'Success!',
						"variant": 'success',
						"mode":"dismissable",
						"message": 'Billing Entity successfully related'
					});	
					*/
                } else if (!this.isEmpty(storeResponse) && storeResponse.hasOwnProperty('status') && storeResponse.status == 'fail'){
                    //cmp.set('v.message', storeResponse);
					cmp.find('notifLib').showToast({
						"title": 'Error!',
						"variant": 'error',
						"mode":"sticky",
						"message": storeResponse.error
					});	
                }   
            }
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},
	isEmpty : function (obj){
		return (obj == null || typeof(obj) == 'undefined' || obj == '' || obj == 'undefined');
	},

	//Start Tal - VAT Logic
	checkVATBeforeRelate : function(cmp, evt){
		var beId = cmp.get('v.currently_selected');
		if (this.isEmpty(beId)){
			beId = cmp.get('v.selected_be');
			if (!this.isEmpty(beId)){
				beId = beId.val;
			}
		}
		cmp.set('v.beToUPdate', beId);

		var action = cmp.get("c.getValuesCallVatService");
        action.setParams({ "BEId" :  beId});
        action.setCallback(this, function(response) {
			var state = response.getState();
			var storeResponse = response.getReturnValue();
			cmp.set('v.getServiceStatus', storeResponse);
			if (state === "SUCCESS") {
				if (storeResponse=='invalid') {
					cmp.set('v.showVatErrorCmp', true);
					cmp.set('v.invalidVATForm', true);
				}
				//service is down
				else if (storeResponse=='unknown') {
					cmp.find('notifLib').showToast({
						"title": 'Wrong VAT Number- ',
						"variant": 'warning',
						"mode":"sticky",
						"message": 'Service is down - please contract bizops'
					});
				}
				else{
					if(cmp.get('v.selection_mode') == 'choose existing' || cmp.get('v.selection_mode') == 'search'){
						this.relate(cmp, evt);
					}

					if(cmp.get('v.endPoint_duplicate') == false){
						this.testUniqu(cmp,evt);
					}
				}
			}

			else if(state === "ERROR"){
				var errors = action.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log('### error message: '+ errors[0].message);
					}
				}
			}
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},

	updateBillingEntityFields : function(cmp, evt){
		var BEId = cmp.get('v.billingEntityId');
		var vatServiceStatus = cmp.get('v.getServiceStatus');
		if (this.isEmpty(BEId) || BEId == null){
			BEId = cmp.get('v.beToUPdate');
		}
		
		var customerVat = cmp.get('v.customerVatNumber');
		var vatNumber = cmp.get('v.vatNumberValue');
		var action = cmp.get("c.updateBillingEntityFields");
        action.setParams({ "BEId" :  BEId, "customerVat" : customerVat, "vatNumber" : vatNumber, "vatServiceStatus" : vatServiceStatus});
        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
				if(cmp.get('v.endPoint_duplicate') == false){
					cmp.set('v.selected_be', BEId);
					cmp.set('v.enableSet', false);
					cmp.set('v.temp_selected_be', null);
					cmp.set('v.form_new', false);
					cmp.set('v.showAltPopup', false);
					cmp.set('v.invalidVATForm', false);
					cmp.find('notifLib').showToast({
						"title": 'Success!',
						"variant": 'success',
						"mode":"dismissable",
						"message": 'Billing Entity successfully updated'
					});
				}
				else{
					this.relate(cmp, evt);
				}
				// $A.get("e.force:closeQuickAction").fire();
				// $A.get('e.force:refreshView').fire();
				
            }
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},

	updateBillingEntityFieldsFromCreate : function(cmp, evt){
		var BEId = cmp.get('v.beIdAfterSuccess');
		var vatServiceStatus = cmp.get('v.getServiceStatus');

		var customerVat = cmp.get('v.customerVatNumber');
		var vatNumber = cmp.get('v.vatNumberValue');

		var action = cmp.get("c.updateBillingEntityFields");
        action.setParams({ "BEId" :  BEId, "customerVat" : customerVat, "vatNumber" : vatNumber, "vatServiceStatus" : vatServiceStatus});
        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
				if(cmp.get('v.endPoint_duplicate') == false){
					cmp.set('v.selected_be', BEId);
					cmp.set('v.enableSet', false);
					cmp.set('v.temp_selected_be', null);
					cmp.set('v.form_new', false);
					cmp.set('v.showAltPopup', false);
					cmp.set('v.invalidVATForm', false);
					cmp.find('notifLib').showToast({
						"title": 'Success!',
						"variant": 'success',
						"mode":"dismissable",
						"message": 'Billing Entity successfully updated'
					});
				}
				else{
					this.relate(cmp, evt);
				}
				// $A.get("e.force:closeQuickAction").fire();
				// $A.get('e.force:refreshView').fire();
				
            }
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},

	isVATrequiresChecking : function(cmp, evt){
		var action = cmp.get("c.isVATrequiresChecking");
        action.setCallback(this, function(response) {
			var state = response.getState();
			var storeResponse = response.getReturnValue();
            if (state === "SUCCESS") {
				cmp.set('v.getVatServiceStatus', storeResponse);
            }
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	}
	//End Tal - VAT Logic
})