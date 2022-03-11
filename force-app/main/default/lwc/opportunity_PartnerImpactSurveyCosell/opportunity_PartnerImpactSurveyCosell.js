import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import COSELL_REQUEST_ID from '@salesforce/schema/Opportunity.Co_Sell_Request__c';
import COSELL_REQUEST_SURVEY_FILLED from '@salesforce/schema/Opportunity.Co_Sell_Request__r.Impact_Survey_Filled__c';
import ACCOUNT_COSELL_LEADER from '@salesforce/schema/Opportunity.Account.Co_Sell_Leader__c';
import OPP_RECORD_TYPE from '@salesforce/schema/Opportunity.RecordType.DeveloperName';

export default class Opportunity_PartnerImpactSurveyCosell extends LightningElement {
    @api recordId;
    coSellReqId;
    load = false;
    userId = Id;

    @wire(getRecord, { recordId: '$recordId', fields: [COSELL_REQUEST_ID, COSELL_REQUEST_SURVEY_FILLED, ACCOUNT_COSELL_LEADER, OPP_RECORD_TYPE]})
    wiredRecord({ error, data }) {
        if (data) {
            console.log('loading co-sell impact survey...');
            this.coSellReqId = getFieldValue(data, COSELL_REQUEST_ID);
            var recordType = getFieldValue(data, OPP_RECORD_TYPE);
            var surveyFilled = getFieldValue(data, COSELL_REQUEST_SURVEY_FILLED);
            var accountCosellLeader = getFieldValue(data, ACCOUNT_COSELL_LEADER);
            console.log('co-sell request id: '+ this.coSellReqId);
            console.log('opp record type: '+ recordType);
            console.log('survey filled: '+ surveyFilled); //PROBLEM - RETURNS NULL B/C SHARING RULES
            console.log('account Cosell Leader: '+ accountCosellLeader);
            if(this.coSellReqId != null && this.coSellReqId != undefined 
                && surveyFilled == false
                && ((recordType == 'Partner_Opportunity' && accountCosellLeader == 'Partners')
                    || (recordType == 'Internal_Opportunity' && accountCosellLeader == 'Sales'))){
                this.load = true; //load survey
                console.log('loading co-sell impact survey now!');
            } else {
                this.load = false; //do not load survey
                console.log('NO co-sell impact survey needed!');
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.coSellReqId = undefined;
        }
    }

    handleSurveyFilledEvent(){
        // Create the recordInput object
        const fields = {};
        fields.Id = this.coSellReqId;
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