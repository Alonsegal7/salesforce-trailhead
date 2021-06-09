({
    cloneOpportunity: function(component, event, helper) {
        // stop the form from submitting since we are going to clone the opportunity 
        // so it will be done in the server side action
        event.preventDefault();       
        
        var fields = event.getParam("fields");
        //fields["Id"] = component.get("v.recordId");
        console.log(JSON.stringify(fields))
       	helper.cloneOpp(component, fields);
    },
  
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    navigateToOpp : function( component, event, helper ) {
        helper.navigateToRecord(component.get("v.clonedOppRecordId"));
    },
})