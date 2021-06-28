import { LightningElement, wire, api } from 'lwc';
import getAllOpportunityBillings from '@salesforce/apex/BigBrainController.getAllOpportunityBillings';
export default class PaymentsClaimPicker extends LightningElement {

    claimedSubscriptions = [];
    availableSubscriptions = [];

    @api Id;
    @wire(getAllOpportunityBillings, { opportunityId: '$Id' })
    data({ error, data }) {
        console.log("DATA")
        console.log(data)
        // console.log(Id)
        data = `{"claimed":[{"id":1991739, "event_happened_at":"2020-07-09T08:19:20.000Z", "bluesnap_log_entry_id":1870895, "pulse_account_id":6433992, "event_type":"CHARGE", "invoice_charge_amount":"52.0", "invoice_charge_amount_usd":"63.8", "mrr_gain":"65.58", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":5, "name":"Standard -- Up to 5 users (Monthly)", "tier":"standard", "period":"monthly"}}, {"id":2087768, "event_happened_at":"2020-08-09T09:03:58.000Z", "bluesnap_log_entry_id":1966911, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"52.0", "invoice_charge_amount_usd":"66.37", "mrr_gain":"2.29", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":5, "name":"Standard -- Up to 5 users (Monthly)", "tier":"standard", "period":"monthly"}}, {"id":2197015, "event_happened_at":"2020-09-09T08:07:06.000Z", "bluesnap_log_entry_id":2076147, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"52.0", "invoice_charge_amount_usd":"66.31", "mrr_gain":"0.59", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":5, "name":"Standard -- Up to 5 users (Monthly)", "tier":"standard", "period":"monthly"}}, {"id":2287807, "event_happened_at":"2020-10-06T10:56:29.000Z", "bluesnap_log_entry_id":2166930, "pulse_account_id":6433992, "event_type":"CONTRACT_CHANGE", "invoice_charge_amount":"0.0", "invoice_charge_amount_usd":"0.0", "mrr_gain":"43.1", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":5, "name":"Pro -- Up to 5 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":2355656, "event_happened_at":"2020-10-26T10:56:09.000Z", "bluesnap_log_entry_id":2234776, "pulse_account_id":6433992, "event_type":"CONTRACT_CHANGE", "invoice_charge_amount":"0.0", "invoice_charge_amount_usd":"0.0", "mrr_gain":"112.82", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":10, "name":"Pro -- Up to 10 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":2467106, "event_happened_at":"2020-11-26T09:05:26.000Z", "bluesnap_log_entry_id":2346229, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"172.0", "invoice_charge_amount_usd":"224.78", "mrr_gain":"5.1", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":10, "name":"Pro -- Up to 10 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":2565990, "event_happened_at":"2020-12-26T09:04:14.000Z", "bluesnap_log_entry_id":2445108, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"172.0", "invoice_charge_amount_usd":"227.58", "mrr_gain":"3.38", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":10, "name":"Pro -- Up to 10 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":2673001, "event_happened_at":"2021-01-26T09:07:01.000Z", "bluesnap_log_entry_id":2552113, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"172.0", "invoice_charge_amount_usd":"229.75", "mrr_gain":"2.46", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":10, "name":"Pro -- Up to 10 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":2792897, "event_happened_at":"2021-02-26T09:59:49.000Z", "bluesnap_log_entry_id":2672092, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"172.0", "invoice_charge_amount_usd":"237.91", "mrr_gain":"7.16", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":10, "name":"Pro -- Up to 10 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":2796996, "event_happened_at":"2021-02-27T10:50:48.000Z", "bluesnap_log_entry_id":2676191, "pulse_account_id":6433992, "event_type":"CONTRACT_CHANGE", "invoice_charge_amount":"0.0", "invoice_charge_amount_usd":"0.0", "mrr_gain":"117.02", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":15, "name":"Pro -- Up to 15 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":2907692, "event_happened_at":"2021-03-26T08:08:04.000Z", "bluesnap_log_entry_id":2786884, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"258.0", "invoice_charge_amount_usd":"346.12", "mrr_gain":"-5.85", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":15, "name":"Pro -- Up to 15 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":3027221, "event_happened_at":"2021-04-26T08:04:55.000Z", "bluesnap_log_entry_id":2906389, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"258.0", "invoice_charge_amount_usd":"350.06", "mrr_gain":"4.28", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":15, "name":"Pro -- Up to 15 users (Monthly)", "tier":"pro", "period":"monthly"}}, {"id":3150049, "event_happened_at":"2021-05-26T08:05:02.000Z", "bluesnap_log_entry_id":3029171, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"258.0", "invoice_charge_amount_usd":"356.52", "mrr_gain":"7.35", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":15, "name":"Pro -- Up to 15 users (Monthly)", "tier":"pro", "period":"monthly"}}], "unclaimed":[{"id":3278277, "event_happened_at":"2021-06-26T08:05:51.000Z", "bluesnap_log_entry_id":3157368, "pulse_account_id":6433992, "event_type":"RECURRING", "invoice_charge_amount":"258.0", "invoice_charge_amount_usd":"350.83", "mrr_gain":"-5.93", "account":{"account_name":"UpSlide", "slug":"upslide-squad"}, "plan":{"max_user":15, "name":"Pro -- Up to 15 users (Monthly)", "tier":"pro", "period":"monthly"}}]}`
        console.log(data)
        if(!data) return;
        if(error) {
            this.isLoading = false;
            this.error = error;
            return;
        }
        const results = JSON.parse(data);
        this.claimedSubscriptions = this.toListboxFormat(results.claimed).map(s => String(s.value))
        this.availableSubscriptions = this.toListboxFormat([...results.unclaimed, ...results.claimed])
    }

    get options() {
        return this.availableSubscriptions
    }

    handleChange(e) {
        console.log(e)
        console.log(e.detail)
        this.claimedSubscriptions = e.detail.value;
        this.claimedSubscriptions.unshift(this.claimedSubscriptions.pop())
    }

    handleClick(){
        
    }

    toListboxFormat(subscriptions){
        return subscriptions.map(s => ({
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