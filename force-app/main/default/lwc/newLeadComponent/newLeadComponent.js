import { LightningElement, api } from 'lwc';

export default class NewLeadComponent extends LightningElement {
    @api initOwner;
    @api companySize;
    @api country;
}