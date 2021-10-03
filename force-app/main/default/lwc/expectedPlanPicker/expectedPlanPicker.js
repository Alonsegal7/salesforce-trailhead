import { LightningElement, track, wire,api } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getPlans from '@salesforce/apex/BigBrainController.getPlans';
import getForecastDetails from '@salesforce/apex/BigBrainController.getForecastDetails';
import getAddedArr from '@salesforce/apex/BigBrainController.getAddedArr';

import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import ACCOUNT_FIELD from "@salesforce/schema/Opportunity.Account.primary_pulse_account_id__c";
import ISO_CURRENCY_FIELD from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import EXCHANGE_RATE_FIELD from '@salesforce/schema/Opportunity.USD_exchange_rate__c';
import PRICING_VERSION_FIELD from '@salesforce/schema/Opportunity.Pricing_Version__c';
import QUOTE_TYPE_FIELD from '@salesforce/schema/Opportunity.Expected_Quote_Type__c';
import ADDED_ARR_FIELD from '@salesforce/schema/Opportunity.Expected_ARR__c';
import TIER_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Tier__c';
import PERIOD_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Period__c';
import SEATS_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Seats__c';
import SEAT_PRICE_FIELD from '@salesforce/schema/Opportunity.Expected_Seat_Price__c';
import DISCOUNT_FIELD from '@salesforce/schema/Opportunity.Expected_Discount__c';
import PLAN_NAME_FIELD from '@salesforce/schema/Opportunity.Expected_Plan_Name__c';
import PRIOR_ARR_FIELD from '@salesforce/schema/Opportunity.Prior_ARR__c';
import PRIOR_SEATS_FIELD from '@salesforce/schema/Opportunity.Prior_Seats__c';
import PRIOR_TIER_FIELD from '@salesforce/schema/Opportunity.Prior_Tier__c';

const fields = [
  ACCOUNT_FIELD,
  ISO_CURRENCY_FIELD,
  EXCHANGE_RATE_FIELD,
  PRICING_VERSION_FIELD,
  QUOTE_TYPE_FIELD,
  ADDED_ARR_FIELD,
  TIER_FIELD,
  PERIOD_FIELD,
  SEATS_FIELD,
  SEAT_PRICE_FIELD,
  DISCOUNT_FIELD,
  PLAN_NAME_FIELD,
  PRIOR_SEATS_FIELD,
  PRIOR_ARR_FIELD,
  PRIOR_TIER_FIELD
];

const PERIOD_YEARLY = 'Yearly'; 
const PERIOD_MONTHLY = 'Monthly'
const QUOTE_TYPE_NEW_CONTARCT = 'New Contract';
const QUOTE_TYPE_PRORATED = 'Pro-rated';
const TIER_BASIC = 'Basic';
const TIER_STANDARD = 'Standard';
const TIER_PRO = 'Pro';
const TIER_ENTERPRISE = 'Enterprise';

const QUOTE_TYPE_OPTIONS = [
  { label: 'New contract', value: QUOTE_TYPE_NEW_CONTARCT },
  { label: 'Prorated', value: QUOTE_TYPE_PRORATED },
];

const PERIOD_OPTIONS = [
  { label: 'Monthly', value: PERIOD_MONTHLY },
  { label: 'Yearly', value: PERIOD_YEARLY },
];

const TIER_OPTIONS = [
  { label: 'Basic', value: TIER_BASIC },
  { label: 'Standard', value: TIER_STANDARD },
  { label: 'Pro', value: TIER_PRO },
  { label: 'Enterprise', value: TIER_ENTERPRISE },
];

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

const titlize = str => {
  if (!str) return;
  return str.replace(/\w\S*/g, txt => txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase());
}

const lower = str => (str || '').toLowerCase();

const calcSeatPrice = (plan, currency, seats, period) => {
  if (!seats || !period) return null;
  const months = period == PERIOD_YEARLY ? 12 : 1;
  const totalPrice = getTotalPrice(plan, currency);
  return totalPrice / seats / months;
}

const parseSeatsOptions = (plans, quoteType, priorSeats) => {
  if (!plans || !quoteType || (!priorSeats && priorSeats != 0)) { return []; } 
  const allSeats = plans.map(p => p.users.toString());
  const uniqueSeats = [...new Set(allSeats)];

  return uniqueSeats.map(s => {
    const seatsDelta = s - priorSeats;
    const label = (quoteType == QUOTE_TYPE_NEW_CONTARCT) ? s : `${s} (+${seatsDelta})`;
    return { label: label, value: s.toString() };
  }).filter(v => v);
}

export default class ExpectedPlanPicker extends LightningElement {
  @api recordId;

  @track recordData;
  @track plans;
  @track forecastDetails;
  @track planOptions;

  @track recordError;
  @track plansError;
  @track forecastDetailsError;

  @track pricingVersion;
  @track pulseAccountId;
  @track addedArr;
  
  @track isSubmitting = false;
  @track formFields = {};

  @wire(getRecord, { recordId: '$recordId', fields })
  wiredRecord({ error, data }) {
    if (error) console.log(error);
    this.recordError = error;

    if (data) {
      this.record = data;
      this.isSubmitting = false;
      this.resetFormFields();
      this.setFormField(QUOTE_TYPE_FIELD, this.defaultQuoteType);
    }
  }

  @wire(getPlans, { pricingVersion: '$pricingVersion' })
  wiredPlans({ error, data }) {
    if (error) console.log(error);
    this.plansError = error;
 
    if (data) {
      this.plans = JSON.parse(data);
      this.updateMatchingPlan();
      this.setPlanOptions();
    }
  }

  @wire(getForecastDetails, { pulseAccountId: '$pulseAccountId' })
  wiredForecast({ error, data }) {
    if (error) console.log(error);
    this.forecastDetailsError = error;
    
    if (data) {
      this.forecastDetails = JSON.parse(data);
      this.forecastDetailsError = this.forecastDetails.message;

      this.setFormField(PRIOR_ARR_FIELD, getFieldValue(this.record, PRIOR_ARR_FIELD) || this.forecastDetails["arr"] || 0);
      this.setFormField(PRIOR_SEATS_FIELD, getFieldValue(this.record, PRIOR_SEATS_FIELD) || this.forecastDetails["seats"] || 0);
      this.setFormField(PRIOR_TIER_FIELD, getFieldValue(this.record, PRIOR_TIER_FIELD) || this.forecastDetails["tier"]);

      this.setPlanOptions();
      this.updateAddedArr();
    }
  }

  updateAddedArr() {
    const {quoteType, exchangeRate, priorSeats, seats, seatPrice, priorArr} = this;
    if (!quoteType || !exchangeRate || !priorSeats || !seats || seatPrice == null || priorArr == null) {
      this.addedArr = null;
    }

    getAddedArr({quoteType, exchangeRate, priorSeats, seats, seatPrice, priorArr})
      .then(result => { this.addedArr = result; })
      .catch(error => { console.log('Error calculating added ARR', error); });
  }

  get record() {
    return this.recordData;
  }

  set record(value) {
    this.recordData = value;
    this.updateMatchingPlan();
    this.updateAddedArr();
    this.pricingVersion = getFieldValue(value, PRICING_VERSION_FIELD);

    if (getFieldValue(value, ACCOUNT_FIELD)) {
      this.pulseAccountId = getFieldValue(value, ACCOUNT_FIELD);
    } else {
      this.initMissingAccountDetails();
    }
  }

  get exchangeRate() {
    return getFieldValue(this.record, EXCHANGE_RATE_FIELD) || 0;
  }

  get priorArr() {
    const recordValue = getFieldValue(this.record, PRIOR_ARR_FIELD);
    if (recordValue && recordValue !== 0) { return recordValue; }

    return this.forecastDetails && this.forecastDetails["arr"] || 0;
  }

  get priorSeats() {
    const recordValue = getFieldValue(this.record, PRIOR_SEATS_FIELD);
    if (recordValue && recordValue !== 0) { return recordValue; }

    return this.forecastDetails && this.forecastDetails["seats"] || 0;
  }

  get priorTier() {
    return (this.forecastDetails && this.forecastDetails["tier"]) || '-';
  }

  get isLoading() {
    return !this.isError && (!this.record || !this.plans || !this.forecastDetails);
  }

  get isError() {
    return this.recordError || this.plansError || this.forecastDetailsError;
  }

  get isMissing() {
    return this.record && !this.pulseAccountId;
  }

  get isReady(){
    return !this.isLoading && !this.isError;
  }

  get isPaying() {
    return this.priorTier;
  }

  get currency() {
    return getFieldValue(this.record, ISO_CURRENCY_FIELD);
  }

  get currencyTooltip() {
    return `ARR is calculated using an exchange rate of 1 ${this.currency} to ${this.exchangeRate} USD`;
  }

  get pulseAccountId() {
    return getFieldValue(this.record, ACCOUNT_FIELD);
  }

  get isDirty() {
    return Object.values(this.formFields).some(v => v !== null);
  }

  get isSubmitting() {
    return this.isSubmitting;
  }

  get isQuoteTypeDisabled() {
    return !this.isPaying;
  }

  get isApplyDisabled() {
    return !this.isDirty || this.isSubmitting;
  }

  get isRevertDisabled() {
    return !this.isDirty || this.isSubmitting;
  }

  getFormField(field){
    return this.formFields[field.fieldApiName];
  }

  setFormField(field, value){
    const newFields = { ...this.formFields };
    const currentValue = getFieldValue(this.record, field);

    if (currentValue != value) {
      newFields[field.fieldApiName] = value;
    } else { 
      delete newFields[field.fieldApiName];
    }

    this.formFields = newFields;
  }

  resetFormFields() {
    this.formFields = {};
  }

  hasFormField(field) {
    return this.formFields.hasOwnProperty(field.fieldApiName);
  }

  get tier() {
    return titlize(this.getFormField(TIER_FIELD) || getFieldValue(this.record, TIER_FIELD));
  }

  set tier(value) {
    this.setFormField(TIER_FIELD, value);
  }

  get defaultQuoteType() {
    return getFieldValue(this.record, QUOTE_TYPE_FIELD) || QUOTE_TYPE_NEW_CONTARCT;
  }

  get quoteType() {
    return this.getFormField(QUOTE_TYPE_FIELD) || getFieldValue(this.record, QUOTE_TYPE_FIELD);
  }

  set quoteType(value) {
    const resetDiscount = this.tier != this.priorTier;

    if(value === QUOTE_TYPE_PRORATED) {
      this.tier = this.priorTier;
      this.period = PERIOD_YEARLY;
    }
    
    this.setFormField(QUOTE_TYPE_FIELD, value);
    this.setPlanOptions();
    this.updatePrices(resetDiscount);
    this.updateAddedArr();
  }

  get period() {
    return titlize(this.getFormField(PERIOD_FIELD) || getFieldValue(this.record, PERIOD_FIELD));
  }

  set period(value){
    this.setFormField(PERIOD_FIELD, value);
  }

  get seats() {
    return (this.getFormField(SEATS_FIELD) || getFieldValue(this.record, SEATS_FIELD) || '').toString();
  }

  set seats(value){
    this.setFormField(SEATS_FIELD, value);
    this.updateAddedArr();
  }

  get seatPrice() {
    return this.hasFormField(SEAT_PRICE_FIELD) ? this.getFormField(SEAT_PRICE_FIELD) : getFieldValue(this.record, SEAT_PRICE_FIELD);
  }

  set seatPrice(value){
    this.setFormField(SEAT_PRICE_FIELD, value);
    this.updateAddedArr();
  }

  get discount() {
    return this.hasFormField(DISCOUNT_FIELD) ? this.getFormField(DISCOUNT_FIELD) : getFieldValue(this.record, DISCOUNT_FIELD);
  }

  set discount(value){
    this.setFormField(DISCOUNT_FIELD, value);
  }

  get planName() {
    return `${this.tier} ${this.seats} ${this.period}`;
  }

  handleApplyClick() {
    this.isSubmitting = true;
    const fields = {...this.formFields};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[PLAN_NAME_FIELD.fieldApiName] = this.planName;
    const recordInput = { fields };
    console.log(recordInput);

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
        console.log(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Error updating forecast',
            variant: 'error'
          })
        );
        this.isSubmitting = false;
      });
  }

  handleRevertClick() {
    this.resetFormFields();
  }

  get discountInputValue() {
    return Math.round(this.discount * 10000) / 100;
  }

  get addedSeats() {
    const {quoteType, seats, priorSeats} = this;

    switch (quoteType) {
      case QUOTE_TYPE_NEW_CONTARCT:
        return seats;
      case QUOTE_TYPE_PRORATED:
        return seats - priorSeats;
      default:
        return null;
    }
  }

  get finalArr() {
    return this.addedArr + this.priorArr;
  }

  get totalPrice() {
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

  setPlanOptions() {
    this.planOptions = parseSeatsOptions(this.plans, this.quoteType, this.priorSeats);
  }

  get tierOptions() {
    return TIER_OPTIONS;
  }

  get quoteTypeOptions() {
    return QUOTE_TYPE_OPTIONS;
  }

  get periodOptions() {
    return PERIOD_OPTIONS;
  }

  handleQuoteTypeChange(event) {
    this.quoteType = event.detail.value;
  }

  handleTierChange(event) {
    this.tier = event.detail.value;
    this.updatePrices(true);
  }

  handleSeatsChange(event) {
    this.seats = event.detail.value;
    this.updatePrices(false);
  }

  handlePeriodChange(event) {
    this.period = event.detail.value;
    this.updatePrices(true);
  }

  handleSeatPriceChange(e) {
    const { seats, period, currency, plan } = this;
    this.seatPrice = e.detail.value;
    this.discount = 1 - this.seatPrice / calcSeatPrice(plan, currency, seats, period);
  }

  handleDiscountChange(e) {
    this.discount = e.detail.value / 100;
    this.seatPrice = calcSeatPrice(this.plan, this.currency, this.seats, this.period) * (1 - this.discount);
  }

  updatePrices(resetDiscount) {
    const { seats, period } = this;
    if (!seats || !period) return;
    
    this.updateMatchingPlan();
    if (resetDiscount) { this.discount = 0; }
    this.seatPrice = calcSeatPrice(this.plan, this.currency, seats, period) * (1 - this.discount);
  }

  updateMatchingPlan() {
    const { seats, period, tier, plans } = this;
    if (!seats || !period || !tier || !plans) return;
    
    const matchingPlans = plans.filter(p => p.users == seats && p.period == lower(period) && p.tier == lower(tier));
    if (matchingPlans.length != 1) return;

    this.plan = matchingPlans[0];
  }

  get isTierDisabled() {
    return this.quoteType == QUOTE_TYPE_PRORATED;
  }

  get isPeriodDisabled() {
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
}