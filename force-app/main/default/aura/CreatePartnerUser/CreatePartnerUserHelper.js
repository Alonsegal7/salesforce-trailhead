({
	callbackInit : function(component) {   
		var contactRec = component.get("v.initialContact");
        var action = component.get('c.getFieldsList'); //this also checks for existing user with same email
        action.setParams({
			contactId: component.get("v.recordId"),
			email: contactRec.Email,
			accountId: contactRec.AccountId,
			isPartner: contactRec.Account.IsPartner,
			approvalStatus: contactRec.Approval_Status_Partner_Users__c
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
		contactToUpdate['OwnerId'] = component.get("v.managerId");
		contactToUpdate['Id'] = component.get("v.recordId");
		contactToUpdate['Send_Welcome_Email__c'] = component.get("v.sendWelcomeEmail");
		var action = component.get('c.submitNewUserRequest'); //this also checks for existing user with same email
        action.setParams({
			contactId: component.get("v.recordId"),
			contactToUpdate: contactToUpdate,
			approvalStatus: component.get("v.initialContact").Approval_Status_Partner_Users__c,
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
			var errMsg = '';
            if(state == "SUCCESS"){
                var newUser = response.getReturnValue();
				component.set("v.screen1", false);
				if(newUser == null){
					component.set("v.screen3", true);
				} else {
					component.set("v.newUser", newUser);
					component.set("v.screen2", true);
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

	updateAttribute: function(component, event, attributeName) { 
        var fieldName = event.getSource().get("v.fieldName");
        var fieldValue = event.getSource().get("v.value");
        var attributeVar = component.get(attributeName);
        attributeVar[fieldName] = fieldValue;
        component.set(attributeName, attributeVar);  
    },
})