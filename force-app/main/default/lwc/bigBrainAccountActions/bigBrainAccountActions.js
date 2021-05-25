import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setAccountFreeUsers from '@salesforce/apex/BigBrainController.setAccountFreeUsers';

import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
const fields = [ACCOUNT_FIELD];

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

  get accountId() {
    return getFieldValue(this.lead.data, ACCOUNT_FIELD);
  }

  get oneMonthFromNow(){
    const today = new Date();
    today.setMonth(today.getMonth() + 1);
    return formatDate(today);
  }

  get todaysDate() {
    const today = new Date();
    return formatDate(today);
  }

  freeUsersAmount = 0;
  freeUsersUntil = "";

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
}