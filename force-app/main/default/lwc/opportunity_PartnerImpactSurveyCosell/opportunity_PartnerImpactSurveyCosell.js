import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import COSELL_REQUEST_FIELD from '@salesforce/schema/Opportunity.Co_Sell_Request__c';

export default class Opportunity_PartnerImpactSurveyCosell extends LightningElement {
    @api recordId;
    targetId;
    load = false;
    userId = Id;

    @wire(getRecord, { recordId: '$recordId', fields: [COSELL_REQUEST_FIELD]})
    wiredRecord({ error, data }) {
        if (data) {
            this.targetId = getFieldValue(data, COSELL_REQUEST_FIELD);
            this.load = true;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.targetId = undefined;
        }
    }

    handleSurveyFilledEvent(){
        // Create the recordInput object
        const fields = {};
        fields.Id = this.targetId;
        fields.Impact_Survey_Responded_By__c = this.userId;
        fields.Impact_Survey_Responded_Date__c = this.getTodayDate();

        const recordInput = { fields };

        updateRecord(recordInput)
        .then(() => {
            console.log('success update survey filled by/date.');
        })
        .catch(error => {
            console.log('error updating survey filled by/date: ' + JSON.stringify(error));
        });
    }

    getTodayDate(){
        // Get the current date/time in UTC
        let rightNow = new Date();

        // Adjust for the user's time zone
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );

        // Return the date in "YYYY-MM-DD" format
        let yyyyMmDd = rightNow.toISOString().slice(0,10);
        console.log(yyyyMmDd); // Displays the user's current date, e.g. "2020-05-15"
        return yyyyMmDd;
    }
}