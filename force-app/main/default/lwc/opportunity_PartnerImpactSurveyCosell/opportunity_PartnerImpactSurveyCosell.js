import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';
import COSELL_REQUEST_ID from '@salesforce/schema/Opportunity.Co_Sell_Request__c';
import COSELL_REQUEST_STATUS from '@salesforce/schema/Opportunity.Co_Sell_Request__r.Status__c';
import COSELL_REQUEST_SURVEY_FILLED from '@salesforce/schema/Opportunity.Co_Sell_Request__r.Impact_Survey_Filled__c';
import ACCOUNT_COSELL_LEADER from '@salesforce/schema/Opportunity.Account.Co_Sell_Leader__c';
import OPP_RECORD_TYPE from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import OPP_OWNERID from '@salesforce/schema/Opportunity.OwnerId';
import OPP_OWNER_MANAGERID from '@salesforce/schema/Opportunity.Owner.ManagerId';

export default class Opportunity_PartnerImpactSurveyCosell extends LightningElement {
    @api recordId;
    coSellReqId;
    load = false;
    userId = Id;

    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [COSELL_REQUEST_ID, 
                    COSELL_REQUEST_STATUS,
                    COSELL_REQUEST_SURVEY_FILLED, 
                    ACCOUNT_COSELL_LEADER, 
                    OPP_RECORD_TYPE, 
                    OPP_OWNERID,
                    OPP_OWNER_MANAGERID
                ]})
    wiredRecord({ error, data }) {
        if (data) {
            this.coSellReqId = getFieldValue(data, COSELL_REQUEST_ID);
            var coSellReqStatus = getFieldValue(data, COSELL_REQUEST_STATUS);
            var recordType = getFieldValue(data, OPP_RECORD_TYPE);
            var surveyFilled = getFieldValue(data, COSELL_REQUEST_SURVEY_FILLED);
            var accountCosellLeader = getFieldValue(data, ACCOUNT_COSELL_LEADER);
            var oppOwnerId = getFieldValue(data, OPP_OWNERID);
            var oppOwnerManagerId = getFieldValue(data, OPP_OWNER_MANAGERID);
            if(this.coSellReqId != null && this.coSellReqId != undefined && coSellReqStatus == 'Approved' // only for opps with approved co-sell req
                && surveyFilled == false //survey was not filled yet
                && (this.userId == oppOwnerId || this.userId == oppOwnerManagerId) //survey open only for opp owner / owner's manager
                && ((recordType == 'Partner_Opportunity' && accountCosellLeader == 'Partners') || (recordType == 'Internal_Opportunity' && accountCosellLeader == 'Sales'))){ //survey is open by leader (partner opps for partners leader and internal opps for sales leader)
                this.load = true; //load survey
            } else {
                this.load = false; //do not load survey
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
            refreshApex(this.wiredRecord);
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
        return yyyyMmDd;
    }
}