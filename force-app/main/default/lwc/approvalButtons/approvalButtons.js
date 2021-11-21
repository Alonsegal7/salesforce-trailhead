import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import checkApproval from '@salesforce/apex/approvalButtonsController.checkApproval';
import approveOrRejectRecord from '@salesforce/apex/approvalButtonsController.approveOrRejectRecord';


export default class ApprovalButtons extends LightningElement {
    @api recordId;
    approvalProcessId;
    error;
    wiredLoadButtonsResult;
    comments;

    @wire(checkApproval, { recordId: '$recordId' }) 
    wiredLoadButtons(result) {
        this.wiredLoadButtonsResult = result;
        if (result.data) {
            this.approvalProcessId = result.data;
            console.log('approvalProcessId: ' + this.approvalProcessId);
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.approvalProcessId = false;
            console.log('error: ' + JSON.stringify(this.error));
        }
    }

    callApproveRecord(){
        this.error = '';
        this.isLoading = true;
        console.log('comments: '+this.comments);
        approveOrRejectRecord({
            approvalProcessId: this.approvalProcessId,
            action: 'Approve',
            comments: this.comments
        })
        .then(result => {
            this.isLoading = false;
            window.location.reload();
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    callRejectRecord(){
        this.error = '';
        this.isLoading = true;
        console.log('comments: '+this.comments);
        approveOrRejectRecord({
            approvalProcessId: this.approvalProcessId,
            action: 'Reject',
            comments: this.comments
        })
        .then(result => {
            this.isLoading = false;
            window.location.reload();
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    handleCommentsChange(event){
        this.comments = event.target.value;
     }
}