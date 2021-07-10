import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActionsDetails from '@salesforce/apex/BigBrainController.getActionsDetails';
import setAccountFreeUsers from '@salesforce/apex/BigBrainController.setAccountFreeUsers';
import grantAccountFeatures from '@salesforce/apex/BigBrainController.grantAccountFeatures';
import ungrantAccountFeatures from '@salesforce/apex/BigBrainController.ungrantAccountFeatures';
import resetAccountTrial from '@salesforce/apex/BigBrainController.resetAccountTrial';
import setPricingVersion from '@salesforce/apex/BigBrainController.setPricingVersion';

const PRICING_VERSION_OPTIONS = [
  { label: '6 - old infra / higher prices', value: 6 },
  { label: '7 - new infra / lower prices', value: 7 },
  { label: '8 - new infra / higher prices', value: 8 },
  { label: '9 - new infra / updated higher prices (ENT 38$, BRL, MXN, INR)', value: 9 }
];

const formatDate = (date) => {
  var dd = String(date.getDate()).padStart(2, '0');
  var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = date.getFullYear();
  return dd + '/' + mm + '/' + yyyy;
} 

const formatFeature = (name, tier) => `${tier} - ${name}`

const parseAvailableFeatures = data => 
    Object.keys(data).map(tier => 
      data[tier].map(feature => ({label: formatFeature(feature, tier), value: feature}))
  ).flat();

const parseGrantedFeatures = temp => {
  const data = temp.features || temp;
  return Object.keys(data)
    .map(f => ({name: f, hasFeature: data[f].has_feature}))
    .filter(f => f.hasFeature)
    .map(f => f.name);
}

export default class BigBrainAccountActions extends LightningElement {
  @api recordId;
  @api pulseAccountId;
  @api pricingVersion;

  error;
  loading = true;
  submitting = false;
  @track data = {};
  @track allFeatures = [];
  @track grantedFeatures = [];

  selectedFreeUsersAmount;
  selectedFreeUsersUntil;
  selectedPricingVersion;

  @wire(getActionsDetails, { pulseAccountId: '$pulseAccountId' })
  wiredState({ error, data }) {
    this.error = error;
    if (data) { 
      const parsedData = JSON.parse(data);
      this.data = parsedData;
      this.grantedFeatures = parseGrantedFeatures(parsedData.granted_features);
      this.allFeatures = parseAvailableFeatures(parsedData.available_features);
      this.loading = false;
    }
  }

  get isError() {
    return !!this.error;
  }

  get isLoading() {
    return this.loading;
  }

  get isReady() {
    return !this.isError && !this.isLoading;
  }

  get currentFreeUsersAmount() {
    return this.data.free_users;
  }

  get freeUsersAmount() {
    return this.selectedFreeUsersAmount || this.currentFreeUsersAmount;
  }

  get freeUsersUntil() {
    return this.selectedFreeUsersUntil;
  }

  get isFreeUsersGrantDisabled() {
    return !this.selectedFreeUsersAmount || !this.isFreeUsersGrantUntilValid;
  }

  get isFreeUsersGrantUntilValid() {
    if (!this.selectedFreeUsersUntil) return false;
    const parsedDate = new Date(this.selectedFreeUsersUntil);
    return parsedDate >= this.minGrantUntilDate && parsedDate <= this.maxGrantUntilDate;
  }

  get freeUsersGrantUntilValidationMessage() {
    if (!this.selectedFreeUsersUntil) return '';
    if (!this.isFreeUsersGrantUntilValid) return `Date must be between ${formatDate(this.minGrantUntilDate)} and ${formatDate(this.maxGrantUntilDate)}`;
  }

  get minGrantUntilDate() {
    return new Date();
  }

  get maxGrantUntilDate() {
    const today = new Date();
    today.setMonth(today.getMonth() + 1);
    return today;
  }

  get isPaying() { 
    return this.data.is_paying;
  }

  get isSubmitting() {
    return this.submitting;
  }
  
  get pricingVersionOptions() {
    return PRICING_VERSION_OPTIONS; 
  }

  get currentPricingVersion() { 
    return this.data.pricing_version; 
  }

  get pricingVersion() { 
    return this.selectedPricingVersion || this.currentPricingVersion;
  }

  get isSetPricingVersionDisabled() {
    return !this.selectedPricingVersion || this.isPaying;
  }

  // Handle field changes --------------------------------------------------------------------------------------
  handleFeaturesChange(e) {
    console.log(e.detail.value);

    const updatedList = e.detail.value;
    const addedFeatures = updatedList.filter(feature => !this.grantedFeaturesList.includes(feature));
    
    if(addedFeatures.length > 0) {
      this.grantFeatures(addedFeatures);
    } else {
      const removedFeatures = this.grantedFeaturesList.filter(feature => !updatedList.includes(feature));
      if(removedFeatures.length > 0) this.ungrantFeatures(removedFeatures);
    }

    this.grantedFeaturesList = updatedList;
  }

  handlePricingVersionChange(e) {
    this.selectedPricingVersion = e.detail.value;
  }

  handleFreeUsersAmountChange(e) {
    this.selectedFreeUsersAmount = e.detail.value;
  }

  handleFreeUsersUntilChange(e) {
    this.selectedFreeUsersUntil = e.detail.value;
  }

  // Submit -------------------------------------------------------------------------------------------------
  grantFeatures(addedFeatures) {
    this.submitting = true;
    grantAccountFeatures({pulseAccountId: this.pulseAccountId, features: addedFeatures})
      .then(result => this.successToast("Granted features successfully", `Features granted: ${addedFeatures}`))
      .catch(error => this.errorToast("Error setting granted features"));
  }

  ungrantFeatures(removedFeatures) {
    this.submitting = true;
    ungrantAccountFeatures({pulseAccountId: this.pulseAccountId, features: removedFeatures })
      .then(result => this.successToast("Ungranted features successfully", `Featured removed: ${addedFeatures}`))
      .catch(error => this.errorToast("Error setting ungranting features"));
  }

  handleFreeUsersGrantClick(e) {
    this.submitting = true;
    setAccountFreeUsers({pulseAccountId: this.pulseAccountId, freeUsers: this.freeUsersAmount, untilDate: this.freeUsersUntil})
      .then(result => {
        if (result.message) { this.errorToast(result.message) } 
        else { this.successToast("Set free users successfully", `Free users was set to ${this.freeUsersAmount}`) }
      })
      .catch(error => this.errorToast("Error setting free users"));
  }

  handleResetTrialClick(e) {
    this.submitting = true;
    resetAccountTrial({pulseAccountId: this.pulseAccountId})
      .then(result => this.successToast("Reset account trial successfully!"))
      .catch(error => this.errorToast("Error resetting account trial"));
  }

  handleSetPricingVersionClick(e) {
    this.submitting = true;
    setPricingVersion({pulseAccountId: this.pulseAccountId, version: pricingVersion})
      .then(result => this.successToast("Set pricing version successfully"))
      .catch(error => this.errorToast("Error setting pricing version"));
  }

  successToast(title, message) {
    this.toast('success', title, message);
  }

  errorToast(title, message) {
    this.toast('error', title, message);
  }

  toast(variant, title, message) {
    this.submitting = false;
    const evt = new ShowToastEvent({ title, message, variant });
    this.dispatchEvent(evt);
  }
}