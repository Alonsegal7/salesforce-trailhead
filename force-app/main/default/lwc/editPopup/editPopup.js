import { api, LightningElement, track } from 'lwc';

export default class TeamQuotasEditPopup extends LightningElement {

    @api memberQuotaDetail;
    @track newValue = 0;
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
}