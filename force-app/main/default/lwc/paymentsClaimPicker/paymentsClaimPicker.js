import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import getAllOpportunityBillings from '@salesforce/apex/BigBrainController.getAllOpportunityBillings';
import ACCOUNT_FIELD from "@salesforce/schema/Opportunity.Account.primary_pulse_account_id__c";
import BILLING_IDS_FIELD from "@salesforce/schema/Opportunity.Billing_Ids__c";
import IS_CLAIMED_FIELD from "@salesforce/schema/Opportunity.Is_Claim_Available__c"
import ID_FIELD from "@salesforce/schema/Opportunity.Id";

export default class PaymentsClaimPicker extends LightningElement {
    claimedSubscriptions = [];
    availableSubscriptions = [];
    isLoading = true;
    disable = true;

    @api recordId;
    @track pulseAccountId;

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_FIELD, BILLING_IDS_FIELD, IS_CLAIMED_FIELD] })
    wiredRecord({ error, data }) {
        if (error) { this.recordError = error; }
        if (data) {
            this.pulseAccountId = getFieldValue(data, ACCOUNT_FIELD);
            this.isClaimAvailable = getFieldValue(data, IS_CLAIMED_FIELD);
        }
    }

    @wire(getAllOpportunityBillings, { pulseAccountId: '$pulseAccountId', opportunityId: '$recordId' })
    data({ error, data }) {
        if (!data) return;
        if (error) {
            this.isLoading = false;
            this.error = error;
            return;
        }

        this.isLoading = false;
        const results = JSON.parse(data);

        this.claimed = results.claimed || [];
        this.unclaimed = results.unclaimed || [];

        this.claimedSubscriptions = this.toDisplayFormat(this.claimed).map(s => String(s.value))
        this.availableSubscriptions = this.toDisplayFormat([...this.unclaimed, ...this.claimed])

        this.disable = !this.isClaimAvailable
        if ((this.claimed.length + this.unclaimed.length) === 0) { this.disable = true }

    }

    handleChange(e) {
        this.claimedSubscriptions = e.detail.value; // detail.value holds *all* the claimed subscriptions
    }

    updateBillingsClaims() {
        this.isLoading = true;
        this.showSuccess = false;

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[BILLING_IDS_FIELD.fieldApiName] = this.claimedSubscriptions.join(",");

        updateRecord({ fields }).then(() => {
            this.isLoading = false;
            this.showSuccess = true;
        });
    }

    toDisplayFormat(subscriptions) {
        return (subscriptions || []).map(s => ({
            label: `$${s.invoice_charge_amount_usd} | ${this.formatDate(new Date(s.event_happened_at))} | ${s.event_type} | ${s.plan.name} | ${s.account.slug}`,
            value: String(s.bluesnap_log_entry_id)
        }))
    }

    formatDate = (date) => {
        const dd = String(date.getDate()).padStart(2, '0');
        const mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
        const yyyy = date.getFullYear();
        return mm + '/' + dd + '/' + yyyy;
    }
}