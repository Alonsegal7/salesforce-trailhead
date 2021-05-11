import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import runTransfer from '@salesforce/apex/Partner_TransferRecords.runCpmTransfer';

export default class QuotaAttainmentTool extends LightningElement {
    error;
    partnerAccountId = '';
    fromCpmId = '';
    toCpmId = '';
    startingFrom = '';
    badInput = false;
    showSpinner = false;
    customError = '';

    handleRunTransfer() {
        if(this.fromCpmId == '' || this.toCpmId == '' || this.partnerAccountId == '' || this.startingFrom == ''){
            this.badInput = true;
            this.customError = 'Whoops! Please select Partner, from CPM, to CPM and Starting From.';
        } else {
            this.error = '';
            this.customError = '';
            this.badInput = false;
            this.showSpinner = true;
            console.log('partnerAccountId: ' + this.partnerAccountId);
            console.log('fromCpmId: ' + this.fromCpmId);
            console.log('toCpmId: ' + this.toCpmId);
            console.log('startingFrom: ' + this.startingFrom);
            runTransfer({ partnerAccountId: this.partnerAccountId, oldCpmId: this.fromCpmId, newCpmId: this.toCpmId, startingFrom: this.startingFrom })
            .then(result => {
                this.showSpinner = false;
                if(result == 'running'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: 'Records transfer between CPMs is running. You will recieve a summary email when completed.',
                            variant: 'success',
                        }),
                    );
                    this.fromCpmId = '';
                    this.toCpmId = '';
                    this.partnerAccountId = '';
                    this.startingFrom = '';
                } else {
                    this.badInput = true;
                    this.customError = 'No records to update.';
                } 
            })
            .catch(error => {
                this.error = error;
                this.showSpinner = false;
            });
        }
    }

    handleFromCpmChange(event) {
        this.fromCpmId = (event.detail.value)[0];
    }

    handleToCpmChange(event) {
        this.toCpmId = (event.detail.value)[0];
    }

    handlePartnerChange(event) {
        this.partnerAccountId = (event.detail.value)[0];
    }

    handleStartingFromChange(event) {
        this.startingFrom = event.detail.value;
    }
}