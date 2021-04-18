({
	getInitials: function (cmp, evt) {
		var action = cmp.get("c.getInitialParams");
        action.setParams({ "cId" : cmp.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
			var errFound = false;
			var success = false;
			var errMsg = '';

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse: ' + JSON.stringify(storeResponse));
                if (!this.isEmpty(storeResponse)){
                    if (!this.isEmpty(storeResponse.user_error)){
						errMsg += storeResponse.user_error;
						errFound = true;
					}
					if (!this.isEmpty(storeResponse.contact_error)){
						if (errFound) errMsg += '. Also, '
						errMsg += storeResponse.contact_error;
						errFound = true;
					}
					if (!this.isEmpty(storeResponse.account_error)){
						if (errFound) errMsg += '. And, '
						errMsg += storeResponse.account_error;
						errFound = true;
					}
					if (!this.isEmpty(storeResponse.create_message)){
						if (storeResponse.create_message.indexOf('OK') == 0){
                            errMsg = '/lightning/r/User/' + storeResponse.create_message.split(':')[1] + '/view';
							success = true;
						} else {
							errMsg = storeResponse.create_message;
                            errFound = true;
						}
					}
					cmp.set('v.hasError', errFound);
					cmp.set('v.hasSuccess', success);
					cmp.set('v.errMsg', errMsg);
                }else{
                    console.log('Server issue loading initial params');
                }   
            } else {
				let err = response.getError();
				if (err && Array.isArray(err)) console.log('Error loading initial params: ' + err[0].message);
			}
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},
	isEmpty : function(obj){
		return (obj == null || typeof(obj) == 'undefined' || obj == '' || obj == 'undefined');
	}
})