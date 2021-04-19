({
    
    cloneOpp: function (component, fields){
        console.log('Helper cloneOpp')
        let action = component.get("c.cloneOpportunityWithContent");
        action.setParams({
            opp: fields,
            sourceOppRecordId : component.get("v.recordId")
        });
        
        this.showSpinner(component);
        debugger;
        action.setCallback( this, function( response ) {
            let state = response.getState();
			if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                this.navigateToRecord(response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.error('ERROR');
                this.handleErrors(component, [{message: 'Unable to clone the opportunity due to network error'}]);
            }
            else if (state === "ERROR") {
                console.error(response.getError());
                this.handleErrors(component, response.getError(), 'info');
            }
            this.hideSpinner(component);
        } );

        $A.enqueueAction(action);    
    },
    
    navigateToRecord: function ( recordId ) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();	
    },
    
    handleErrors: function (component, errors, type, closeCallback){
        
        let msgText = 'Unknown error';
		let variant = 'error';
        
        if(type){
            variant = type;
        }

        if (errors && Array.isArray(errors) && errors.length > 0) {
            msgText = errors[0].message;
        }
        
        console.error(msgText);
        
        component.find('notifLib').showNotice({
            "variant": variant,
            "header": variant == "error" ? "Something has gone wrong!" : "Information",
            "message": msgText,
            closeCallback: closeCallback ? closeCallback : null 
        });
    },
    
   showSpinner : function( component ) {

        $A.util.removeClass( component.find( 'spinner' ), 'slds-hide' );

    },

    hideSpinner : function( component ) {

        $A.util.addClass( component.find( 'spinner' ), 'slds-hide' );

    },

})