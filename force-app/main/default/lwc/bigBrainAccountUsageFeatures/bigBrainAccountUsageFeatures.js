import { LightningElement, api, wire } from 'lwc';
import getAccountFeaturesUsage from '@salesforce/apex/BigBrainController.getAccountFeaturesUsage';

export default class BigBrainAccountUsageFeatures extends LightningElement {
  @api pulseAccountId;

  loaded = false;

  //General
  featuresData = []

  @wire(getAccountFeaturesUsage, { pulseAccountId: '$pulseAccountId' })
  data ({ error, data }) {
    if (!data) return;
    
    this.featuresData = this.postProcessData(JSON.parse(data).features_use)
    this.loaded = true;
  };

  postProcessData(featuresData) {
      return featuresData.map(feature => {
          return {
              ...feature, 
              name: feature.name.replaceAll("_", " "),
              class: feature.data > 0 ? 'circle green' : 'circle red'
            }
      }).sort((a, b) => a.name.toUpperCase() > b.name.toUpperCase() ? 1 : -1)
  }
}