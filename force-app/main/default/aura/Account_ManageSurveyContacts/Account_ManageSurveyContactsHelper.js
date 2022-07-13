({
    callbackInit : function(component) {   
        var action = component.get('c.getAllContacts'); 
        action.setParams({
			accountId: component.get("v.recordId")
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                var storeResponse = response.getReturnValue();
                console.log('getAllContacts data: ' + JSON.stringify(storeResponse));
                if (storeResponse != null){
                    component.set("v.contactsOptions",storeResponse.contacts_options);
                    console.log('getAllContacts contacts_options: ' + JSON.stringify(component.get("v.contactsOptions")));
                    component.set("v.selectedChamps",storeResponse.selected_champs);
                    component.set("v.originallySelected",storeResponse.selected_champs);
                    console.log('getAllContacts selectedChamps: ' + JSON.stringify(component.get("v.originallySelected")));
                }  else {
					errMsg = 'Oops... Server issue loading opportunity data (storeResponse is null in callbackInit). Please reach out to Biz Ops.';
					component.set("v.errMsg", errMsg);
				}
            } else {
				let err = response.getError();
				if (err && Array.isArray(err)) {
					errMsg = 'Error: ' + err[0].message;
				} else {
					errMsg = 'Unknown error occured.';
				}
				component.set("v.errMsg", errMsg);
            }
			component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },

    callbackSave : function(component) {  
        var all_contacts = {};
        all_contacts['originally_selected'] = component.get("v.originallySelected");
        all_contacts['currently_selected'] = component.get("v.selectedChamps");
        var action = component.get('c.saveContacts'); 
        action.setParams({
			contacts_map: all_contacts
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success!',
                    message: 'CSM Champions updated successfuly!',
                    variant: 'success'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else {
				let err = response.getError();
				if (err && Array.isArray(err)) {
					errMsg = 'Error: ' + err[0].message;
				} else {
					errMsg = 'Unknown error occured.';
				}
				component.set("v.errMsg", errMsg);
            }
			component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
})