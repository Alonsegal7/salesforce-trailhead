import { LightningElement, wire, api } from 'lwc';
import getAccountUsers from '@salesforce/apex/BigBrainController.getAccountUsers';

const DEFAULT_PHOTO = 'https://d1f5eoceewynq7.cloudfront.net/dapulse_default_photo.png';
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
    @api pulseAccountId;

    columns = columns;
    isLoading = true;
    usersData = [];
    error;

    @wire(getAccountUsers, { pulseAccountId: '$pulseAccountId' })
    data({ error, data }) {
        if(!data) return;
        if(error) {
            this.isLoading = false;
            this.error = error;
            return;
        }

        const results = JSON.parse(data);

        this.usersData = results.map(u => ({
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