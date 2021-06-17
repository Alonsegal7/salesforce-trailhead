({
	doInit: function(component, event, helper) {
        try {
            component.set("v.spinner", true);
            helper.callbackInit(component, event, helper);
        } catch(err) {
            component.set("v.errMsg", 'Component Error: ' + err.message);
            component.set("v.spinner", false);
        }
    },

    createNewUser: function(component, event, helper) {
        var allValid = true;
        component.find('field').forEach(function checkValidity(field) {
            if($A.util.isEmpty(field.get("v.value"))) {
                allValid = false;
            }
        });
        if (allValid) {
            try {
                component.set("v.spinner", true);
                component.set("v.fieldsValidationError", '');
                helper.callbackCreateNewUser(component, event, helper);
            } catch(err) {
                component.set("v.errMsg", 'Component Error: ' + err.message);
                component.set("v.spinner", false);
            }
        } else {
            component.set("v.fieldsValidationError", 'Please update the invalid form entries and try again.');
        }
    },

    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    closeModalRefreshView: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    updateContactRecord: function(component, event, helper) { 
        helper.updateAttribute(component, event, "v.contactToUpdate");
    },

    updateManagerId: function(component, event, helper) { 
        helper.updateAttribute(component, event, "v.managerId");
    },
})