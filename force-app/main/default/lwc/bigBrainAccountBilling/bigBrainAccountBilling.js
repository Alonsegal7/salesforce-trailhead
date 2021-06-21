import { LightningElement, wire, api } from 'lwc';
import getAccountBilling from '@salesforce/apex/BigBrainController.getAccountBilling';

const columns = [
    { label: 'Time', fieldName: 'time', type: 'date' },
    { label: 'Type', fieldName: 'type' },
    { label: 'Status', fieldName: 'status' },
    { label: 'Plan', fieldName: 'plan' },
    { label: 'Price', fieldName: 'price' },
    { label: 'MRR Gain', fieldName: 'mrr_gain' },
    { label: 'Currency', fieldName: 'currency' },
    { label: 'Price (USD)', fieldName: 'price_usd' },
    { label: 'Coupon', fieldName: 'coupon', }
];

export default class BigBrainAccountBilling extends LightningElement {
    columns = columns;
    isLoading = true;

    @api pulseAccountId;
    @wire(getAccountBilling, { pulseAccountId: '$pulseAccountId' })
    data({ error, data }) {
        if(!data) return;
        if(error) {
            this.isLoading = false;
            this.error = error;
            return;
        }
        const results = JSON.parse(data);

        this.data = results.map(b => ({
            time: b.event_happened_at,
            type: b.event_type,
            status: b.status,
            plan: b.plan ? b.plan.name : "",
            price: this.formatPrice(b.invoice_charge_amount),
            mrr_gain: this.formatPrice(b.mrr_gain),
            currency: b.currency,
            price_usd: this.formatPrice(b.invoice_charge_amount_usd),
            coupon: b.coupon_code
        }));

        this.isLoading = false
    }

    formatPrice(price) {
        return Math.abs(price) > 999 ?
            Math.sign(price) * ((Math.abs(price) / 1000).toFixed(1)) + 'k' :
            Math.sign(price) * Math.abs(price)
    }
}