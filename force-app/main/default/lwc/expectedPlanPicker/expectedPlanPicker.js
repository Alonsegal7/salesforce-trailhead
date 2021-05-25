import { LightningElement } from 'lwc';

export default class ExpectedPlanPicker extends LightningElement {
  currency = null;
  pricingVersion = null;

  tier = null;
  period = null;
  users = null;
  pps = null;
  discount = null;

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
  }

  get periodOptions() {
    return [
        { label: 'Monthly', value: 'monthly' },
        { label: 'Yearly', value: 'yearly' },
    ];
  }

  handlePeriodChange(event) {
    this.period = event.detail.value;
  }
}