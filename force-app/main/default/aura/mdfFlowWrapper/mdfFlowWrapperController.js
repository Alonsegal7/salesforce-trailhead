({
    statusChange : function (component, event) {
        if (event.getParam('status') === 'FINISHED') {
            component.set("v.displayModal", !component.get("v.displayModal"));
        };
    },
    handleClick : function(component, event, helper) {
        helper.toggleModal(component);
    }
})