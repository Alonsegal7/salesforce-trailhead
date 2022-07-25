import { LightningElement, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'


export default class genericUpdateRecordButton extends LightningElement {
    @api recordId;
    @api name;
    @api fieldName;
    @api value;

    handleClick() {
        console.log('recordId: '+this.recordId);
        const fields = {};
        fields['Id'] = this.recordId;
        fields[this.fieldName] = this.value;
        console.log('fields: '+JSON.stringify(fields));
        console.log('fieldName: '+this.fieldName);
        console.log('value: '+this.value);
            

        const recordInput = { fields };
        console.log('recordInput: '+JSON.stringify(recordInput));


        updateRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record Updated',
                    variant: 'success'
                })
            );

        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Updating Record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });

 
    }
}









