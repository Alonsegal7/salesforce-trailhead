import { LightningElement, track, wire,api } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import getPlans from '@salesforce/apex/BigBrainController.getPlans';
import getForecastDetails from '@salesforce/apex/BigBrainController.getForecastDetails';

import ACCOUNT_FIELD from "@salesforce/schema/Opportunity.Account.primary_pulse_account_id__c";
import CURRENCY_FIELD from '@salesforce/schema/Opportunity.Currency__c';
import PRICING_VERSION_FIELD from '@salesforce/schema/Opportunity.Pricing_Version__c';
import TIER_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Tier__c';
import PERIOD_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Period__c';
import SEATS_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Seats__c';
import DISCOUNT_FIELD from '@salesforce/schema/Opportunity.Expected_Discount__c';

const fields = [ACCOUNT_FIELD, CURRENCY_FIELD, PRICING_VERSION_FIELD, TIER_FIELD, PERIOD_FIELD, SEATS_FIELD, DISCOUNT_FIELD];

const getTotalPrice = (plan, currency) => {
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
  @track plans;

  @track recordError;
  @track plansError;
  @track forecastDetailsError;

  @track pricingVersion;
  @track pulseAccountId;
  
  //  currency = null;
   tier = null;
   period = null;
  //  pps = null;
  //  discount = null;

  seats = null;
  seatsOptions = null;

  @track exchangeRate;
  @track currentArr;

  @track totalPrice = 0;
  @track seatPrice;
  @track discount;

  get isLoading() {
    return !this.isError && (!this.record || !this.plans || !this.forecastDetails);
  }

  get isError() {
    return this.recordError || this.plansError || this.forecastDetailsError;
  }

  get currency() {
    return getFieldValue(this.record, CURRENCY_FIELD);
  }

  get pulseAccountId() {
    return getFieldValue(this.record, ACCOUNT_FIELD);
  }

  get isDirty() {
    return true;
  }

  get discountInputValue() {
    return this.discount * 100;
  }

  @wire(getRecord, { recordId: '$recordId', fields })
  wiredRecord({ error, data }) {
    if (error) {
      console.log(error);
      this.recordError = error;
    }

    if (data) {
      this.record = data;
      this.pricingVersion = getFieldValue(data, PRICING_VERSION_FIELD);
      this.pulseAccountId = getFieldValue(data, ACCOUNT_FIELD);
    }
  }

  @wire(getPlans, { pricingVersion: '$pricingVersion' })
  wiredPlans({ error, data }) {
    if (error) {
      console.log(error);
      this.plansError = error;
    }

    if (data) {
      this.plans = JSON.parse(data);
      this.updateSeatsOptions();
    }
  }

  @wire(getForecastDetails, { pulseAccountId: '$pulseAccountId' })
  wiredForecast({ error, data }) {
    if (error) {
      console.log(error);
      this.forecastDetailsError = error;
    }

    if (data) {
      this.forecastDetails = JSON.parse(data);
      this.exchangeRate = this.forecastDetails["exchange_rate"];
      this.currentArr = this.forecastDetails["current_arr"];
    }
  }

  updateSeatsOptions() {
    const allSeats = this.plans.map(p => p.users.toString());
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
    this.updatePrices();
  }

  handlePeriodChange(event) {
    this.period = event.detail.value;
    this.updatePrices();
  }

  handleTotalPriceChange(e) {
    console.log(e.detail.value);
    this.totalPrice = e.detail.value;
    this.applyTotalPrice();
  }

  handleSeatPriceChange(e) {
    console.log(e.detail.value);
    this.seatPrice = e.detail.value;
    this.applySeatPrice();
  }

  handleDiscountChange(e) {
    console.log(e.detail.value);
    this.discount = e.detail.value / 100;
    this.applyDiscount();
  }

  updatePrices(){
    const { seats, period, tier } = this;
    if (!seats || !period || !tier) return;
    
    const matchingPlans = this.plans.filter(p => p.users == seats && p.period == period && p.tier == tier);
    if (matchingPlans.length != 1) return;

    this.plan = matchingPlans[0];
    this.totalPrice = getTotalPrice(this.plan, this.currency);
    this.seatPrice = getSeatPrice(this.plan, this.currency, seats, period);
    this.discount = getDiscount(this.plan, this.currency);
  }

  applyDiscount(){
    const { seats, period, tier } = this;
    this.totalPrice = getTotalPrice(this.plan, this.currency) * (1 - this.discount);
    this.seatPrice = getSeatPrice(this.plan, this.currency, seats, period) * (1 - this.discount);
  }

  applyTotalPrice(){
    const { seats, period, tier } = this;
    this.discount = 1 - this.totalPrice / getTotalPrice(this.plan, this.currency);
    this.seatPrice = getSeatPrice(this.plan, this.currency, seats, period) * (1 - this.discount);
  }

  applySeatPrice(){
    const { seats, period, tier } = this;
    console.log('3');

    this.discount = 1 - this.seatPrice / getSeatPrice(this.plan, this.currency, seats, period);
    this.totalPrice = getTotalPrice(this.plan, this.currency) * (1 - this.discount);
  }
}