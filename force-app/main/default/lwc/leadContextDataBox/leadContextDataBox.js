import { LightningElement, api } from 'lwc';

export default class LeadContextDataBox extends LightningElement {
    @api icon;
    @api leadTitle;
    @api dockUrl;
}