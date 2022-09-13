import { LightningElement, track } from 'lwc';
import michael_assets from '@salesforce/resourceUrl/leadContextAssets';

export default class SubmitFeedbackButton extends LightningElement {
    @track feedbackIcon = michael_assets + '/icons/askUs.svg';
}