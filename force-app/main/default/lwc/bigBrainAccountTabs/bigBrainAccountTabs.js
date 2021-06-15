import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LEAD_ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import OPP_ACCOUNT_FIELD from "@salesforce/schema/Opportunity.primary_pulse_account_id__c";

const fields = [LEAD_ACCOUNT_FIELD, OPP_ACCOUNT_FIELD];

export default class BigBrainAccountTabs extends LightningElement {
    @track record; 

    get pulseAccountId() {
        const leadPulseAccoiuntId = getFieldValue(data, LEAD_ACCOUNT_FIELD);
        const opportunityPulse_account_id = getFieldValue(data, OPP_ACCOUNT_FIELD);
        return leadPulseAccoiuntId || opportunityPulse_account_id;
      }

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({ error, data }) {
        if (data) { this.record = data; }
        }
    }

}