({
	callbackInit : function(component) {   
        var action = component.get('c.getFieldsList'); //this also checks for existing user with same email
        action.setParams({
			contactId: component.get("v.recordId"),
			email: component.get("v.initialContact").Email
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
			var errMsg = '';
            if(state == "SUCCESS"){
                var storeResponse = response.getReturnValue();
				if (!$A.util.isEmpty(storeResponse) && (!$A.util.isEmpty(storeResponse.existingUserId) || !$A.util.isEmpty(storeResponse.contactFieldNamesList))){
					if(!$A.util.isEmpty(storeResponse.existingUserId)){
						component.set("v.existingUserId", storeResponse.existingUserId);
					} else {
						component.set("v.contactFieldNamesList", storeResponse.contactFieldNamesList);
						component.set("v.managerId", $A.get("$SObjectType.CurrentUser.Id"));
						component.set("v.screen1", true);
					}
				} else {
					errMsg = 'Server issue loading contact field names from CMT.';
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
			var spinner = component.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
		var spinner = component.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
    },

	callbackCreateNewUser: function(component) {   
		var contactToUpdate = component.get("v.contactToUpdate");
		if($A.util.isEmpty(contactToUpdate)) {
			contactToUpdate = null;
		} else {
			contactToUpdate['Id'] = component.get("v.recordId");
		}
		var action = component.get('c.createUser'); //this also checks for existing user with same email
        action.setParams({
			contactId: component.get("v.recordId"),
			contactToUpdate: contactToUpdate,
			managerId: component.get("v.managerId")
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
			var errMsg = '';
            if(state == "SUCCESS"){
                var newUserId = response.getReturnValue();
				component.set("v.newUserId", newUserId);
				component.set("v.screen1", false);
				component.set("v.screen2", true);
            } else {
				let err = response.getError();
				if (err && Array.isArray(err)) {
					errMsg = 'Error: ' + err[0].message;
				} else {
					errMsg = 'Unknown error occured.';
				}
				component.set("v.errMsg", errMsg);
            }
			var spinner = component.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
		var spinner = component.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},

	updateAttribute: function(component, event, attributeName) { 
        var fieldName = event.getSource().get("v.fieldName");
        var fieldValue = event.getSource().get("v.value");
        var attributeVar = component.get(attributeName);
        attributeVar[fieldName] = fieldValue;
        component.set(attributeName, attributeVar);  
    },
})