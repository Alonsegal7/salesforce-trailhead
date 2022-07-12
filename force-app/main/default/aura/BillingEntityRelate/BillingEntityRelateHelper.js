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
					cmp.set('v.date_today', storeResponse.date_today);
					try{
						if (storeResponse.hasOwnProperty('opportunity')){
							var lbe = {};
							cmp.set('v.loadedOpp', storeResponse.opportunity);
							if (!this.isEmpty(storeResponse.opportunity) && !this.isEmpty(storeResponse.opportunity.Billing_Entity__c)){
								lbe.val = storeResponse.opportunity.Billing_Entity__c;
								lbe.text = storeResponse.opportunity.Billing_Entity__r.Name;
								cmp.set('v.has_existing', true);

								if(!this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__c) && !this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__r)){
									//cmp.set('v.showVATInEdtForm', (this.isEmpty(storeResponse.opportunity.Account.Latest_Billing_Entity__r.VAT_Number__c)));
									let be = storeResponse.opportunity.Account.Latest_Billing_Entity__r;
									cmp.set('v.edit_country', be.Country__c);
									cmp.set('v.edit_state', be.Billing_State__c);
									cmp.set('v.edit_shipping_country', be.Shipping_Country_G__c);
									cmp.set('v.edit_shipping_state', be.Shipping_State__c);
									if ((!this.isEmpty(be.Customer_Has_VAT_Number__c) && be.Customer_Has_VAT_Number__c == 'Yes') || !this.isEmpty(be.VAT_Number__c)){
										cmp.set('v.edit_has_vat', 'Yes');
									} else {
										cmp.set('v.edit_has_vat', 'No');
									}
									if ((!this.isEmpty(be.Customer_Has_QST_Number__c) && be.Customer_Has_QST_Number__c == 'Yes') || !this.isEmpty(be.QST_Number__c)){
										cmp.set('v.edit_has_qst', 'Yes');
									} else {
										cmp.set('v.edit_has_qst', 'No');
									}
								}
							}
							cmp.set('v.latest_be', lbe);
							cmp.set('v.beToUPdate', lbe.val);
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
							console.log('theFields: ' + JSON.stringify(theFields));
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
						if (!this.isEmpty(storeResponse.partnerSORequest)){
							cmp.set('v.related_partner_so', storeResponse.partnerSORequest);
						}
						if (storeResponse.hasOwnProperty('partnerSORequest') && !this.isEmpty(storeResponse.partnerSORequest) && storeResponse.hasOwnProperty('fieldMapping')){
							cmp.set('v.isCanada', (storeResponse.partnerSORequest.Shipping_Country__c == 'Canada'));
							cmp.set('v.isQuebec', (storeResponse.partnerSORequest.Shipping_State__c == 'Quebec'));
							if (!this.isEmpty(storeResponse.partnerSORequest.VAT_Text__c)){
								console.log('VAT_Text__c: ' + storeResponse.partnerSORequest.VAT_Text__c);
								cmp.set('v.vatAttribute', storeResponse.partnerSORequest.VAT_Text__c);
								cmp.set('v.customerVatNumber', 'Yes');
								console.log('vatAttribute: ' + cmp.get('v.vatAttribute'));
							} else {
								cmp.set('v.customerVatNumber', 'No');
							}
							if (!this.isEmpty(storeResponse.partnerSORequest.QST_Number__c)){
								console.log('QST_Number__c: ' + storeResponse.partnerSORequest.QST_Number__c);
								cmp.set('v.vatAttribute', storeResponse.partnerSORequest.QST_Number__c);
								cmp.set('v.qstQ', 'Yes');
								console.log('qstNumber: ' + cmp.get('v.vatAttribute'));
							} else {
								cmp.set('v.qstQ', 'No');
							}

							if (!this.isEmpty(storeResponse.partnerSORequest) && !this.isEmpty(storeResponse.fieldMapping)){
								var mappedFields = cmp.get('v.form_new_fields');
								if (!this.isEmpty(mappedFields)){
									for (var i = 0; i < mappedFields.length; i++){
										if (!this.isEmpty(storeResponse.fieldMapping[mappedFields[i].name])){
											mappedFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping[mappedFields[i].name]];
										}
									}
									console.log('mappedFields: ' + JSON.stringify(mappedFields));
									cmp.set('v.form_new_fields', mappedFields);
									cmp.set('v.hasPartnerSO', true);
									cmp.set('v.toggleChecked', false);
								}
							
								var mappedShippingFields = cmp.get('v.form_new_shipping_fields');
								if (!this.isEmpty(mappedShippingFields)){
									for (var i = 0; i < mappedShippingFields.length; i++){
										/*
										if (mappedShippingFields[i].name == 'Ship_To_Name__c') mappedShippingFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping['Name']];
										if (mappedShippingFields[i].name == 'Shipping_Country_G__c') mappedShippingFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping['Country__c']];
										if (mappedShippingFields[i].name == 'Shipping_State__c') mappedShippingFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping['Billing_State__c']];
										if (mappedShippingFields[i].name == 'Shipping_City__c') mappedShippingFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping['City__c']];
										if (mappedShippingFields[i].name == 'Shipping_Street__c') mappedShippingFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping['Street__c']];
										if (mappedShippingFields[i].name == 'Shipping_Zip_Postal_Code__c') mappedShippingFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping['Zip_Postal_Code__c']];
										*/									
										if (!this.isEmpty(storeResponse.fieldMapping[mappedFields[i].name])){
											mappedShippingFields[i].val = storeResponse.partnerSORequest[storeResponse.fieldMapping[mappedShippingFields[i].name]];
										}
									
									}
									console.log('mappedShippingFields: ' + JSON.stringify(mappedShippingFields));
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
					} catch (err) {
						console.log('Error initializing: ' + err);
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

	callVatService : function(cmp, evt, fromForm){
		console.log('--------------callVatService---------------')
		var fields = evt.getParam("fields");
		console.log('fields: ' + JSON.stringify(fields));
		console.log('--------------callVatService---------------+'+fields);
		var allowSubmit = cmp.get('v.allowSubmit');
		var BEId = cmp.get('v.beToUPdate');
		var isEditing = cmp.get('v.edit_existing');
		cmp.set('v.vatError', false);
		cmp.set('v.gstError', false);
		cmp.set('v.qstError', false);

		if (!this.isEmpty(fields.VAT_Number__c)){
			var params = {};
			params.countryName = fields.Shipping_Country_G__c;
			params.vatNumber = fields.VAT_Number__c;
			if (fields.Shipping_Country_G__c == 'Canada'){
				params.testType = 'GST';
			}
			if(isEditing && !this.isEmpty(BEId)){
				params.beId = BEId;
			}

			console.log('VAT Validation params: ' + JSON.stringify(params));

			var action = cmp.get("c.CallVatService");
			action.setParams(params);
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS"){
					var storeResponse = response.getReturnValue();
					console.log('VAT-SERVICE----' + storeResponse);
					cmp.set('v.vatServiceCalled', true);
					cmp.set('v.getServiceStatus', storeResponse);
					if (storeResponse == 'invalid') {
						if(cmp.get('v.endPoint_duplicate') == false){
							if (fields.Shipping_Country_G__c == 'Canada'){
								console.log('GST Error, hold submit');
								cmp.set('v.gstError', true);
								if (!this.isEmpty(fields.QST_Number__c)){
									this.callVatServiceQST(cmp, evt, fromForm);
								} else {
									cmp.set('v.showVatErrorCmp', true);
									this.hideAllSpinners(cmp, evt);
								}
							} else {
								cmp.set('v.vatError', true);
								cmp.set('v.showVatErrorCmp', true);
								this.hideAllSpinners(cmp, evt);
							}
						}

						if(cmp.get('v.endPoint_duplicate') == true){
							cmp.set('v.showVatErrorCmp', true);
							cmp.set('v.invalidVATForm', true);
						}
					}
					//service is down
					else if (storeResponse=='unknown') {
						cmp.find('notifLib').showToast({
							"title": 'Wrong VAT Number- ',
							"variant": 'warning',
							"mode":"sticky",
							"message": 'Service is down - please contract bizops'
						});
					} else{//Vat number returned true - go next step
						cmp.set('v.vatError', false);
						cmp.set('v.gstError', false);
						if (fields.Shipping_Country_G__c == 'Canada' && !this.isEmpty(fields.QST_Number__c)){
							this.callVatServiceQST(cmp, evt);
						} else {
							if (fromForm == 'edit'){
								if (fields.Customer_Has_VAT_Number__c == 'No'){
									fields.VAT_Number__c = null;
								}
								if (!fields.hasOwnProperty('Customer_Has_QST_Number__c') || fields.Customer_Has_QST_Number__c == 'No'){
									fields.QST_Number__c = null;
								}
								if (cmp.get('v.vatServiceCalled')){
									fields.Last_VAT_Validation_Date__c = cmp.get('v.date_today');
								}
								cmp.find('mainEBEForm').submit(fields);
							} else {
								this.testUniqu(cmp, evt);
							}
						}
					}
				}
			})
			
			$A.enqueueAction(action);
		} else {
			if (fields.Shipping_Country_G__c == 'Canada' && !this.isEmpty(fields.QST_Number__c)){
				this.callVatServiceQST(cmp, evt);
			} else {
				if (fromForm == 'edit'){
					if (fields.Customer_Has_VAT_Number__c == 'No'){
						fields.VAT_Number__c = null;
					}
					if (!fields.hasOwnProperty('Customer_Has_QST_Number__c') || fields.Customer_Has_QST_Number__c == 'No'){
						fields.QST_Number__c = null;
					}
					if (cmp.get('v.vatServiceCalled')){
						fields.Last_VAT_Validation_Date__c = cmp.get('v.date_today');
					}
					cmp.find('mainEBEForm').submit(fields);
				} else {
					this.testUniqu(cmp, evt);
				}
			}
		}
	},

	callVatServiceQST : function(cmp, evt, fromForm){
		var fields = evt.getParam("fields");
		var params = {};
		params.countryName = fields.Shipping_Country_G__c;
		params.vatNumber = fields.QST_Number__c;
		params.testType = 'QST';
		var BEId = cmp.get('v.beToUPdate');
		var isEditing = cmp.get('v.edit_existing');
		if(isEditing && !this.isEmpty(BEId)){
			params.beId = BEId;
		}

		var action = cmp.get("c.CallVatService");
		action.setParams(params);
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS"){
				var storeResponse = response.getReturnValue();
				console.log('VAT-SERVICE-QST: ' + storeResponse);
				cmp.set('v.vatServiceCalled', true);
				cmp.set('v.getServiceStatus', storeResponse);
				if (storeResponse == 'invalid') {
					console.log('QST Error, hold submit');
					cmp.set('v.qstError', true);
					cmp.set('v.showVatErrorCmp', true);
					this.hideAllSpinners(cmp, evt);
				} else if (storeResponse == 'unknown') {//service is down
					cmp.find('notifLib').showToast({
						"title": 'VAT Service is down',
						"variant": 'warning',
						"mode":"sticky",
						"message": 'Service is down - please contract bizops'
					});
				} else {//Vat number returned true - go next step
					cmp.set('v.qstError', false);
					if (cmp.get('v.gstError')){
						cmp.set('v.showVatErrorCmp', true);
						this.hideAllSpinners(cmp, evt);
					} else {
						if (fromForm == 'edit'){
							if (fields.Customer_Has_VAT_Number__c == 'No'){
								fields.VAT_Number__c = null;
							}
							if (!fields.hasOwnProperty('Customer_Has_QST_Number__c') || fields.Customer_Has_QST_Number__c == 'No'){
								fields.QST_Number__c = null;
							}
							if (cmp.get('v.vatServiceCalled')){
								fields.Last_VAT_Validation_Date__c = cmp.get('v.date_today');
							}
							cmp.find('mainEBEForm').submit(fields);
						} else {
							this.testUniqu(cmp, evt);
						}
					}
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
		//End Tal - VAT Logicוואו
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
							try{
								if (cmp.get('v.vatServiceCalled')){
									fields.Last_VAT_Validation_Date__c = cmp.get('v.date_today');
								}
								var mainForm = cmp.find('mainEBEForm');
								if (!this.isEmpty(mainForm)){
									if (fields.Customer_Has_VAT_Number__c == 'No'){
										fields.VAT_Number__c = null;
									}
									if (!fields.hasOwnProperty('Customer_Has_QST_Number__c') || fields.Customer_Has_QST_Number__c == 'No'){
										fields.QST_Number__c = null;
									}
									mainForm.submit(fields);
									console.log('Edit form submitted');
								} else {
									var mainForm = cmp.find('mainBEForm');
									mainForm.submit(fields);
									console.log('New form submitted');
								}

								//Start Tal - VAT Logic
								/*
								if(cmp.get('v.getVatServiceStatus') == 'Active'){
									console.log('Calling updateBillingEntityFields');
									this.updateBillingEntityFields(cmp, evt);
									console.log('updateBillingEntityFields called');
								}
								*/
								//End Tal - VAT Logic
							} catch (err){
								console.log('Error trying to submit: ' + err);
							}
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
						if (cmp.get('v.vatServiceCalled')){
							console.log('Assigning Last_VAT_Validation_Date__c');
							fields.Last_VAT_Validation_Date__c = cmp.get('v.date_today');
						}
						if(cmp.get('v.invalidVATForm') == false){
							console.log('Choosing form to submit');
							var mainForm = cmp.find('mainBEForm');
							if (this.isEmpty(mainForm)){
								mainForm = cmp.find('mainEBEForm');
							}
							try{
								mainForm.submit(fields);
							} catch (err){
								console.log('Error submitting: ' + err);
							}
						}
						if(cmp.get('v.invalidVATForm') == true){
							console.log('5');
							var mainForm = cmp.find('invalidVATFormId');
							mainForm.submit(fields);
						}
						try{
							//Start Tal - VAT Logic
							console.log('6');
							if(cmp.get('v.billingEntityId') != null || cmp.get('v.beToUPdate') != null){
								//this.updateBillingEntityFields(cmp, evt);
								this.relate(cmp, evt);
							}
							//End Tal - VAT Logic
						} catch (err){
							console.log('Error calling post submit logic: ' + err);
						}
						
					} else {
						console.log('Not Submitting...');
						cmp.set('v.altList', storeResponse.matchesFound);
						cmp.set('v.showAltPopup', true);
						this.hideAllSpinners(cmp, evt);
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
		console.log('In relate');
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

		console.log('In relate 1');
		var action = cmp.get("c.doRelate");
        action.setParams({ "oppId" : oppId, "BEId" :  beId});
        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				console.log('Relate response: ' + JSON.stringify(storeResponse));
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
		return ((obj == null || typeof(obj) == 'undefined' || obj == '' || obj == 'undefined') && obj !== 0 && obj !== '0' && obj !== false);
	},

	//Start Tal - VAT Logic
	checkVATBeforeRelate : function(cmp, evt){
		var beId = cmp.get('v.currently_selected');
		var country = cmp.get('v.shippingCountry');
		if (this.isEmpty(beId)){
			beId = cmp.get('v.selected_be');
			if (!this.isEmpty(beId)){
				beId = beId.val;
			}
		}
		cmp.set('v.beToUPdate', beId);
		cmp.set('v.qstError', false);
		cmp.set('v.gstError', false);
		cmp.set('v.vatError', false);

		var action = cmp.get("c.getValuesCallVatService");
        action.setParams({ "BEId" :  beId});
        action.setCallback(this, function(response) {
			var state = response.getState();
			var storeResponse = response.getReturnValue();
			if (state === "SUCCESS") {
				cmp.set('v.vatServiceCalled', true);
				if (!this.isEmpty(storeResponse.raw)){
					cmp.set('v.getServiceStatus', storeResponse.raw);
				}

				if (!storeResponse.service_available){
					//service is down
					cmp.find('notifLib').showToast({
						"title": 'Wrong VAT Number- ',
						"variant": 'warning',
						"mode":"sticky",
						"message": 'Service is down - please contract bizops'
					});
				} else {
					console.log('checkVATBeforeRelate response: ' + JSON.stringify(storeResponse));
					if (!this.isEmpty(storeResponse.billing_entity)){
						cmp.set('v.isCanada', (storeResponse.billing_entity.Shipping_Country_G__c == 'Canada'));
						cmp.set('v.isQuebec', (storeResponse.billing_entity.Shipping_State__c == 'Quebec'));
						console.log('isCanada: ' + cmp.get('v.isCanada'));
						console.log('isQuebec: ' + cmp.get('v.isQuebec'));
						if (!this.isEmpty(storeResponse.billing_entity.VAT_Number__c) || storeResponse.billing_entity.Customer_Has_VAT_Number__c == 'Yes'){
							cmp.set('v.customerVatNumber', 'Yes');
							cmp.set('v.edit_has_vat', 'Yes');
							cmp.set('v.vatAttribute', storeResponse.billing_entity.VAT_Number__c);
						} else {
							cmp.set('v.customerVatNumber', 'No');
							cmp.set('v.edit_has_vat', 'No');
						}

						if (!this.isEmpty(storeResponse.billing_entity.QST_Number__c) || storeResponse.billing_entity.Customer_Has_QST_Number__c == 'Yes'){
							cmp.set('v.qstQ', 'Yes');
							cmp.set('v.edit_has_qst', 'Yes');
							cmp.set('v.qstNumber', storeResponse.billing_entity.QST_Number__c);
						} else {
							cmp.set('v.qstQ', 'No');
							cmp.set('v.edit_has_qst', 'No');
						}
					}
					if (storeResponse.hasOwnProperty('qst_valid') && cmp.get('v.isCanada') && cmp.get('v.isQuebec')){ // Boaz - Prevent QST validation from poping 
						cmp.set('v.qstError', !storeResponse.qst_valid);
					}
					if (storeResponse.hasOwnProperty('gst_valid') && cmp.get('v.isCanada')){ // Boaz - Prevent GST validation from poping 
						cmp.set('v.gstError', !storeResponse.gst_valid);
					}
					if (storeResponse.hasOwnProperty('vat_valid')){
						cmp.set('v.vatError', !storeResponse.vat_valid);
					}
					if (cmp.get('v.qstError') || cmp.get('v.gstError') || cmp.get('v.vatError')){
						console.log('Show VAT Error before relate');
						cmp.set('v.showVatErrorCmp', true);
						cmp.set('v.edit_existing', true);
						cmp.find('mainEBEForm').set('v.recordId', beId);
						//cmp.set('v.invalidVATForm', true);
					} else {
						if(cmp.get('v.selection_mode') == 'choose existing' || cmp.get('v.selection_mode') == 'search'){
							this.relate(cmp, evt);
						}

						if(cmp.get('v.endPoint_duplicate') == false){
							this.testUniqu(cmp,evt);
						}
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
	},
	//End Tal - VAT Logic
	resetToLoadedSO : function(cmp, evt){
		let pso = cmp.get('v.related_partner_so');

	},
	hideAllSpinners : function (cmp, evt){
		var spinner = cmp.find("cmspinner");
        $A.util.addClass(spinner, "slds-hide");
		var spinner = cmp.find("cmspinnernew");
        $A.util.addClass(spinner, "slds-hide");
		var spinner = cmp.find("cmspinneredit");
        $A.util.addClass(spinner, "slds-hide");
		cmp.set('v.editFormSubmitting ', false);
	}
})