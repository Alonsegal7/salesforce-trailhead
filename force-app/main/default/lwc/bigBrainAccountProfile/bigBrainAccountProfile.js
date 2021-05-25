import { LightningElement, wire, api } from 'lwc';
import getAccountProfile from '@salesforce/apex/BigBrainController.getAccountProfile';
import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
const fields = [ACCOUNT_FIELD];


const SLUG_SUFFIX = ".monday.com"
export default class BigBrainAccountProfile extends LightningElement {
  loaded = false;

  //General
  accountData = {};
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

  @api recordId;
  @wire(getRecord, { recordId: '$recordId', fields })
  wiredRecord({ error, data }) {
      if (data) {
          const pulseAccountId = getFieldValue(data, ACCOUNT_FIELD)
          this.fetchAccountProfile(pulseAccountId)
      }

      if (error) { 
        this.error = error;
        this.loaded = true;
      }
  }

  async fetchAccountProfile(pulseAccountId) {
    const response = await getAccountProfile({ pulseAccountId })
    console.log("asdfasdf", response.status)
    this.accountData = JSON.parse(response);
    console.log(this.accountData);

    const { 
      domain, 
      created_at, 
      trial_period, 
      company_size, 
      max_team_size, 
      slug, 
      plan, 
      pricing_version, 
      payment_currency, 
      collection_usd, 
      arr,
      users_breakdown
  } = this.accountData;
    const { max_user, tier, period, started_at, ended_at } = plan;
    const { total_seats, members, viewers, guests, free_users, seats_left } = users_breakdown;

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

    this.totalSeats = total_seats || 0;
    this.members = members || 0;
    this.viewers = viewers || 0;
    this.freeUsers = free_users || 0;
    this.guests = guests || 0;
    this.seatsLeft = seats_left || 0;

    // this.error = error;
    this.loaded = true;
  }
  // data ({ error, data }) {
  //   if (!data) return;
    
  //   console.log(JSON.parse(data));
  //   this.accountData = JSON.parse(data);

  //   const { 
  //     domain, 
  //     created_at, 
  //     trial_period, 
  //     company_size, 
  //     max_team_size, 
  //     slug, 
  //     plan, 
  //     pricing_version, 
  //     payment_currency, 
  //     collection_usd, 
  //     arr,
  //     users_breakdown
  //  } = this.accountData;
  //   const { max_user, tier, period, started_at, ended_at } = plan;
  //   const { total_seats, members, viewers, guests, free_users, seats_left } = users_breakdown;

  //   this.wesbite = `https://${domain}`;
  //   this.signupDate = created_at;
  //   this.trialPeriod = trial_period;
  //   this.companySize = company_size || "Unknown";
  //   this.teamSize = max_team_size || "Unknown";
  //   this.slug = `https://${slug}${SLUG_SUFFIX}`;

  //   this.plan = `${max_user} ${tier} ${period}`;
  //   this.currency = payment_currency;
  //   this.pricingVersion = pricing_version;
  //   this.planStartDate = started_at;
  //   this.planUntilDate = ended_at;
  //   this.collection = collection_usd;
  //   this.arr = arr;

  //   this.totalSeats = total_seats || 0;
  //   this.members = members || 0;
  //   this.viewers = viewers || 0;
  //   this.freeUsers = free_users || 0;
  //   this.guests = guests || 0;
  //   this.seatsLeft = seats_left || 0;

  //   this.error = error;
  //   this.loaded = true;
  // };
}