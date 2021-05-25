import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';

import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';

const fields = [ACCOUNT_FIELD];

export default class BigBrainAccountActions extends LightningElement {
  @api recordId;

  @wire(getRecord, { recordId: '$recordId', fields })
  lead;

  get accountId() {
    return getFieldValue(this.lead.data, ACCOUNT_FIELD);
  }

  freeUsersAmount = 0;
  freeUsersUntil = null;

  handleFreeUsersAmountChange(e) {
    console.log(e.detail.value);
    console.log(e.target.value);
    this.freeUsersAmount = e.detail.value;
  }

  handleFreeUsersUntilChange(e) {
    console.log(e.detail.value);
    console.log(e.target.value);
    this.freeUsersUntil = e.detail.value;
}

  handleFreeUsersGrantClick(e) {
    alert(this.accountId);
    console.log(this.freeUsersAmount);
    console.log(this.freeUsersUntil);
    console.log(this.accountId);
  }
}