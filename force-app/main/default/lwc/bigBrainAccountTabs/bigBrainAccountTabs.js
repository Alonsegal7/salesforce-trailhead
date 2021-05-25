import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';

const fields = [ACCOUNT_FIELD];

export default class BigBrainAccountTabs extends LightningElement {
    pulseAccountId; 

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({ error, data }) {
        if (data) {
            this.pulseAccountId = getFieldValue(data, ACCOUNT_FIELD)
        }
    }

}