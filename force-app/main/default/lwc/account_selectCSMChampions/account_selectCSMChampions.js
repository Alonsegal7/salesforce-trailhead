import { LightningElement, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getAllContacts from '@salesforce/apex/Account_selectCSMChamps.getAllContacts';
import saveContacts from '@salesforce/apex/Account_selectCSMChamps.saveContacts';


export default class Account_selectCSMChampions extends LightningElement {

    @api recordId;
    error;
    isLoading = true;
    contacts_options = [];
    selected_champs = [];
    originally_selected = [];
    wiredContactsResult;

    @wire(getAllContacts, { accountId: '$recordId' })
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.error) { this.error = result.error; }
        if (result.data) {
            console.log('getAllContacts data: ' + JSON.stringify(result.data));
            var parsed_data = JSON.parse(JSON.stringify(result.data));
            this.contacts_options = parsed_data.contacts_options;
            console.log('getAllContacts contacts_options: ' + JSON.stringify(this.contacts_options));
            this.selected_champs = parsed_data.selected_champs;
            this.originally_selected = parsed_data.selected_champs;
            console.log('getAllContacts selected_champs: ' + JSON.stringify(this.selected_champs));
        }
        this.isLoading = false;
    }

    handleSave() {
        var all_contacts = {};
        all_contacts['originally_selected'] = this.originally_selected;
        all_contacts['currently_selected'] = this.selected_champs;
        this.isLoading = true;
        saveContacts({
            contacts_map: all_contacts
        })
        .then(result => {
            this.isLoading = false;
            refreshApex(this.wiredContactsResult);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message: 'CSM Champions updated successfuly!',
                    variant: 'success',
                }),
            );
            this.closeQuickAction();
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleChampSelected(e){
        this.selected_champs = e.detail.value;
        console.log('selected Champs: ' + this.selected_champs);
    }
}