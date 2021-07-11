import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LEAD_ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import OPP_ACCOUNT_FIELD from "@salesforce/schema/Opportunity.primary_pulse_account_id__c";

const fields = [LEAD_ACCOUNT_FIELD, OPP_ACCOUNT_FIELD];

export default class BigBrainAccountTabs extends LightningElement {
    @api recordId;
    @track pulseAccountId;

    // Getting by lead
    @wire(getRecord, { recordId: '$recordId', fields: [LEAD_ACCOUNT_FIELD] })
    wiredRecord({ error, data }) {
        const pulseAccountId = getFieldValue(data, LEAD_ACCOUNT_FIELD);
        if (pulseAccountId) { this.pulseAccountId = pulseAccountId; }
    }

    // Getting by opportunity
    @wire(getRecord, { recordId: '$recordId', fields: [OPP_ACCOUNT_FIELD] })
    wiredRecord({ error, data }) {
        const pulseAccountId = getFieldValue(data, OPP_ACCOUNT_FIELD);
        if (pulseAccountId) { this.pulseAccountId = pulseAccountId; }
    }
}