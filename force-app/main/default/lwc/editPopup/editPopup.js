import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class TeamQuotasEditPopup extends LightningElement {

    @api memberQuotaDetail;
    @track newValue = 0;

    handleSuccess(event){
        console.log('Line 10 in popup',event.detail.fields.Sign_Up_Daily_Quota__c.value);
        console.log('Line 11 in popup',JSON.stringify(this.memberQuotaDetail.Leads_Quotas__r[0].Sign_Up_Daily_Quota__c));

        //Update the current amount of the lead cups to the new
        // this.memberQuotaDetail.Leads_Quotas__r[0].Sign_Up_Daily_Quota__c = event.detail.fields.Sign_Up_Daily_Quota__c.value;
        console.log('Line 15 ' , this.memberQuotaDetail.Id);
        const updateDailySignupQuota = new CustomEvent('updatequota',{detail: {newquotas: event.detail.fields.Sign_Up_Daily_Quota__c.value,  id: this.memberQuotaDetail.Id}});
        this.dispatchEvent(updateDailySignupQuota);
        this.showToast();
        this.closeModal();

        return refreshApex(this.memberQuotaDetail);
    }
    

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        const closePopup = new CustomEvent('closepopup', {openWindow: false});
        this.dispatchEvent(closePopup);
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.modalOpen = false;
        console.log('Line 16 ', this.memberQuotaDetail[0]);
    }

    newQuotaValue(event){
        this.newValue = event.target.value;
        console.log('Line 18 ', event.target.value);
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Sign Up Daily Quota',
            message: 'Sign Up Daily Quota was updated sucssfuly',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}