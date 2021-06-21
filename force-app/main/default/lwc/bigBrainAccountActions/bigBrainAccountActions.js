import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setAccountFreeUsers from '@salesforce/apex/BigBrainController.setAccountFreeUsers';
import getAccountGrantedFeatures from '@salesforce/apex/BigBrainController.getAccountGrantedFeatures';
import resetAccountTrial from '@salesforce/apex/BigBrainController.resetAccountTrial';

import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import PRICING_VERSION_FIELD from '@salesforce/schema/Lead.Pricing_Version__c';
const fields = [ACCOUNT_FIELD, PRICING_VERSION_FIELD];

const formatDate = (date) => {
  var dd = String(date.getDate()).padStart(2, '0');
  var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = date.getFullYear();
  return mm + '/' + dd + '/' + yyyy;
} 

export default class BigBrainAccountActions extends LightningElement {
  @api recordId;
  @wire(getRecord, { recordId: '$recordId', fields })
  lead;

  get oneMonthFromNow(){
    const today = new Date();
    today.setMonth(today.getMonth() + 1);
    return formatDate(today);
  }

  get todaysDate() {
    const today = new Date();
    return formatDate(today);
  }

  get pricingVersionOptions() {
    return [
      { label: '6 - old infra / higher prices', value: 6 },
      { label: '7 - new infra / lower prices', value: 7 },
      { label: '8 - new infra / higher prices', value: 8 },
      { label: '9 - new infra / updated higher prices (ENT 38$, BRL, MXN, INR)', value: 9 }
    ];
  }

  @api pulseAccountId;
  @wire(getAccountGrantedFeatures, { pulseAccountId: '$pulseAccountId' })
  data({ error, data }) {
    console.log("data", error)
    if(!data) return;

    const respJson = JSON.parse(data)
    console.log("respJson", respJson)
    this.options = []
    this.value = ""
  }

  freeUsersAmount = 0;
  freeUsersUntil = "";
  pricingVersion = null;

  handlePricingVersionChange(event) {
    this.pricingVersion = event.detail.value;
  }

  handleFreeUsersAmountChange(e) {
    this.freeUsersAmount = e.detail.value;
  }

  handleFreeUsersUntilChange(e) {
    this.freeUsersUntil = e.detail.value;
}

  handleFreeUsersGrantClick(e) {
    setAccountFreeUsers({pulseAccountId: this.accountId, freeUsers: this.freeUsersAmount, untilDate: this.freeUsersUntil})
      .then(result => {
        const evt = new ShowToastEvent({
          title: "Set free users successfully!",
          message: 'Free users was set to ' + this.freeUsersAmount,
          variant: "success",
        });

        this.dispatchEvent(evt);
      })
      .catch(error => {
        const evt = new ShowToastEvent({
          title: "Error while setting free users",
          variant: "error",
        });

        this.dispatchEvent(evt);
      });
  }

  handleResetTrialClick(e) {
    resetAccountTrial({pulseAccountId: '$pulseAccountId'})
      .then(result => {
        const evt = new ShowToastEvent({
          title: "Reset account trial successfully!",
          variant: "success",
        });

        this.dispatchEvent(evt);
      })
      .catch(error => {
        const evt = new ShowToastEvent({
          title: "Error while resetting account trial",
          variant: "error",
        });

        this.dispatchEvent(evt);
      });
  }
}