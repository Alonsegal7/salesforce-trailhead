import { LightningElement, wire, api } from 'lwc';
import getAccountProfile from '@salesforce/apex/BigBrainController.getAccountProfile';

const SLUG_SUFFIX = ".monday.com"
const UNKNOWN = '-';

export default class BigBrainAccountProfile extends LightningElement {
  @api pulseAccountId;

  data = null;
  error = null;
  loading = true;

  //General
  name;
  signupDate;
  createdAt;
  trialPeriod;
  teamSize;
  companySize;
  slug;
  industry;
  website;
  statuses;

  //Plan related data
  plan;
  currency;
  pricingVersion;
  planStartDate;
  planUntilDate;
  collection;
  paymentMethodLabel;
  arr;

  //users breakdown data
  totalSeats;
  members;
  viewers;
  freeUsers;
  guests;
  seatsLeft;

  get isError() {
    return !!this.error;
  }

  get isLoading() {
    return this.loading && !this.error;
  }

  get isReady() {
    return !this.isError && !this.isLoading;
  }

  get hasStatuses() {
    return this.statuses && this.statuses.length > 0;
  }
  
  @wire(getAccountProfile, { pulseAccountId: '$pulseAccountId' })
  data ({ error, data }) {
    this.error = error;
    this.data = data;
    if (!data) return;

    const parsedData = JSON.parse(data);
 
    const { 
      domain,
      industry,
      created_at,
      last_seen,
      trial_period, 
      company_size, 
      max_team_size, 
      slug, 
      plan = {}, 
      pricing_version, 
      payment_currency, 
      collection_usd, 
      payment_method_label,
      arr,
      users_breakdown = {},
      account_name,
      xi_country,
      xi_city,
      xi_region,
      xi_time_diff,
      statuses,
      message
   } = parsedData;
   
    const { max_user, tier, period, started_at, ended_at } = plan;
    const { total_seats, members, viewers, guests, free_users, seats_left } = users_breakdown;
    const timeDiffText = xi_time_diff ? '' : `(${xi_time_diff})`;

    this.error = message;
    this.name = account_name;
    this.wesbite = `https://${domain}`;
    this.industry = industry || UNKNOWN;
    this.signupDate = created_at;
    this.trialPeriod = trial_period;
    this.companySize = company_size || UNKNOWN;
    this.teamSize = max_team_size || UNKNOWN;
    this.slug = `https://${slug}${SLUG_SUFFIX}`;
    this.address = `${xi_city}, ${xi_region}, ${xi_country} ${timeDiffText}`;
    this.statuses = (statuses || []).map(s => ({label: s}));

    if (tier) {
      this.plan = `${max_user} ${tier} ${period}`;
      this.planStartDate = started_at;
      this.planUntilDate = ended_at;
    } else {
      this.plan = 'Trial';
      this.planStartDate = created_at;
      var trialUntil = new Date(created_at);
      trialUntil.setDate(trialUntil.getDate() + trial_period);
      this.planUntilDate = trialUntil;
    }

    this.currency = payment_currency;
    this.pricingVersion = pricing_version;
    this.lastSeen = last_seen;
    this.collection = collection_usd;
    this.paymentMethodLabel = payment_method_label;
    this.arr = arr;

    this.totalSeats = total_seats || 0;
    this.members = members || 0;
    this.viewers = viewers || 0;
    this.freeUsers = free_users || 0;
    this.guests = guests || 0;
    this.seatsLeft = seats_left || 0;

    this.loading = false;
  };
}