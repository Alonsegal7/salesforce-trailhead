import { LightningElement, track, wire,api } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getPlans from '@salesforce/apex/BigBrainController.getPlans';
import getForecastDetails from '@salesforce/apex/BigBrainController.getForecastDetails';

import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import ACCOUNT_FIELD from "@salesforce/schema/Opportunity.Account.primary_pulse_account_id__c";
import CURRENCY_FIELD from '@salesforce/schema/Opportunity.Currency__c';
import ISO_CURRENCY_FIELD from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import PRICING_VERSION_FIELD from '@salesforce/schema/Opportunity.Pricing_Version__c';
import QUOTE_TYPE_FIELD from '@salesforce/schema/Opportunity.Expected_Quote_Type__c';
import ADDED_ARR_FIELD from '@salesforce/schema/Opportunity.Expected_ARR__c';
import TIER_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Tier__c';
import PERIOD_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Period__c';
import SEATS_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Seats__c';
import SEAT_PRICE_FIELD from '@salesforce/schema/Opportunity.Expected_Seat_Price__c';
import DISCOUNT_FIELD from '@salesforce/schema/Opportunity.Expected_Discount__c';

const fields = [
  ACCOUNT_FIELD,
  CURRENCY_FIELD,
  ISO_CURRENCY_FIELD,
  PRICING_VERSION_FIELD,
  QUOTE_TYPE_FIELD,
  ADDED_ARR_FIELD,
  TIER_FIELD,
  PERIOD_FIELD,
  SEATS_FIELD,
  SEAT_PRICE_FIELD,
  DISCOUNT_FIELD
];

const PERIOD_YEARLY = 'yearly';
const PERIOD_MONTHLY = 'monthly'
const QUOTE_TYPE_NEW_CONTARCT = 'New Contract';
const QUOTE_TYPE_PRORATED = 'Pro-rated';

const getTotalPrice = (plan, currency) => {
  switch (currency) {
    case 'USD':
      return plan.price_usd;
    case 'GBP':
      return plan.price_gbp;
    case 'EUR':
      return plan.price_eur;
    case 'CAD':
      return plan.price_cad;
    case 'AUD':
      return plan.price_aud;
    case 'MXN':
      return plan.price_mxn;
    case 'BRL':
      return plan.price_brl;
    case 'INR':
      return plan.price_inr;
    case 'JPY':
      return plan.price_jpy;
    default:
      return null;
  }
};

const getSeatPrice = (plan, currency, seats, period) => {
  if (!seats || !period) return null;
  const months = period == PERIOD_YEARLY ? 12 : 1;
  const totalPrice = getTotalPrice(plan, currency);
  return totalPrice / seats / months;
}

const getDiscount = (plan, currency) => {
  return 0;
}

const parseSeatsOptions = (plans, quoteType, currentSeats) => {
  const allSeats = plans.map(p => p.users.toString());
  const uniqueSeats = [...new Set(allSeats)];
  const options = uniqueSeats.map(s => ({ label: (quoteType == QUOTE_TYPE_NEW_CONTARCT) ? s : `+${currentSeats - s}`, value: s }));
  return options;
}

export default class ExpectedPlanPicker extends LightningElement {
  @api recordId;

  @track record;
  @track plans;
  @track forecastDetails;

  @track recordError;
  @track plansError;
  @track forecastDetailsError;

  @track pricingVersion;
  @track pulseAccountId;
  
  @track formFields = {};
  @track seatsOptions = null;

  @wire(getRecord, { recordId: '$recordId', fields })
  wiredRecord({ error, data }) {
    if (error) {this.recordError = error;}

    if (data) {
      this.record = data;
      this.pricingVersion = getFieldValue(data, PRICING_VERSION_FIELD);
      this.pulseAccountId = getFieldValue(data, ACCOUNT_FIELD);
    }
  }

  @wire(getPlans, { pricingVersion: '$pricingVersion' })
  wiredPlans({ error, data }) {
    if (error) {this.plansError = error;}

    if (data) {
      this.plans = JSON.parse(data);
      this.seatsOptions = parseSeatsOptions(this.plans, this.quoteType, this.currentSeats);
    }
  }

  @wire(getForecastDetails, { pulseAccountId: '$pulseAccountId' })
  wiredForecast({ error, data }) {
    if (error) {this.forecastDetailsError = error;}
    if (data) {this.forecastDetails = JSON.parse(data);}
  }

  get exchangeRate() {
    return this.forecastDetails["exchange_rate"];
  }

  get currentArr() {
    return this.forecastDetails["current_arr"];
  }

  get currentSeats() {
    return this.forecastDetails["current_seats"];
  }

  get currentTier() {
    return this.forecastDetails["current_tier"];
  }

  get isLoading() {
    return !this.isError && (!this.record || !this.plans || !this.forecastDetails);
  }

  get isError() {
    return this.recordError || this.plansError || this.forecastDetailsError;
  }

  get currency() {
    return getFieldValue(this.record, ISO_CURRENCY_FIELD);
  }

  get pulseAccountId() {
    return getFieldValue(this.record, ACCOUNT_FIELD);
  }

  get isApplyDisabled() {
    if (!this.isDirty) { return true; }

  }

  get isRevertDisabled() {

  }

  get isClearDisabled() {

  }

  setFormField(fieldName, value){
    const newFields = { ...this.formFields };
    newFields[fieldName] = value;
    this.formFields = newFields;
  }

  get tier() {
    return this.formFields[TIER_FIELD.fieldApiName] || getFieldValue(this.record, TIER_FIELD);
  }

  set tier(value){
    this.setFormField(TIER_FIELD.fieldApiName, value);
  }

  get quoteType() {
    return this.formFields[QUOTE_TYPE_FIELD.fieldApiName] || getFieldValue(this.record, QUOTE_TYPE_FIELD);
  }

  set quoteType(value){
    this.setFormField(QUOTE_TYPE_FIELD.fieldApiName, value);
  }

  get period() {
    return this.formFields[PERIOD_FIELD.fieldApiName] || getFieldValue(this.record, PERIOD_FIELD);
  }

  set period(value){
    this.setFormField(PERIOD_FIELD.fieldApiName, value);
  }

  get seat() {
    return this.formFields[SEATS_FIELD.fieldApiName] || getFieldValue(this.record, SEATS_FIELD);
  }

  set seat(value){
    this.setFormField(SEATS_FIELD.fieldApiName, value);
  }

  get seatPrice() {
    return this.formFields[SEAT_PRICE_FIELD.fieldApiName] || getFieldValue(this.record, SEAT_PRICE_FIELD);
  }

  set seatPrice(value){
    this.setFormField(SEAT_PRICE_FIELD.fieldApiName, value);
  }

  get discount() {
    return this.formFields[DISCOUNT_FIELD.fieldApiName] || getFieldValue(this.record, DISCOUNT_FIELD);
  }

  set discount(value){
    this.setFormField(DISCOUNT_FIELD.fieldApiName, value);
  }

  handleApplyClick() {
    const fields = {...this.formFields};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[ADDED_ARR_FIELD.fieldApiName] = this.addedArr;
    const recordInput = { fields };
    
    updateRecord(recordInput)
      .then(() => {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Forecast updated',
                  variant: 'success'
              })
          );
      })
      .catch(error => {
        new ShowToastEvent({
          title: 'Error',
          message: 'Error updating forecast',
          variant: 'error'
        })
      });
  }

  handleRevertClick() {
    this.formFields = {};
  }

  handleClearClick() {
    this.tier = null;
    this.quoteType = null;
    this.seats = null;
    this.seatPrice = null;
    this.discount = null;
    this.period = null;

    this.handleApplyClick();
  }

  get isDirty() {
    return Object.values(this.formFields).some(v => v !== null);
  }

  get discountInputValue() {
    return this.discount * 100;
  }

  get addedSeats() {
    const {quoteType, seats, currentSeats} = this;

    switch (quoteType) {
      case QUOTE_TYPE_NEW_CONTARCT:
        return seats;
      case QUOTE_TYPE_PRORATED:
        return currentSeats;
      
      default:
        return null;
    }
  }

  get addedArr() {
    const {quoteType, exchangeRate, addedSeats, seatPrice, currentArr} = this;
    const newArr = 12 * exchangeRate * addedSeats * seatPrice;

    switch (quoteType) {
      case QUOTE_TYPE_NEW_CONTARCT:
        return newArr - currentArr;
      case QUOTE_TYPE_PRORATED:
        return newArr;
      
      default:
        return null;
    }
  }

  get finalArr(){
    return this.addedArr + this.currentArr;
  }

  get totalPrice(){
    const {addedSeats, seatPrice, period} = this;
    const monthlyPrice = addedSeats * seatPrice;

    switch (period) {
      case PERIOD_YEARLY:
        return 12 * monthlyPrice;
      case PERIOD_MONTHLY:
        return monthlyPrice;
      default:
        return null;
    }
  }

  get tierOptions() {
    return [
        { label: 'Basic', value: 'basic' },
        { label: 'Standard', value: 'standard' },
        { label: 'Pro', value: 'pro' },
        { label: 'Enterprise', value: 'enterprise' },
    ];
  }

  get quoteTypeOptions() {
    return [
        { label: 'New contract', value: QUOTE_TYPE_NEW_CONTARCT },
        { label: 'Prorated', value: QUOTE_TYPE_PRORATED },
    ];
  }

  get periodOptions() {
    return [
        { label: 'Monthly', value: 'monthly' },
        { label: 'Yearly', value: 'yearly' },
    ];
  }

  handleTierChange(event) {
    this.tier = event.detail.value;
    this.updatePrices();
  }

  handleQuoteTypeChange(event) {
    this.quoteType = event.detail.value;
    if(this.quoteType == QUOTE_TYPE_PRORATED) { this.tier = this.currentTier; } 
    this.seatsOptions = parseSeatsOptions(this.plans, this.quoteType, this.currentSeats);
  }

  handleSeatsChange(event) {
    this.seats = event.detail.value;
    this.updatePrices();
  }

  handlePeriodChange(event) {
    this.period = event.detail.value;
    this.updatePrices();
  }

  handleSeatPriceChange(e) {
    console.log(e.detail.value);
    this.seatPrice = e.detail.value;
    this.applySeatPrice();
  }

  handleDiscountChange(e) {
    this.discount = e.detail.value / 100;
    this.applyDiscount();
  }

  updatePrices(){
    const { seats, period, tier } = this;
    if (!seats || !period || !tier) return;
    
    const matchingPlans = this.plans.filter(p => p.users == seats && p.period == period && p.tier == tier);
    if (matchingPlans.length != 1) return;

    this.plan = matchingPlans[0];
    this.seatPrice = getSeatPrice(this.plan, this.currency, seats, period);
    this.discount = getDiscount(this.plan, this.currency);
  }

  get isTierDisabled() {
    return this.quoteType == QUOTE_TYPE_PRORATED;
  }

  get quoteTypeMessage() {
    if (!this.quoteType) { return 'Select change type'; }
    return null;
  }

  get planMessage() {
    if (this.quoteTypeMessage) { return ' '; }
    const { seats, period, tier, plan } = this;
    if (!seats || !period || !tier) { return 'Missing required fields for plan'; }
    if (!plan) { return "Plan doesn't exist"; }
    return null;
  }

  applyDiscount(){
    const { seats, period } = this;
    this.seatPrice = getSeatPrice(this.plan, this.currency, seats, period) * (1 - this.discount);
  }

  applyTotalPrice(){
    const { seats, period } = this;
    this.discount = 1 - this.totalPrice / getTotalPrice(this.plan, this.currency);
    this.seatPrice = getSeatPrice(this.plan, this.currency, seats, period) * (1 - this.discount);
  }

  applySeatPrice(){
    const { seats, period } = this;
    this.discount = 1 - this.seatPrice / getSeatPrice(this.plan, this.currency, seats, period);
  }
}