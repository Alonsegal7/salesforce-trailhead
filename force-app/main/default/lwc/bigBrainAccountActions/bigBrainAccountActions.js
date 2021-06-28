import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setAccountFreeUsers from '@salesforce/apex/BigBrainController.setAccountFreeUsers';
import getAccountGrantedFeatures from '@salesforce/apex/BigBrainController.getAccountGrantedFeatures';
import grantAccountFeatures from '@salesforce/apex/BigBrainController.grantAccountFeatures';
import ungrantAccountFeatures from '@salesforce/apex/BigBrainController.ungrantAccountFeatures';
import resetAccountTrial from '@salesforce/apex/BigBrainController.resetAccountTrial';

import ACCOUNT_FIELD from '@salesforce/schema/Lead.primary_pulse_account_id__c';
import PRICING_VERSION_FIELD from '@salesforce/schema/Lead.Pricing_Version__c';
const fields = [ACCOUNT_FIELD, PRICING_VERSION_FIELD];

const formatDate = (date) => {
  var dd = String(date.getDate()).padStart(2, '0');
  var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = date.getFullYear();
  return mm + '/' + dd + '/' + yyyy;
} 

export default class BigBrainAccountActions extends LightningElement {
  @api recordId;
  @wire(getRecord, { recordId: '$recordId', fields })
  lead;
  
  @track featuresList = [];
  @track grantedFeaturesList = [];


  get oneMonthFromNow(){
    const today = new Date();
    today.setMonth(today.getMonth() + 1);
    return formatDate(today);
  }

  get todaysDate() {
    const today = new Date();
    return formatDate(today);
  }

  get pricingVersionOptions() {
    return [
      { label: '6 - old infra / higher prices', value: 6 },
      { label: '7 - new infra / lower prices', value: 7 },
      { label: '8 - new infra / higher prices', value: 8 },
      { label: '9 - new infra / updated higher prices (ENT 38$, BRL, MXN, INR)', value: 9 }
    ];
  }

  @api pulseAccountId;
  @wire(getAccountGrantedFeatures, { pulseAccountId: '$pulseAccountId' })
  data({ error, data }) {
    console.log(data);
    if(!data) {
      console.error(error);
      return;
    }

    const respJson = JSON.parse(data);
    const { allFeatures, selectedFeatures }  = this.prepareList(respJson);
    this.grantedFeaturesList.push(...selectedFeatures);
    this.featuresList.push(...allFeatures);
  }

  handleFeaturesListChange(e) {
    const updatedList = e.detail.value;
    const addedFeatures = updatedList.filter(feature => !this.grantedFeaturesList.includes(feature));
    if(addedFeatures) {
      this.grantFeatures(addedFeatures)
    } else {
      const removedFeatures = this.grantedFeaturesList.filter(feature => !updatedList.includes(feature));
      if(removedFeatures) this.ungrantFeatures();
    }
    this.grantedFeaturesList = updatedList;
  }

  prepareList(response) {
    const { allFeatures, selectedFeatures } = response;
    const tiers = Object.keys(allFeatures)
    const processedFeatures = tiers.map(tier => {
      return allFeatures[tier].map(feature => ({label: `${tier} - ${feature}`, value: feature}))
    }).flat();

    const featuresList = Object.keys(selectedFeatures.features)
    const selectedFeaturesProcessed = featuresList.map(feature => {
      const featureData = selectedFeatures.features[feature]
      if(!featureData.has_feature) return null;

      return feature;
    });
    const selectedFeaturesCurated = selectedFeaturesProcessed.filter(featureObj => !!featureObj);
    return { allFeatures: processedFeatures, selectedFeatures: selectedFeaturesCurated}
  }

  grantFeatures(addedFeatures) {
    const now = new Date();
    const dueDate = new Date(now.setDate(now.getDate() + 30)).toString();
    grantAccountFeatures({pulseAccountId: this.accountId, features: addedFeatures, due_date: dueDate})
      .then(result => {
        const evt = new ShowToastEvent({
          title: "Granted features successfully!",
          message: 'Free users was set to ' + addedFeatures,
          variant: "success",
        });

        // this.dispatchEvent(evt);
      })
      .catch(error => {
        const evt = new ShowToastEvent({
          title: "Error while setting granted features",
          variant: "error",
        });

        // this.dispatchEvent(evt);
      });
  }


  freeUsersAmount = 0;
  freeUsersUntil = "";
  pricingVersion = null;

  handlePricingVersionChange(event) {
    this.pricingVersion = event.detail.value;
  }

  handleFreeUsersAmountChange(e) {
    this.freeUsersAmount = e.detail.value;
  }

  handleFreeUsersUntilChange(e) {
    this.freeUsersUntil = e.detail.value;
}

  handleFreeUsersGrantClick(e) {
    setAccountFreeUsers({pulseAccountId: this.accountId, freeUsers: this.freeUsersAmount, untilDate: this.freeUsersUntil})
      .then(result => {
        const evt = new ShowToastEvent({
          title: "Set free users successfully!",
          message: 'Free users was set to ' + this.freeUsersAmount,
          variant: "success",
        });

        this.dispatchEvent(evt);
      })
      .catch(error => {
        const evt = new ShowToastEvent({
          title: "Error while setting free users",
          variant: "error",
        });

        this.dispatchEvent(evt);
      });
  }

  handleResetTrialClick(e) {
    resetAccountTrial({pulseAccountId: '$pulseAccountId'})
      .then(result => {
        const evt = new ShowToastEvent({
          title: "Reset account trial successfully!",
          variant: "success",
        });

        this.dispatchEvent(evt);
      })
      .catch(error => {
        const evt = new ShowToastEvent({
          title: "Error while resetting account trial",
          variant: "error",
        });

        this.dispatchEvent(evt);
      });
  }
}