({
	doInit: function (cmp, evt, hlp) {
		console.log('Billing Entity Relate Initializing...');
		hlp.isVATrequiresChecking(cmp, evt);
		hlp.loadInitialParameters(cmp, evt);
	},
	modeChanged : function(cmp, evt, hlp){
		cmp.set('v.currently_selected' , null);
		cmp.set('v.selection_mode', evt.getSource().get('v.label').toLowerCase());
	},
	cbChanged : function(cmp, evt, hlp){
		var source = evt.getSource();
		var sourceName = source.get('v.name');
		var currently_selected = cmp.get('v.currently_selected');
		if (currently_selected == sourceName) {
			cmp.set('v.currently_selected' , null);
		} else {
			cmp.set('v.selected_be', '');
			cmp.set('v.currently_selected' , sourceName);
			cmp.set('v.selection_mode', 'choose existing');
		}
	},
	beChanged : function(cmp, evt, hlp){
		var selectedBE = cmp.get('v.selected_be');
		cmp.set('v.currently_selected', null);
		cmp.set('v.selection_mode', 'search');
	},
	openNew : function(cmp, evt, hlp){
		cmp.set('v.form_new', true);
		cmp.set('v.selected_best_match', null);
		cmp.set('v.selected_more_option', null);
		cmp.set('v.selected_be', '');
		cmp.set('v.currently_selected', null);
		cmp.set('v.selection_mode', '');
	},
	closeNew : function(cmp, evt, hlp){
		cmp.set('v.form_new', false);
	},
	openEdit : function(cmp, evt, hlp){
		let beId = cmp.get('v.latest_be').val;
		cmp.set('v.beToUPdate', beId);
		console.log('Opening edit for: ' + beId);
		hlp.loadBEforEdit(cmp, evt, beId);
		cmp.set('v.edit_existing', true);
	},
	closeEdit : function(cmp, evt, hlp){
		cmp.set('v.edit_existing', false);
	},
	handleSubmit : function (cmp, evt, hlp) {
		var radioButtonValue = cmp.get("v.radioValue");
		evt.stopPropagation();
		evt.preventDefault();
		var spinner = cmp.find("cmspinneredit");
		$A.util.removeClass(spinner, "slds-hide");
		//Start Tal - VAT Logic
		console.log('Submitting and service status is: ' + cmp.get('v.getVatServiceStatus'));
		console.log('Submitting and customer vat number is: ' + cmp.get('v.customerVatNumber'));
		
		if(cmp.get('v.getVatServiceStatus') == 'Active'){
			if(cmp.get('v.customerVatNumber') == 'Yes' || cmp.get('v.qstQ')){
				hlp.callVatService(cmp,evt);
			}
			else{
				hlp.testUniqu(cmp, evt);
			}
		}

		else{
			hlp.testUniqu(cmp, evt);
		}
		//End Tal - VAT Logic
	},
	handleEditSubmit : function (cmp, evt, hlp) {
		console.log('Edit Billing Entity form attempt submit');
		cmp.set('v.editFormSubmitting', true);
		var spinner = cmp.find("cmspinneredit");
		$A.util.removeClass(spinner, "slds-hide");
		evt.stopPropagation();
		evt.preventDefault();
		hlp.callVatService(cmp, evt, 'edit');
		//hlp.testUniqu(cmp, evt);
	},
	handleSuccess : function (cmp, evt, hlp) {
		console.log('in success');
		var payload = evt.getParams().response;
		var id = payload.id;
		console.log('Saved Billing Entity Id: ' + id);

		cmp.set('v.currently_selected', id);

		//Start Tal - VAT Logic
		if(cmp.get('v.getVatServiceStatus') == 'Active'){
			cmp.set('v.beIdAfterSuccess', id);
			hlp.updateBillingEntityFieldsFromCreate(cmp, evt);
		}
		//End Tal - VAT Logic
		
		cmp.find('notifLib').showToast({
			"title": 'Success!',
			"variant": 'success',
			"mode":"dismissable",
			"message": 'Billing Entity successfully created'
		});
		hlp.relate(cmp, evt);
	},
	handleEditSuccess : function (cmp, evt, hlp) {
		console.log('In edit success');
		var payload = evt.getParams().response;
		var id = payload.id;
		let opp = cmp.get('v.loadedOpp');
		console.log('BE Id: ' + id);
		console.log('Opp.Billing_Entity__c: ' + opp.Billing_Entity__c);
		cmp.set('v.currently_selected', id);
		if (id != opp.Billing_Entity__c){
			hlp.relate(cmp, evt);
		}
		cmp.set('v.editFormSubmitting', false);
		$A.get("e.force:closeQuickAction").fire();
		$A.get('e.force:refreshView').fire();
	},
	handleError : function (cmp, evt, hlp) {
		console.log('Error here');
        var payload = evt.getParams().response;
		var errors = evt.getParams();
        var errorMessage = 'An error had occured on the server. If this problem persist, please contact your Administrator';
        console.log('Payload >>>> ' + payload);    
        console.log('errors >>>> ' + JSON.stringify(errors));
        if (errors && errors.hasOwnProperty('message')){
            errorMessage = errors.message;
        }
        cmp.find('notifLib').showNotice({
            "variant": "error",
            "header": "Something has gone wrong!",
            "message": errorMessage
        });
        var spinner = cmp.find("cmspinnernew");
		$A.util.addClass(spinner, "slds-hide");
        spinner = cmp.find("cmspinner");
		$A.util.addClass(spinner, "slds-hide");
	},
	handleEditError : function (cmp, evt, hlp) {
		console.log('Error here');
        var payload = evt.getParams().response;
		var errors = evt.getParams();
        var errorMessage = 'An error had occured on the server. If this problem persist, please contact your Administrator';
        console.log('Payload >>>> ' + payload);    
        console.log('errors >>>> ' + JSON.stringify(errors));
        if (errors && errors.hasOwnProperty('message')){
            errorMessage = errors.message;
        }
        cmp.find('notifLib').showNotice({
            "variant": "error",
            "header": "Something has gone wrong!",
            "message": errorMessage
		});
		cmp.set('v.editFormSubmitting', false);
        var spinner = cmp.find("cmspinneredit");
		$A.util.addClass(spinner, "slds-hide");
        spinner = cmp.find("cmspinner");
		$A.util.addClass(spinner, "slds-hide");
	},
	relate : function(cmp, evt, hlp){
		//Start Tal - VAT Logic
		if(cmp.get('v.getVatServiceStatus') == 'Active'){
			if(cmp.get('v.endPoint_duplicate') == false){
				hlp.checkVATBeforeRelate(cmp, evt);
			}
			else{
				hlp.relate(cmp, evt);
			}
		}
		//End Tal - VAT Logic

		else{
			hlp.relate(cmp, evt);
		}
	},
    closeDialog : function(){
    	$A.get("e.force:closeQuickAction").fire();
	},
	validationListItemClicked : function(cmp, evt, hlp){
		var target = evt.getSource();
		var BEId = target.get('v.label');
		var BEName = target.get('v.text');
		console.log('BEId: ' + BEId);
		console.log('BEName: ' + BEName);
		var selectedBE = {};
		selectedBE.val = BEId;
		selectedBE.text = BEName;
		cmp.set('v.temp_selected_be', selectedBE);
		cmp.set('v.enableSet', true);
		//Start Tal - VAT Logic
		cmp.set('v.billingEntityId', BEId);
		//End Tal - VAT Logic
	},
	setSelectedToMain : function(cmp, evt, hlp){
		//Start Tal - VAT Logic
		cmp.set('v.endPoint_duplicate', true);
		hlp.updateBillingEntityFields(cmp, evt);
		//End Tal - VAT Logic
		cmp.set('v.selected_be', cmp.get('v.temp_selected_be'));
		cmp.set('v.enableSet', false);
		cmp.set('v.temp_selected_be', null);
		cmp.set('v.form_new', false);
		cmp.set('v.showAltPopup', false);
		cmp.set('v.invalidVATForm', false);
	},
	closeAltPopup : function(cmp, evt, hlp){
		cmp.set('v.temp_selected_be', null);
		cmp.set('v.enableSet', false);
		cmp.set('v.showAltPopup', false);
		cmp.set('v.allowSubmit', false);
	},
	submitOriginal : function(cmp, evt, hlp){
		var fields = cmp.get('v.formFieldsToSubmit');
		var mainForm = cmp.find('mainBEForm');
		console.log('Submitting');
		try{
			mainForm.submit(fields);
			cmp.set('v.showAltPopup', false);
		} catch (err){
			console.log('Error submitting: ' + err);
		}
	},
	//Start Tal	
	handleToggleChanged : function (component, event, helper) {
		var target = event.getSource();
		var txtValField = target.get("v.fieldName");
		var selectedValue = target.get("v.value");
		var toggleValue = component.get("v.toggleChecked");
		var hasSO = component.get("v.hasPartnerSO");
		var formNewShippingFields = component.get("v.form_new_shipping_fields");
		var formNewFields = component.get("v.form_new_fields");
		var shippingFiled = '';

		console.log('Toggle: ' + toggleValue);
		console.log('selectedValue: ' + selectedValue);
		console.log('Field name: ' + txtValField);
		if (!toggleValue){
			if (txtValField == 'Shipping_Country_G__c'){
				component.set('v.isCanada', (selectedValue == 'Canada'));
			}
			if (txtValField == 'Shipping_State__c'){
				component.set('v.isQuebec', (selectedValue == 'Quebec'));
			}

			if (selectedValue == 'sync'){
				for (let j = 0; j < formNewShippingFields.length; j++){
					formNewShippingFields[j].val = null;
				}
				component.set("v.form_new_shipping_fields", formNewShippingFields);
				let vf = component.find('vatValue');
				if (!helper.isEmpty(vf)){
					vf.set('v.value', null);
				}
				component.set('v.shipToName', null);
				component.set('v.shippingCountry', null);
				component.set('v.shippingState', null);
				component.set('v.shippingCity', null);
				component.set('v.shippingStreet', null);
				component.set('v.shippingZipCode', null);
			}
		}

		if(toggleValue == true){
			if(txtValField === 'Name'){
				component.set('v.shipToName', target.get("v.value"));
				shippingFiled = 'Ship_To_Name__c';
			}
	
			if(txtValField ==='Country__c'){
				component.set('v.shippingCountry', target.get("v.value"));
				component.set('v.isCanada', (selectedValue == 'Canada'));
				shippingFiled = 'Shipping_Country_G__c';
			}

			if(txtValField ==='Shipping_Country_G__c'){
				component.set('v.isCanada', (selectedValue == 'Canada'));
				shippingFiled = 'Shipping_Country_G__c';
			}

			if(txtValField === 'Billing_State__c'){
				component.set('v.shippingState', target.get("v.value"));
				component.set('v.isQuebec', (selectedValue == 'Quebec'));
				shippingFiled = 'Shipping_State__c';
			}

			if(txtValField === 'Shipping_State__c'){
				component.set('v.isQuebec', (selectedValue == 'Quebec'));
				shippingFiled = 'Shipping_State__c';
			}
	
			if(txtValField === 'City__c'){
				component.set('v.shippingCity', target.get("v.value"));
				shippingFiled = 'Shipping_City__c';
			}
	
			if(txtValField === 'Street__c'){
				component.set('v.shippingStreet', target.get("v.value"));
				shippingFiled = 'Shipping_Street__c';
			}
	
			if(txtValField === 'Zip_Postal_Code__c'){
				component.set('v.shippingZipCode', target.get("v.value"));
				shippingFiled = 'Shipping_Zip_Postal_Code__c';
			}
			if (hasSO && formNewShippingFields != null && Array.isArray(formNewShippingFields)){
				if (selectedValue == 'sync'){
					for (let i = 0; i < formNewFields.length; i++){
						for (let j = 0; j < formNewShippingFields.length; j++){
							if (formNewFields[i].name == 'Name' && formNewShippingFields[j].name == 'Ship_To_Name__c') {
								formNewShippingFields[j].val = formNewFields[i].val;
								break;
							}
							if (formNewFields[i].name == 'Country__c' && formNewShippingFields[j].name == 'Shipping_Country_G__c') {
								formNewShippingFields[j].val = formNewFields[i].val;
								break;
							}
							if (formNewFields[i].name == 'Billing_State__c' && formNewShippingFields[j].name == 'Shipping_State__c') {
								formNewShippingFields[j].val = formNewFields[i].val;
								break;
							}
							if (formNewFields[i].name == 'City__c' && formNewShippingFields[j].name == 'Shipping_City__c') {
								formNewShippingFields[j].val = formNewFields[i].val;
								break;
							}
							if (formNewFields[i].name == 'Street__c' && formNewShippingFields[j].name == 'Shipping_Street__c') {
								formNewShippingFields[j].val = formNewFields[i].val;
								break;
							}
							if (formNewFields[i].name == 'Zip_Postal_Code__c' && formNewShippingFields[j].name == 'Shipping_Zip_Postal_Code__c') {
								formNewShippingFields[j].val = formNewFields[i].val;
								break;
							}
						}
					}
					component.set("v.form_new_shipping_fields", formNewShippingFields);
				} else {
					for (let i = 0; i < formNewShippingFields.length; i++){
						if (formNewShippingFields[i].name == shippingFiled){
							formNewShippingFields[i].val = selectedValue;
							component.set("v.form_new_shipping_fields", formNewShippingFields);
							break;
						}
					}
				}
			}
		}
	},
	//End Tal
    handleEditFieldChange : function(cmp, evt, hlp){
        var target = evt.getSource();
		var txtValField = target.get("v.fieldName");
		var selectedValue = target.get("v.value");
        if(txtValField ==='Shipping_Country_G__c'){
            cmp.set('v.edit_shipping_country', selectedValue);
        }
        
        if(txtValField === 'Shipping_State__c'){
            cmp.set('v.edit_shipping_state', selectedValue);
        }
    },

	//Start Tal - VAT Logic
	updateRequiredVAT : function(component, event, helper){
        var requiredVat = event.getParam('value');
        component.set('v.customerVatNumber', requiredVat);
        event.preventDefault();
    },
	//End Tal - Vat Logic

	//Start Tal - VAT Logic
    closeModal : function(component, event, helper) {
        component.set('v.showVatErrorCmp', false);
	},

	closeInvalidModal : function(cmp, evt){
		cmp.set('v.invalidVATForm', false);
	},
	
	updateVatNumberValue : function(cmp, evt){
		var vatNum = evt.getParam('value');
		cmp.set('v.vatNumberValue', vatNum);
	}
    //End Tal - VAT Logic
})