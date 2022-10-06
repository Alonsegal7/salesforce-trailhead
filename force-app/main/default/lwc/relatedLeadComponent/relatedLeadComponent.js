import { LightningElement, api } from 'lwc';

export default class RelatedLeadComponent extends LightningElement {
    @api initOwner;
    @api relatedDistributionReason;
    @api relatedRecordUrl;
    @api profileUrl;
}