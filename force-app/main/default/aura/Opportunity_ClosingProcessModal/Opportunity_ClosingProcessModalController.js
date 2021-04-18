({
    doInit : function (component, event, helper){
        component.set('v.stage_ClosedLost', 'Closed Lost');
        console.log('### check: ' + component.get('v.stage_ClosedLost'));
        //==============
        var oppId = cmp.get('v.recordId');
		var action = cmp.get("c.getOpportunityFields");
        action.setParams({ "oppId" : oppId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				console.log('### storeResponse: ' + storeResponse);
				console.log('### isEmpty: ' + this.isEmpty(storeResponse));
            }
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
    },

    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        component.find("overlayLib").notifyClose();
    },
    
    handleOK : function(component, event, helper) {
        //do something
    }
})