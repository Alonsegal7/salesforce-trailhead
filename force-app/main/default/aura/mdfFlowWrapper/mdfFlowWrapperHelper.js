({
    toggleModal : function(component) {
        component.set("v.displayModal", !component.get("v.displayModal"));
        if(component.get("v.displayModal")){
            var flow = component.find("flowData");
            flow.startFlow("Submit_Marketing_Activity");
        }
    }
})