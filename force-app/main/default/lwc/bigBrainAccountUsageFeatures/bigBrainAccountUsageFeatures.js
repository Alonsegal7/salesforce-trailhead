import { LightningElement, api, wire } from 'lwc';
import getAccountFeaturesUsage from '@salesforce/apex/BigBrainController.getAccountFeaturesUsage';

const postProcessData = featuresData => 
  JSON.parse(featuresData).map(feature => (
    {
      ...feature, 
      name: feature.name.replaceAll("_", " "),
      class: feature.data > 0 ? 'circle green' : 'circle red'
    }
    )).sort((a, b) => a.name.toUpperCase() > b.name.toUpperCase() ? 1 : -1);

export default class BigBrainAccountUsageFeatures extends LightningElement {
  @api pulseAccountId;

  loaded = false;
  featuresData = []

  @wire(getAccountFeaturesUsage, { pulseAccountId: '$pulseAccountId' })
  data ({ error, data }) {
    if (!data) return;
    this.featuresData = postProcessData(data);
    this.loaded = true;
  };
}