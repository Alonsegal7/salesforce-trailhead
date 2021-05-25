import { LightningElement, wire, track } from 'lwc';
import getAccountUsers from '@salesforce/apex/BigBrainController.getAccountUsers';
import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';

const fields = [ACCOUNT_FIELD];
const DEFAULT_PHOTO = 'https://d1f5eoceewynq7.cloudfront.net/dapulse_default_photo.png';
const columns = [
    { label: '', fieldName: 'photo_url', type:'image' },
    { label: 'Name', fieldName: 'name', sortable: true },
    { label: 'Email', fieldName: 'email' },
    { label: 'Phone', fieldName: 'phone' },
    { label: 'Engagements', fieldName: 'engagments', type: 'number', sortable: true },
    { label: 'Enabled', fieldName: 'enabled', type: 'boolean' },
    { label: 'Admin', fieldName: 'is_admin', type: 'boolean' },
    { label: 'Guest', fieldName: 'is_guest', type: 'boolean' }
];
export default class BigBrainAccountUsers extends LightningElement {
    // @api recordId;

    // @wire(getRecord, { recordId: '$recordId', fields })
    // lead;

    // get accountId() {
    //     return getFieldValue(this.lead.data, ACCOUNT_FIELD);
    // }

    isLoading = true;

    @track data;
    @wire(getAccountUsers, { pulseAccountId: '5' }) // must be string

    data({ error, data }) {
        this.error = error;
        if (!data) return;

        const results = JSON.parse(data);
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

        this.isLoading = false;
    };

    isLoading() { return this.isLoading }

    columns = columns;
}

/*
Ugly sorting code
Need to add this to datable in HTML:
    onsort={onHandleSort}


sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
*/