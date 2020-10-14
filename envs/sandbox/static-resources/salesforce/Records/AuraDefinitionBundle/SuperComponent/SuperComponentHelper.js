/**
 * Created by anastasiyakovalchuk on 2019-02-17.
 */
({
    init: function() {},
    
    testConsole: function(cmp) {
        console.log('sdsds');
    },
    
    attribute: function(cmp, attrName, value) {
        if (value === undefined) {
            return cmp.get(attrName);
        }
        cmp.set(attrName, value);
    },
    /* Get/Set */
    recordId: function(cmp, value) {
        return this.attribute(cmp, 'v.recordId', value);
    },
    isLoading: function(cmp, value) {
        return this.attribute(cmp, 'v.isLoading', value);
    },
    getRecordId: function(cmp) {
        return this.recordId(cmp);
    },
    /* END Get/Set */
    
    navigateToURL: function(url) {
        if (url) {
            var urlEvent = $A.get('e.force:navigateToURL');
            urlEvent.setParams({
                url: url
            });
            urlEvent.fire();
        }
    },

    navigateToURLRecordId : function (recordId) {
        if (recordId) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": recordId
            });
            navEvt.fire();
        }
    },
    
    executeApex: function(cmp, params, options) {
        var self = this;
        var defaultOptions = {
            withLoader: false,
            isStorable: false,
            withResponseObj: true,
            apexAction: 'execute' 
        };
        options = Object.assign({}, defaultOptions, options);
        var apexAction = options.apexAction;
        
        if (options.withLoader) {
            self.showLoader(cmp);
        }
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = cmp.get('c.' + apexAction);
                action.setParams(params);
                if (options.isStorable) {
                    action.setStorable();
                }
                action.setCallback(this, function(callbackResult) {
                    if (options.withLoader) {
                        self.hideLoader(cmp);
                    }
                    if (callbackResult.getState() === 'SUCCESS') {
                        var resp = callbackResult.getReturnValue();
                        if (!options.withResponseObj) {
                            return resolve(resp);
                        }
                        if (resp.isSuccess) {
                            return resolve(resp.responseObj);
                        } else {
                            console.log('ERROR in ' + apexAction + ' call', resp.message);
                            return reject(resp.message);
                        }
                    }
                    if (callbackResult.getState() === 'ERROR') {
                        console.log('ERROR', callbackResult.getError());
                        return reject(callbackResult.getError());
                    }
                });
                $A.enqueueAction(action);
            })
        );
    },
    
    /**
   *
   * @param {Object} cmp - component
   * @param {Object[]} batchArr - Array of batch items
   * @param {Object} options - options
   * @returns {Promise} promise
   */
    requestBatchApex: function(cmp, batchArr, options) {
        var self = this;
        var defaultOptions = {
            withLoader: false
        };
        options = Object.assign({}, defaultOptions, options);
        
        if (options.withLoader) {
            self.showLoader(cmp);
        }
        var batchPromises = batchArr.map(function(item) {
            return self.executeApex(cmp, item.reqParams, item.options);
        });
        return Promise.all(batchPromises)
        .then(function(data) {
            if (options.withLoader) {
                self.hideLoader(cmp);
            }
            return data;
        })
        .catch(function(err) {
            if (options.withLoader) {
                self.hideLoader(cmp);
            }
            throw err;
        });
    },
    
    navigateToSobject: function(recordId) {
        if (recordId) {
            var navEvt = $A.get('e.force:navigateToSObject');
            navEvt.setParams({
                recordId: recordId
            });
            navEvt.fire();
        }
    },
    
    showToast: function(options) {
        var message = options.message;
        if (typeof message !== 'string') {
            if (typeof message === 'object' && message.message) {
                options.message = message.message;
            } else {
                options.message = JSON.stringify(message);
            }
        }
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams(options);
        toastEvent.fire();
    },
    
    showLoader: function(cmp) {
        this.isLoading(cmp, true);
    },
    
    hideLoader: function(cmp) {
        this.isLoading(cmp, false);
    },
    
    buildOptions: function(labelsArr) {
        return labelsArr.map(function(label) {
            return {
                label: label,
                value: label
            };
        });
    },

    showConfirmWindow : function(cmp, actionId, theme, title, message) {
            $A.createComponent("c:ConfirmBox", {
                "actionId"		 : actionId,
                "theme"			 : theme,
                "title"			 : title,
                "message"   : message
            },
           function(newList, status, errorMessage) {
               if (status == "SUCCESS") {
                   var container = cmp.find("confirmBoxContainer");
                   container.set("v.body", "");
                   var body = container.get("v.body");
                   body.push(newList);
                   container.set("v.body", body);
               }
           });
    },

    closeQuickAction: function() {
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    },
});