import { LightningElement, wire, api } from 'lwc';
import getAccountBilling from '@salesforce/apex/BigBrainController.getAccountBilling';

const columns = [
    { label: 'Time', fieldName: 'time', type: 'date', sortable: true },
    { label: 'Type', fieldName: 'type', sortable: true },
    { label: 'Status', fieldName: 'status', sortable: true },
    { label: 'Plan', fieldName: 'plan', sortable: true },
    { label: 'Price', fieldName: 'price', sortable: true },
    { label: 'ARR Gain', fieldName: 'arr_gain', sortable: true },
    { label: 'Currency', fieldName: 'currency', sortable: true },
    { label: 'Price (USD)', fieldName: 'price_usd', sortable: true },
    { label: 'Coupon', fieldName: 'coupon', sortable: true }
];

const parseData = data =>
    JSON.parse(data).map(b => (
        {
            time: b.event_happened_at,
            type: b.event_type,
            status: b.status,
            plan: b.plan ? b.plan.name : "",
            price: `${formatPrice(b.invoice_charge_amount)} ${b.currency}`,
            arr_gain: `${formatPrice(b.mrr_gain * 12)} USD`,
            currency: b.currency,
            price_usd: `${formatPrice(b.invoice_charge_amount_usd)} USD`,
            coupon: b.coupon_code
        }
    ));

const formatPrice = price => 
    Math.abs(price) > 999 ?
        Math.sign(price) * ((Math.abs(price) / 1000).toFixed(1)) + 'k' :
        Math.sign(price) * Math.abs(price);

export default class BigBrainAccountBilling extends LightningElement {
    @api pulseAccountId;

    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    data = [];
    isLoading = true;

    @wire(getAccountBilling, { pulseAccountId: '$pulseAccountId' })
    data({ error, data }) {
        this.error = error;
        if(!data) return;
        this.data = parseData(data);

        this.isLoading = false
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