import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import runTransfer from '@salesforce/apex/Partner_TransferRecords.runUserTransfer';

export default class QuotaAttainmentTool extends LightningElement {
    error;
    fromUserId = '';
    toUserId = '';
    badInput = false;
    showSpinner = false;
    customError = '';

    handleRunTransfer() {
        if(this.fromUserId == '' || this.toUserId == ''){
            this.badInput = true;
            this.customError = 'Whoops! Please select both from user and to user.';
        } else {
            this.error = '';
            this.customError = '';
            this.badInput = false;
            this.showSpinner = true;
            runTransfer({ oldOwnerId: this.fromUserId, newOwnerId: this.toUserId })
            .then(result => {
                this.showSpinner = false;
                if(result == 'running'){ 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: 'Records transfer between owners is running. You will recieve a summary email when completed.',
                            variant: 'success',
                        }),
                    );
                    this.template.querySelectorAll('c-search-component').forEach(element => { 
                        element.handleClose();
                    });
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
	handleLookupFromUser (event){
		this.fromUserId = event.detail.data.recordId;
    }
    handleLookupToUser(event) {
        this.toUserId = event.detail.data.recordId;
    }
}