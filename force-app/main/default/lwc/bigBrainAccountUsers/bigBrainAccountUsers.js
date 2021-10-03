import { LightningElement, wire, api, track } from 'lwc';
import getAccountUsers from '@salesforce/apex/BigBrainController.getAccountUsers';

const DEFAULT_PHOTO = 'https://d1f5eoceewynq7.cloudfront.net/dapulse_default_photo.png';

const columns = [
    { label: '', fieldName: 'photo_url', type: 'image' },
    { label: 'Name', fieldName: 'name', sortable: true },
    { label: 'Email', fieldName: 'email', sortable: true  },
    { label: 'Last seen', fieldName: 'last_seen', type: 'date', sortable: true  },
    { label: 'Phone', fieldName: 'phone' },
    { label: 'Engagements', fieldName: 'engagments', type: 'number', sortable: true  },
    { label: 'Enabled', fieldName: 'enabled', type: 'boolean', sortable: true  },
    { label: 'Admin', fieldName: 'is_admin', type: 'boolean', sortable: true  },
    { label: 'Guest', fieldName: 'is_guest', type: 'boolean', sortable: true  }
];

const parseData = data => 
    JSON.parse(data).map(u => (
        {
            photo_url: u.photo_url || DEFAULT_PHOTO,
            name: u.name,
            email: u.email,
            phone: u.phone,
            engagments: u.engagments,
            last_seen: u.last_seen,
            enabled: u.enabled === 1 ? true : false,
            is_admin: u.is_admin === 1 ? true : false,
            is_guest: u.user_kind === "guest" ? true : false
        }
    ))

export default class BigBrainAccountUsers extends LightningElement {
    @api pulseAccountId;

    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    @track isLoading = true;
    @track data = [];
    error;

    @wire(getAccountUsers, { pulseAccountId: '$pulseAccountId' })
    data({ error, data }) {
        this.error = error;
        if(!data) return;
        this.data = parseData(data);
        this.isLoading = false;
    }

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        console.log(field, reverse, primer);
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
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
}