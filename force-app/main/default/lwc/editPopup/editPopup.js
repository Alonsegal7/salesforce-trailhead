import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TeamQuotasEditPopup extends LightningElement {

    @api memberQuotaDetail;
    @track newValue = 0;

    handleSuccess(event){
        //Update the current amount of the lead cups to the new
        // this.memberQuotaDetail.Leads_Quotas__r[0].Sign_Up_Daily_Quota__c = event.detail.fields.Sign_Up_Daily_Quota__c.value;
        const updateDailySignupQuota = new CustomEvent('updatequota',{detail: {newquotas: event.detail.fields.Sign_Up_Daily_Quota__c.value,  id: this.memberQuotaDetail.Id}});
        this.dispatchEvent(updateDailySignupQuota);
        this.showToast();
        this.closeModal();
    }
    

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        const closePopup = new CustomEvent('closepopup', {openWindow: false});
        this.dispatchEvent(closePopup);
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