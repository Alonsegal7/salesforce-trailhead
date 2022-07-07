import { LightningElement, track, api } from 'lwc';

export default class SpinnerWithText extends LightningElement {
    @api helpText = 'Please wait while loading...';
    @api size = 'medium';
    @api variant = 'base';
    @api hasRendered = false;
    @api showSpinner = false;
    @track spinnerClass;

    connectedCallback() {
        if (this.hasRendered == false) {
            this.hasRendered = true;
            if (this.size == 'small') {
                this.spinnerClass = 'spinner-small';
            } else if (this.size == 'medium') {
                this.spinnerClass = 'spinner-medium';
            } else if (this.size == 'large') {
                this.spinnerClass = 'spinner-large';
            }
        }
    }
}