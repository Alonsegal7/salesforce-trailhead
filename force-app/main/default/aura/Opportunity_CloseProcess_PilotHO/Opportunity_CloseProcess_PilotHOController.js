({
  closeModal: function (component, event, helper) {
    helper.endProcess(component, event, helper);
  },

  handleStageSelected: function (component, event, helper) {
    var stepName = event.getParam("detail").value;
    //if the stage is Closed Won or Closed Lost we display the modal and closing process starts
    //otherwise - the standard Mark as Current Stage button is displayed in the path and stage can be updated
    if (
      stepName == "Closed" ||
      stepName == "Closed Won" ||
      stepName == "Closed Lost"
    ) {
      component.set("v.hideStagePathUpdateBtn", true);
    } else {
      component.set("v.hideStagePathUpdateBtn", false);
    }
  },

  handleClosedStageSelected: function (component, event, helper) {
    console.log("opp close proc ho: handleClosedStageSelected");
    var stageName = event.getParam("detail").value;
    if (stageName == "Closed Won" || stageName == "Closed Lost") {
      if (stageName == "Closed Won") component.set('v.isClosedWon', true);
      else component.set('v.isClosedLost', true);
      helper.callback_closedStageSelected(component, event, helper, stageName);
    } else {
      component.set("v.hideUpdateButton", false);
      component.set("v.hideStagePathUpdateBtn", false);
    }
  },

  recordUpdated: function (component, event, helper) {
    var changeType = event.getParams().changeType; // change types - ERROR, LOADED, REMOVED, CHANGED
    if (changeType === "CHANGED") {
      /* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */
      component.find("recordEditor").reloadRecord();
    }
  },

  isSOManuallySignedClicked: function (component, event, helper) {
    console.log(
      "opp close proc ho: isSOManuallySignedClicked value: " +
        event.getSource().get("v.value")
    );
    component.set(
      "v.closedFields.Is_SO_Signed__c",
      event.getSource().get("v.value")
    );
  },

  setWhatWouldYouLikeToClaim: function (component, event, helper) {
    var claim = event.getParam("value");
    event.preventDefault();
    component.set("v.closedFields.What_Would_You_Like_To_Claim__c", claim);
    helper.checkActivation_InternalOpp(component, event, helper);

    //helper.callback_saveManualFields(component, event, helper);
  },

  handleStatusChange_Handover: function (component, event, helper) {
    if (event.getParam("status") === "FINISHED") {
      helper.callback_closeOpp(component, event, helper, "Closed Won");
    }
  },

  handleSuccessFieldSets: function (component, event, helper) {
    console.log("opp close proc ho: handleSuccessFieldSets");
    component.set('v.showSpinner', false);
    component.set("v.showFieldSetForm", false);
  },

  turnOffSpinner: function (component, event, helper) {
    console.log("opp close proc ho: turnOffSpinner");
    component.set("v.showSpinner", false);
  },

  handleSubmitValidation_SOWon: function (component, event, helper) {
    console.log("opp close proc ho: handleSubmitValidation_SOWon");
    event.preventDefault();
    component.find("validationSOFields").submit();
    component.set('v.showSpinner', true);
  },

  handleSubmitValidation_ClaimWon: function (component, event, helper) {
    console.log("opp close proc ho: handleSubmitValidation_ClaimWon");
    event.preventDefault();
    component.find("validationClaimFields").submit();
    component.set('v.showSpinner', true);
  },

  handleSubmitValidation_Lost: function (component, event, helper) {
    console.log("opp close proc ho: handleSubmitValidation_Lost");
    event.preventDefault();
    component.find("validationLostFields").submit();
    component.set('v.showSpinner', true);
  },

  prioritySO: function (component, event, helper) {
    var manualSign = event.getParam("value");
    component.set("v.isPrioritySO", manualSign);
  },

  handleStatusChange_OpportunityCloseSummary: function (
    component,
    event,
    helper
  ) {
    if (
      event.getParam("status") === "FINISHED_SCREEN" ||
      event.getParam("status") === "FINISHED"
    ) {
      // need to QA start from opp summary and check if this is actually needed
      //maybe only close modal is needed here..
      if (component.get("v.oppData.Close_Process_Sys_Admin__c") == false) {
        component.set("v.closedFields.Close_Process_Path__c", "Done");
      }
    }
  },

  previousStep: function (component, event, helper) {
    component.set("v.errMsg", "");
    event.preventDefault();
    helper.setPreviousStep(component, event, helper);
  },

  handleSuccessHandover: function (component, event, helper) {
    console.log(
      "handleSuccessHandover from close process: " + JSON.stringify(event)
    );
    helper.postHandoverActions(component, event, helper);
  },

  handleErrorHandover: function (component, event, helper) {
    console.log(
      "handleErrorHandover from close process " + JSON.stringify(event)
    );
    helper.postHandoverActions(component, event, helper);
  },

  handleExistingHandover: function (component, event, helper) {
    console.log("handleExistingHandover from close process ");
    component.set("v.hasExistingHandover", true);
  },

  //Next Step button
  submitDetails: function (component, event, helper) {
    console.log("opp close proc ho: entered submitDetails");
    console.log(
      "opp close proc ho: submitDetails isClosedWon " +
        component.get("v.isClosedWon")
    );
    console.log(
      "opp close proc ho: submitDetails isClosedLost " +
        component.get("v.isClosedLost")
    );
    component.set("v.errMsg", "");
    event.preventDefault();
    if (component.get("v.isClosedWon")) {
      console.log("opp close proc ho: entered close won condition");
      helper.submit_closedWon(component, event, helper);
    } else if (component.get("v.isClosedLost")) {
      helper.submit_closedLost(component, event, helper);
    }
  }
});