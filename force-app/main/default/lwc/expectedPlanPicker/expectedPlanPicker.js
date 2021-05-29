import { LightningElement, track, wire,api } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import getPlans from '@salesforce/apex/BigBrainController.getPlans';

import CURRENCY_FIELD from '@salesforce/schema/Opportunity.Currency__c';
import PRICING_VERSION_FIELD from '@salesforce/schema/Opportunity.Pricing_Version__c';
import TIER_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Tier__c';
import PERIOD_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Period__c';
import SEATS_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Seats__c';
import DISCOUNT_FIELD from '@salesforce/schema/Opportunity.Expected_Discount__c';

const fields = [CURRENCY_FIELD, PRICING_VERSION_FIELD, TIER_FIELD, PERIOD_FIELD, SEATS_FIELD, DISCOUNT_FIELD];

const getTotalPrice = (plan, currency) => {
  console.log(plan);
  console.log(currency);
  switch (currency) {
    case 'USD':
      return plan.priceUSD;
    case 'GBP':
      return plan.priceGBP;
    case 'EUR':
      return plan.priceEUR;
    case 'CAD':
      return plan.priceCAD;
    case 'AUD':
      return plan.priceAUD;
    case 'MXN':
      return plan.priceMXN;
    case 'BRL':
      return plan.priceBRL;
    case 'INR':
      return plan.priceINR;
    case 'JPY':
      return plan.priceJPY;
    default:
      return null;
  }
};

const getSeatPrice = (plan, currency, seats, period) => {
  if (!seats || !period) return null;
  const months = period == 'yearly' ? 12 : 1;
  const totalPrice = getTotalPrice(plan, currency);
  return totalPrice / seats / months;
}

const getDiscount = (plan, currency) => {
  return 0;
}

export default class ExpectedPlanPicker extends LightningElement {
  @api recordId;
  @track record;
  @track error;
  @track pricingVersion = null;
  @track plans = null;
  //  currency = null;
   tier = null;
   period = null;
  //  pps = null;
  //  discount = null;

  seats = null;
  seatsOptions = null;

  get currency() {
    return getFieldValue(this.record, CURRENCY_FIELD);
  }

  get isDirty() {
    return true;
  }

  @wire(getRecord, { recordId: '$recordId', fields })
  wiredRecord({ error, data }) {
    if(error) {
      console.log(error);
    }

    if (data) {
      this.record = data;
      this.pricingVersion = getFieldValue(data, PRICING_VERSION_FIELD);
    }
  }

  @wire(getPlans, { pricingVersion: '$pricingVersion' })
  wiredPlans({ error, data }) {
    if(error) {
      console.log(error);
    }

    if (data) {
      this.plans = JSON.parse(data);
      this.updateSeatsOptions();
    }
  }

  updateSeatsOptions() {
    const allSeats = this.plans.map(p => p.users.toString);
    const uniqueSeats = [...new Set(allSeats)];
    const options = uniqueSeats.map(s => ({ label: s, value: s }));
    this.seatsOptions = options;
  }

  get tierOptions() {
    return [
        { label: 'Basic', value: 'basic' },
        { label: 'Standard', value: 'standard' },
        { label: 'Pro', value: 'pro' },
        { label: 'Enterprise', value: 'enterprise' },
    ];
  }

  handleTierChange(event) {
    this.tier = event.detail.value;
    this.updatePrices();
  }

  get periodOptions() {
    return [
        { label: 'Monthly', value: 'monthly' },
        { label: 'Yearly', value: 'yearly' },
    ];
  }

  get seatsOptions() {
    return [
        { label: 'Monthly', value: 'monthly' },
        { label: 'Yearly', value: 'yearly' },
    ];
  }

  handleSeatsChange(event) {
    this.seats = event.detail.value;
    console.log(typeof this.seats);
    this.updatePrices();
  }

  handlePeriodChange(event) {
    this.period = event.detail.value;
    this.updatePrices();
  }

  handleTotalPriceChange(e) {
    this.totalPrice = e.detail.value;
  }

  handleSeatPriceChange(e) {
    this.seatPrice = e.detail.value;
  }

  handleDiscountChange(e) {
    this.discount = e.detail.value;
  }

  updatePrices(){
    const { seats, period, tier } = this;
    if (!seats || !period || !tier) return;
    
    const matchingPlans = this.plans.filter(p => p.users == seats && p.period == period && p.tier == tier);
    if (matchingPlans.length != 1) return;

    const plan = matchingPlans[0];
    this.totalPrice = getTotalPrice(plan, this.currency);
    this.seatPrice = getSeatPrice(plan, this.currency, seats, period);
    this.discount = getDiscount(plan, this.currency);
  }
}