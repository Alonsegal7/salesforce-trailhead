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

    handleSave: function(component, event, helper) {
        try {
            component.set("v.spinner", true);
            helper.callbackSave(component, event, helper);
        } catch(err) {
            component.set("v.errMsg", 'Component Error: ' + err.message);
            component.set("v.spinner", false);
        }
    },

    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleChampSelected: function(component, event, helper) {
        component.set("v.selectedChamps", event.getParam("value"));
        console.log('selected Champs: ' + component.get("v.selectedChamps"));
    },
})
