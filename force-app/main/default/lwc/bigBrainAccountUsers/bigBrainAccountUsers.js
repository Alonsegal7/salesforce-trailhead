import { LightningElement, wire, track, api } from 'lwc';
import getAccountUsers from '@salesforce/apex/BigBrainController.getAccountUsers';
import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

const DEFAULT_PHOTO = 'https://d1f5eoceewynq7.cloudfront.net/dapulse_default_photo.png';
const fields = [ACCOUNT_FIELD];
const columns = [
    { label: '', fieldName: 'photo_url', type: 'image' },
    { label: 'Name', fieldName: 'name' },
    { label: 'Email', fieldName: 'email' },
    { label: 'Phone', fieldName: 'phone' },
    { label: 'Engagements', fieldName: 'engagments', type: 'number' },
    { label: 'Enabled', fieldName: 'enabled', type: 'boolean' },
    { label: 'Admin', fieldName: 'is_admin', type: 'boolean' },
    { label: 'Guest', fieldName: 'is_guest', type: 'boolean' }
];
export default class BigBrainAccountUsers extends LightningElement {
    columns = columns;
    isLoading = true;
    isLoading() { return this.isLoading }

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({ error, data }) {
        if (data) {
            const pulseAccountId = getFieldValue(data, ACCOUNT_FIELD)
            this.displayUsers(pulseAccountId)
        }

        if (error) { this.error = error }
    }

    async displayUsers(pulseAccountId) {
        const response = await getAccountUsers({ pulseAccountId })
        const results = JSON.parse(response);
        this.data = results.map(u => ({
            photo_url: u.photo_url || DEFAULT_PHOTO,
            name: u.name,
            email: u.email,
            phone: u.phone,
            engagments: u.engagments,
            enabled: u.enabled === 1 ? true : false,
            is_admin: u.is_admin === 1 ? true : false,
            is_guest: u.user_kind === "guest" ? true : false
        }));

        this.isLoading = false

    }
}