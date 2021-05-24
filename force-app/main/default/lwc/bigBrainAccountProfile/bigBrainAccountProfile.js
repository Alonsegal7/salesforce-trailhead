import { LightningElement, wire } from 'lwc';
import getAccountProfile from '@salesforce/apex/BigBrainController.getAccountProfile';

export default class BigBrainAccountProfile extends LightningElement {
  @wire(getAccountProfile)
  data ({ error, data }) {
    if (!data) return;

    console.log(JSON.parse(data));
    this.results = JSON.parse(data);
    this.error = error;
  };

  pulseAccountId = 123;
}