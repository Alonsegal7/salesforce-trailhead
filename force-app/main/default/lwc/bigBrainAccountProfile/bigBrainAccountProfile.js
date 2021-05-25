import { LightningElement, wire } from 'lwc';
import getAccountProfile from '@salesforce/apex/BigBrainController.getAccountProfile';

const SLUG_SUFFIX = ".monday.com"
export default class BigBrainAccountProfile extends LightningElement {
  
  accountData = {};
  signupDate;
  createdAt;
  trialPeriod;
  teamSize;
  companySize;
  slug;
  website;
  plan;
  currency;
  pricingVersion;
  planStartDate;
  planUntilDate;
  collection;
  arr;
  
  
  @wire(getAccountProfile)
  data ({ error, data }) {
    if (!data) return;

    this.accountData = JSON.parse(data);

    const { domain, created_at, trial_period, company_size, max_team_size, slug, plan, pricing_version, payment_currency, collection_usd, arr } = this.accountData;
    const { max_user, tier, period, started_at, ended_at } = plan;

    this.wesbite = `https://${domain}`;
    this.signupDate = created_at;
    this.trialPeriod = trial_period;
    this.companySize = company_size || "Unknown";
    this.teamSize = max_team_size || "Unknown";
    this.slug = `https://${slug}${SLUG_SUFFIX}`;
    this.plan = `${max_user} ${tier} ${period}`;
    this.currency = payment_currency;
    this.pricingVersion = pricing_version;
    this.planStartDate = started_at;
    this.planUntilDate = ended_at;
    this.collection = collection_usd;
    this.arr = arr;
    

    console.log(JSON.parse(data));
    this.error = error;
  };
}