import { LightningElement, wire, api } from 'lwc';
import getAccountBilling from '@salesforce/apex/BigBrainController.getAccountBilling';
import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

const fields = [ACCOUNT_FIELD];
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
    isLoading() { return this.isLoading }

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredRecord({ error, data }) {
        if (data) {
            const pulseAccountId = getFieldValue(data, ACCOUNT_FIELD)
            this.diplayBillingData(pulseAccountId)
        }

        if (error) { this.error = error }
    }

    async diplayBillingData(pulseAccountId) {
        const response = await getAccountBilling({ pulseAccountId })
        const results = JSON.parse(response);

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