import { LightningElement, wire, api } from 'lwc';
import getAccountProfile from '@salesforce/apex/BigBrainController.getAccountProfile';


const SLUG_SUFFIX = ".monday.com"
export default class BigBrainAccountProfile extends LightningElement {
  @api pulseAccountId;

  loaded = false;

  //General
  name;
  signupDate;
  createdAt;
  trialPeriod;
  teamSize;
  companySize;
  slug;
  website;

  //Plan related data
  plan;
  currency;
  pricingVersion;
  planStartDate;
  planUntilDate;
  collection;
  arr;

  //users breakdown data
  totalSeats;
  members;
  viewers;
  freeUsers;
  guests;
  seatsLeft;

  
  @wire(getAccountProfile, { pulseAccountId: '$pulseAccountId' })
  data ({ error, data }) {
    if (!data) return;
    
    this.accountData = JSON.parse(data);

    const { 
      domain, 
      created_at, 
      trial_period, 
      company_size, 
      max_team_size, 
      slug, 
      plan = {}, 
      pricing_version, 
      payment_currency, 
      collection_usd, 
      arr,
      users_breakdown = {},
      account_name,
      xi_country,
      xi_city,
      xi_region,
      xi_time_diff
   } = this.accountData;

    const { max_user, tier, period, started_at, ended_at } = plan;
    const { total_seats, members, viewers, guests, free_users, seats_left } = users_breakdown;
    const timeDiffText = xi_time_diff ? '' : `(${xi_time_diff})`

    this.name = account_name;
    this.wesbite = `https://${domain}`;
    this.signupDate = created_at;
    this.trialPeriod = trial_period;
    this.companySize = company_size || "Unknown";
    this.teamSize = max_team_size || "Unknown";
    this.slug = `https://${slug}${SLUG_SUFFIX}`;
    this.address = `${xi_city}, ${xi_region}, ${xi_country} ${timeDiffText}`

    this.plan = `${max_user} ${tier} ${period}`;
    this.currency = payment_currency;
    this.pricingVersion = pricing_version;
    this.planStartDate = started_at;
    this.planUntilDate = ended_at;
    this.collection = collection_usd;
    this.arr = arr;

    this.totalSeats = total_seats || 0;
    this.members = members || 0;
    this.viewers = viewers || 0;
    this.freeUsers = free_users || 0;
    this.guests = guests || 0;
    this.seatsLeft = seats_left || 0;

    this.loaded = true;
  };
}