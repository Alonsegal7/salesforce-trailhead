import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LEAD_ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import OPP_ACCOUNT_FIELD from "@salesforce/schema/Opportunity.primary_pulse_account_id__c";
import ACCOUNT_FIELD from "@salesforce/schema/Account.primary_pulse_account_id__c";

const optionalFields = [LEAD_ACCOUNT_FIELD, OPP_ACCOUNT_FIELD, ACCOUNT_FIELD];

export default class BigBrainAccountTabs extends LightningElement {
    @api recordId;
    @track pulseAccountId;

    @wire(getRecord, { recordId: '$recordId', optionalFields })
    wiredRecord({ error, data }) {
        if (error || !data) return;
        const leadPulseAccountId = getFieldValue(data, LEAD_ACCOUNT_FIELD);
        const opportunityPulseAccountId = getFieldValue(data, OPP_ACCOUNT_FIELD);
        const maPulseAccountId = getFieldValue(data, ACCOUNT_FIELD);
        const pulseAccountId = leadPulseAccountId || opportunityPulseAccountId || maPulseAccountId;
        if (pulseAccountId) { this.pulseAccountId = pulseAccountId; }
    }
}