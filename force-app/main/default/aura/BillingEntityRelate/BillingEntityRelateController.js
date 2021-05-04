({
	doInit: function (cmp, evt, hlp) {
		console.log('Billing Entity Relate Initializing...');
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
		hlp.testUniqu(cmp, evt);
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
		var payload = evt.getParams().response;
		var id = payload.id;
		console.log('Saved Billing Entity Id: ' + id); 
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
		hlp.relate(cmp, evt);
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
	},
	setSelectedToMain : function(cmp, evt, hlp){
		cmp.set('v.selected_be', cmp.get('v.temp_selected_be'));
		cmp.set('v.enableSet', false);
		cmp.set('v.temp_selected_be', null);
		cmp.set('v.form_new', false);
		cmp.set('v.showAltPopup', false);
	},
	closeAltPopup : function(cmp, evt, hlp){
		cmp.set('v.temp_selected_be', null);
		cmp.set('v.enableSet', false);
		cmp.set('v.showAltPopup', false);
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
		console.log('W### Here');
		// if(txtValField === 'VAT_Number__c'){
		// 	var target_v2 = event.getSource();
		// 	var searchText = target_v2.value;
		// 	console.log('W### target_v2: ' + target_v2);
		// 	console.log('$$$ searchText: ' + searchText);
        //     var objectName = component.get("v.objectName");
		// 	var VATno = txtValField;
		// 	var VATvalue = target.get("v.value");
		// 	var limit = component.get("v.limit");
		// 	console.log('### VATno: ' + VATno);
		// 	console.log('### VATvalue: ' + VATvalue);
        //     var action = component.get("c.searchDB");
        //     action.setStorable();
            
        //     action.setParams({
		// 		objectName : objectName,
		// 		searchText : searchText,
		// 		lim : limit,
		// 		VATvalue : VATvalue,
        //         VATno : VATno
        //     });

        //     action.setCallback(this,function(a){
		// 		console.log('@@@ Handler: ');
        //         // this.handleResponse(a, component, helper);
        //     });
            
        //     console.log('Server call made');
        //     $A.enqueueAction(action);
		// }

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
	}
	//End Tal
})