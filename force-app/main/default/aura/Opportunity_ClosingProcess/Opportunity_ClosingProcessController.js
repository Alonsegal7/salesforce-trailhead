({
    doInit: function(component, event, helper) {
        try {
            component.set("v.showSpinner", true);
            helper.callbackInit(component, event, helper);
        } catch(err) {
            component.set("v.errMsg", 'Component Init Error: ' + err.message);
            component.set("v.showSpinner", false);
            component.find('notifLib').showToast({
                "variant": "error",
                "title": "Error occured in init Opportunity_ClosingProcess. Please notify Biz Ops.",
                "message": err.message         
            });
        }
    },

    closeModal : function(component, event, helper) {
        helper.endProcess(component, event, helper);
    },

    handleStageSelected : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        //if the stage is Closed Won or Closed Lost we display the modal and closing process starts
        //otherwise - the standard Mark as Current Stage button is displayed in the path and stage can be updated
        if(stepName == 'Closed' || stepName == 'Closed Won' || stepName == 'Closed Lost'){
            component.set('v.hideStagePathUpdateBtn', true);
        } else {
            component.set('v.hideStagePathUpdateBtn', false);
        }
    },

    handleClosedStageSelected : function (component, event, helper) {
        console.log('opp close proc: handleClosedStageSelected');
        var stepName = event.getParam("detail").value;
        if(stepName == 'Closed Won'){
            //check for co-sell 2.0 survey
            if(component.get('v.oppData.Co_Sell_Opportunity__c') != null 
                && component.get('v.oppData.Co_Sell_Opportunity__c') != ''
                && component.get('v.oppData.Account.Co_Sell_Leader__c') != '' 
                && component.get('v.oppData.Account.Co_Sell_Leader__c') != null
                && component.get('v.oppData.Co_Sell_Request__c') != null 
                && component.get('v.oppData.Co_Sell_Request__c') != '' 
                && component.get('v.oppData.Co_Sell_Request__r.Status__c') == 'Approved'
                && component.get('v.oppData.Co_Sell_Request__r.Impact_Survey_Filled__c') == false){
                    helper.callback_coSellSurvey(component, event, helper);
            } else {
                helper.handleClosedWonStageSelected(component, event, helper);
            } 
        } else if(stepName == 'Closed Lost'){
            helper.handleClosedLostStageSelected(component, event, helper);
        } else { //not closed won and not closed lost
            component.set('v.hideUpdateButton', false);
            component.set('v.hideStagePathUpdateBtn', false);
        }
    },

    recordUpdated : function(component, event, helper) {
        var changeType = event.getParams().changeType; // change types - ERROR, LOADED, REMOVED, CHANGED
        if (changeType === "CHANGED") { /* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */ 
          component.find("recordEditor").reloadRecord();
        }
    },

    isSOManuallySignedClicked : function(component, event, helper) {
        console.log('opp close proc: isSOManuallySignedClicked value: '+ event.getSource().get('v.value'));
        component.set('v.isSoManuallySigned', event.getSource().get('v.value'));
        component.set('v.closedFields.Is_SO_Signed__c', event.getSource().get('v.value'))
    },

    setWhatWouldYouLikeToClaim : function(component, event, helper){
        var claim = event.getParam('value');
        event.preventDefault();
        component.set("v.closedFields.What_Would_You_Like_To_Claim__c", claim);
        helper.callback_saveManualFields(component, event, helper);
    },

    handleStatusChange_Handover : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            helper.callback_closeOpp(component, event, helper, "Closed Won");
        }
    },

    handleSuccessFieldSets : function(component, event, helper){
        component.set('v.showValidation', false);
        if(!component.get('v.isClosedLost')) {
            helper.callback_handover_updateCompSizeRecalcTH(component, event, helper);
        }
    },

    handleSubmitValidation_SOWon : function(component, event, helper){
        event.preventDefault();
        component.find("validationSOFields").submit();
    },

    handleSubmitValidation_ClaimWon : function(component, event, helper){
        event.preventDefault();
        component.find("validationClaimFields").submit();
    },

    handleSubmitValidation_Lost : function(component, event, helper){
        event.preventDefault();
        component.find("validationLostFields").submit();
    },

    prioritySO : function(component, event, helper){
        var manualSign = event.getParam('value');
        component.set('v.isPrioritySO', manualSign);
    },

    handleStatusChange_OpportunityCloseSummary : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED" ){
            // need to QA start from opp summary and check if this is actually needed
            //maybe only close modal is needed here..
            if(component.get('v.oppData.Close_Process_Sys_Admin__c') == false){
                component.set('v.closedFields.Close_Process_Path__c', 'Done');
            }
        }
    },
    
    previousStep : function (component, event, helper){
        component.set("v.errMsg", "");
        event.preventDefault();
        helper.setPreviousStep(component, event, helper);
    },

    
    //Next Step button
    submitDetails : function(component, event, helper) {
        console.log('opp close proc: entered submitDetails');
        console.log('opp close proc: submitDetails isClosedWon '+component.get('v.isClosedWon'));
        console.log('opp close proc: submitDetails isClosedLost '+component.get('v.isClosedLost'));
        component.set("v.errMsg", "");
        event.preventDefault();
        if(component.get('v.isClosedWon')){
            console.log('opp close proc: entered close won condition');
            helper.submit_closedWon(component, event, helper);
        } else if(component.get('v.isClosedLost')){
            helper.submit_closedLost(component, event, helper);
        }
    },
})