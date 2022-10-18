import { LightningElement, track } from 'lwc';
import michael_assets from '@salesforce/resourceUrl/leadContextAssets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SubmitFeedbackButton extends LightningElement {
    @track feedbackIcon = michael_assets + '/icons/askUs.svg';
    
    feedbackUrl = 'https://forms.monday.com/forms/7f75d98aace78ed4c34bdbf543f070f0?r=use1';

    openFeedbackForm(){
        window.open(this.feedbackUrl, '_blank').focus();
    }

    copyLeadUrl(){        
        var inputc = document.body.appendChild(document.createElement("input"));
        inputc.value = window.location.href;
        inputc.select();
        document.execCommand('copy');
        inputc.parentNode.removeChild(inputc);
        
        const event = new ShowToastEvent({
            title: 'Success!',
            message: 'Lead URL Copied to Clipboard',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}
