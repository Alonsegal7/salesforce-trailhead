import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LEAD_ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import OPP_ACCOUNT_FIELD from "@salesforce/schema/Opportunity.primary_pulse_account_id__c";

const fields = [LEAD_ACCOUNT_FIELD, OPP_ACCOUNT_FIELD];

export default class BigBrainAccountTabs extends LightningElement {
    pulseAccountId; 

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({ error, data }) {
        if (data) {
            this.pulseAccountId = getFieldValue(data, LEAD_ACCOUNT_FIELD) || getFieldValue(data, OPP_ACCOUNT_FIELD)
        }
    }

}