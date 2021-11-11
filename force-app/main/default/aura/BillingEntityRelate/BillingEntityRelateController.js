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
		if(cmp.get('v.getVatServiceStatus') == 'Active'){
			if(cmp.get('v.customerVatNumber') == 'Yes'){
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
		//evt.stopPropagation();
		//evt.preventDefault();
		//hlp.testUniqu(cmp, evt);
	},
	handleSuccess : function (cmp, evt, hlp) {
		console.log('in success: ' + id);
		var payload = evt.getParams().response;
		var id = payload.id;
		console.log('Saved Billing Entity Id: ' + id);
		//Start Tal - VAT Logic
		if(cmp.get('v.getVatServiceStatus') == 'Active'){
			cmp.set('v.beIdAfterSuccess', id);
			hlp.updateBillingEntityFieldsFromCreate(cmp, evt);
		}
		//End Tal - VAT Logic
		cmp.set('v.currently_selected', id);
		cmp.find('notifLib').showToast({
			"title": 'Success!',
			"variant": 'success',
			"mode":"dismissable",
			"message": 'Billing Entity successfully created'
		});
		hlp.relate(cmp, evt);
	},
	handleEditSuccess : function (cmp, evt, hlp) {
		var payload = evt.getParams().response;
		var id = payload.id;
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
		var toggleValue = component.get("v.toggleChecked");

		if(toggleValue == true){
			if(txtValField === 'Name'){
				component.set('v.shipToName', target.get("v.value"));
			}
	
			if(txtValField ==='Country__c'){
				component.set('v.shippingCountry', target.get("v.value"));
			}

			if(txtValField === 'Billing_State__c'){
				component.set('v.shippingState', target.get("v.value"));
			}
	
			if(txtValField === 'City__c'){
				component.set('v.shippingCity', target.get("v.value"));
			}
	
			if(txtValField === 'Street__c'){
				component.set('v.shippingStreet', target.get("v.value"));
			}
	
			if(txtValField === 'Zip_Postal_Code__c'){
				component.set('v.shippingZipCode', target.get("v.value"));
			}
		}
	},
	//End Tal

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