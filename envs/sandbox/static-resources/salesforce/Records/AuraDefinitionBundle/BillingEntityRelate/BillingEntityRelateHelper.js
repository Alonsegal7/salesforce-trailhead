({
	loadInitialParameters : function(cmp, evt){
		var oppId = cmp.get('v.recordId');
		var action = cmp.get("c.getInitialParameters");
        action.setParams({ "oppId" : oppId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (!this.isEmpty(storeResponse)){
                    storeResponse = JSON.parse(storeResponse);
					console.log('Init call response: ' + storeResponse);
					if (storeResponse.hasOwnProperty('bestMatch')) {
						cmp.set('v.list_best_match', storeResponse.bestMatch);
						for (var i = 0; i < storeResponse.bestMatch.length; i++){
							if (storeResponse.bestMatch[i].selected) cmp.set('v.currently_selected', storeResponse.bestMatch[i].bEId);
							console.log('Selected by default: ' + cmp.get('v.currently_selected'));
						}
					}
					if (storeResponse.hasOwnProperty('moreOptions')) {
						cmp.set('v.list_more_options', storeResponse.moreOptions);
					}
					if (storeResponse.hasOwnProperty('newFormFields') && storeResponse.newFormFields.length > 0) {
						cmp.set('v.form_new_fields', storeResponse.newFormFields);
						cmp.set('v.enable_form_new', true);
					}
                }else{
                    
                }   
            }
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},
	testUniqu : function(cmp, evt){
		var fields = evt.getParam("fields");
		console.log('fields: ' + JSON.stringify(fields));
		if (!this.isEmpty(fields)){
			var action = cmp.get("c.testUniquness");
			action.setParams({
                "vatNumber": fields.VAT_Number__c,
                "cName": fields.Name,
                "cCountry": fields.Country__c,
                "cCity": fields.City__c,
                "cBillingCurrency": fields.CurrencyIsoCode 
            });
            
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var storeResponse = response.getReturnValue();
					console.log('Uniquness test: ' + storeResponse);
					if (!this.isEmpty(storeResponse)){
						cmp.set('v.selected_be', JSON.parse(storeResponse));
						cmp.set('v.form_new', false);
					}else{
						var mainForm = cmp.find('mainBEForm');
						mainForm.submit(fields);
					}   
				}
				var spinner = cmp.find("cmspinnernew");
				$A.util.removeClass(spinner, "slds-hide");
			});
			var spinner = cmp.find("cmspinnernew");
			$A.util.removeClass(spinner, "slds-hide");
			$A.enqueueAction(action);
		}
	},
	relate : function(cmp, evt){
		var oppId = cmp.get('v.recordId');
		var beId = cmp.get('v.currently_selected');
		if (this.isEmpty(beId)){
			beId = cmp.get('v.selected_be');
			if (!this.isEmpty(beId)){
				beId = beId.val;
			}
		}

		var action = cmp.get("c.doRelate");
        action.setParams({ "oppId" : oppId, "BEId" :  beId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (this.isEmpty(storeResponse)){
					$A.get('e.force:refreshView').fire();
					$A.get("e.force:closeQuickAction").fire();
                }else{
                    //cmp.set('v.message', storeResponse);
					cmp.find('notifLib').showToast({
						"title": 'Error!',
						"variant": 'error',
						"mode":"sticky",
						"message": storeResponse
					});	
                }   
            }
            var spinner = cmp.find("cmspinner");
        	$A.util.addClass(spinner, "slds-hide");
        });
        var spinner = cmp.find("cmspinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.enqueueAction(action);
	},
	isEmpty : function (obj){
		return (obj == null || typeof(obj) == 'undefined' || obj == '' || obj == 'undefined');
	}
})