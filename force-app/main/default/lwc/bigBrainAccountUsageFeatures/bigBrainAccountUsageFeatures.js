import { LightningElement, api, wire } from 'lwc';
import getAccountFeaturesUsage from '@salesforce/apex/BigBrainController.getAccountFeaturesUsage';

const featuresSort = (a, b) => a.name.toUpperCase() > b.name.toUpperCase() ? 1 : -1;

const postProcessData = featuresData => {
  const parsedData = JSON.parse(featuresData);
  return parsedData.map(feature => (
    {
      ...feature, 
      name: feature.name.replaceAll("_", " "),
      class: feature.data > 0 ? 'circle green' : 'circle red'
    }
    )).sort(featuresSort);
}

export default class BigBrainAccountUsageFeatures extends LightningElement {
  @api pulseAccountId;

  isLoading = true;
  featuresData = [];

  data = null;
  error = null;
  loading = true;

  @wire(getAccountFeaturesUsage, { pulseAccountId: '$pulseAccountId' })
  data ({ error, data }) {
    this.error = error;
    this.data = data;
    if (!data) return;

    this.featuresData = postProcessData(data);
    this.isLoading = false;
  };

  get isError() {
    return !!this.error;
  }

  get isLoading() {
    return this.loading && !this.error;
  }

  get isReady() {
    return this.hasData && !this.isError && !this.isLoading;
  }

  get hasData() {
    return this.featuresData && this.featuresData.length != 0;
  }
}