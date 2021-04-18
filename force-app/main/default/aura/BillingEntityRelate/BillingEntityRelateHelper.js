({
	loadInitialParameters : function(cmp, evt){
		var oppId = cmp.get('v.recordId');
		var action = cmp.get("c.getInitialParameters");
        action.setParams({ "oppId" : oppId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				console.log('### storeResponse: ' + storeResponse);
				console.log('### isEmpty: ' + this.isEmpty(storeResponse));
                if (!this.isEmpty(storeResponse)){
					//console.log('Init call response: ' + storeResponse);
					storeResponse = JSON.parse(storeResponse);
					console.log('### storeResponse: ' + this.isEmpty(storeResponse));
					console.log('### storeResponse1: ' + storeResponse.hasOwnProperty('opportunity'));
					if (storeResponse.hasOwnProperty('opportunity')){
						console.log('### storeResponse2: ' + storeResponse.hasOwnProperty('opportunity'));
						var lbe = {};
						cmp.set('v.loadedOpp', storeResponse.opportunity);
						console.log('### storeResponse3: ' + cmp.get('v.loadedOpp'));
						if (!this.isEmpty(storeResponse.opportunity) && !this.isEmpty(storeResponse.opportunity.Billing_Entity__c)){
							console.log('### storeResponse0: ' + this.isEmpty(storeResponse.opportunity.Billing_Entity__c));
							console.log('### storeResponse4: ' + this.isEmpty(storeResponse.opportunity));
							lbe.val = storeResponse.opportunity.Billing_Entity__c;
							console.log('### storeResponse5: ' + lbe.val);
							lbe.text = storeResponse.opportunity.Billing_Entity__r.Name;
							console.log('### storeResponse6: ' + lbe.text);
							cmp.set('v.has_existing', true);
							if(!this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__c)){
								console.log('### storeResponse7: ' + (this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__r.VAT_Number__c)));
								cmp.set('v.showVATInEdtForm', (this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__r.VAT_Number__c)));
							}
							console.log('### storeResponse8: ' + cmp.get('v.has_existing'));
							console.log('### storeResponse9: ' + cmp.get('v.showVATInEdtForm'));
						}
						cmp.set('v.latest_be', lbe);
						console.log('### storeResponse10: ' + cmp.get('v.latest_be'));
					}
					console.log('### storeResponse11: ' + storeResponse.hasOwnProperty('bestMatch'));
					if (storeResponse.hasOwnProperty('bestMatch')) {
						console.log('### storeResponse12: ' + storeResponse.hasOwnProperty('bestMatch'));
						console.log('### storeResponse13: ' + cmp.get('v.list_best_match'));
						cmp.set('v.list_best_match', storeResponse.bestMatch);
						console.log('### storeResponse14: ' + cmp.get('v.list_best_match'));
						for (var i = 0; i < storeResponse.bestMatch.length; i++){
							console.log('### storeResponse15: ' + storeResponse.bestMatch.length);
							if (storeResponse.bestMatch[i].selected){
								console.log('### storeResponse16: ' + storeResponse.bestMatch[i].selected);
								cmp.set('v.currently_selected', storeResponse.bestMatch[i].bEId);
							}
							console.log('Selected by default: ' + cmp.get('v.currently_selected'));
						}
					}
					if (storeResponse.hasOwnProperty('moreOptions')) {
						cmp.set('v.list_more_options', storeResponse.moreOptions);
					}
					console.log('### enable_form_new: ' + cmp.get('v.enable_form_new'));
					if (storeResponse.hasOwnProperty('newFormFields') && storeResponse.newFormFields.length > 0) {
						console.log('### Tal Test1 - enable_form_new: ' + cmp.get('v.enable_form_new'));
						var theFields = new Array();
						console.log('### Tal Test2: ' + theFields);
						for (var i = 0; i < storeResponse.newFormFields.length; i++){
							var f = {};
							f.name = storeResponse.newFormFields[i].name;
							console.log('### Tal Test3: ' + f.name);
							f.req = storeResponse.newFormFields[i].required;
							console.log('### Tal Test4: ' + f.req);
							theFields.push(JSON.parse(JSON.stringify(f)));
							console.log('### Tal Test5: ' + theFields);
						}
						cmp.set('v.form_new_fields', theFields);
						cmp.set('v.enable_form_new', true);
						console.log('### Tal Test6: ' + cmp.get('v.form_new_fields'));
						console.log('### Tal Test7: ' + cmp.get('v.enable_form_new'));
						
					}

					//Start Tal
					if (storeResponse.hasOwnProperty('newFormShippingFields') && storeResponse.newFormShippingFields.length > 0) {
						console.log('@@@ Tal Test1 - enable_form_new: ' + cmp.get('v.enable_form_new'));
						var theShippingFields = new Array();
						console.log('@@@ Tal Test2: ' + theFields);
						for (var i = 0; i < storeResponse.newFormShippingFields.length; i++){
							var f = {};
							f.name = storeResponse.newFormShippingFields[i].name;
							console.log('@@@ Tal Test3: ' + f.name);
							f.req = storeResponse.newFormShippingFields[i].required;
							console.log('@@@ Tal Test4: ' + f.req);
							theShippingFields.push(JSON.parse(JSON.stringify(f)));
							console.log('@@@ Tal Test5: ' + theFields);
						}
						cmp.set('v.form_new_shipping_fields', theShippingFields);
						cmp.set('v.enable_form_new', true);
						console.log('@@@ Tal Test6: ' + cmp.get('v.form_new_fields'));
						console.log('@@@ Tal Test7: ' + cmp.get('v.enable_form_new'));
						
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
	testUniqu : function(cmp, evt){
		var fields = evt.getParam("fields");
		console.log('fields: ' + JSON.stringify(fields));
		var allowSubmit = cmp.get('v.allowSubmit');
		if (!this.isEmpty(fields)){
			var action = cmp.get("c.testUniquness");
			action.setParams({
                "vatNumber": fields.VAT_Number__c,
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
					if (!this.isEmpty(storeResponse)){
						cmp.set('v.selected_be', JSON.parse(storeResponse));
						cmp.set('v.form_new', false);
					}else{
						var fieldValidations = cmp.get('v.fieldValidations');
						if (!this.isEmpty(fieldValidations) && fieldValidations.length > 0 && !allowSubmit){
							this.fieldValidations(cmp, evt);
						} else {
							var mainForm = cmp.find('mainBEForm');
							mainForm.submit(fields);
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
						var mainForm = cmp.find('mainBEForm');
						mainForm.submit(fields);
					} else {
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
	}
})