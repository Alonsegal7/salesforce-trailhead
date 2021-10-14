import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertOpportunity from '@salesforce/apex/Opportunity_RenewalCreation.insertOpportunity';
import checkRelatedOpps from '@salesforce/apex/Opportunity_RenewalCreation.checkRelatedOpps';
import checkRelatedMAs from '@salesforce/apex/Opportunity_RenewalCreation.checkRelatedMAs';
import primaryRenewalOwner from "@salesforce/schema/Contract.Primary_Renewal_Owner__c";
import renewal_primaryRenewalLabel from '@salesforce/label/c.renewal_primaryRenewalLabel';
import renewal_relatedMondayAccountLabel from '@salesforce/label/c.renewal_relatedMondayAccountLabel';

export default class Opportunity_RenewalCreation extends NavigationMixin(LightningElement){//
    label = {
        renewal_primaryRenewalLabel,
        renewal_relatedMondayAccountLabel
    };

    @api recordId;
    @track opportunityId;
    @track oppty;
    @track mondayAcc;
    @track showSpinner = false;
    @track contractDetails;
    oppEsixt = false;
    mondayAccExist = false;
    buttonDisplayed = false;
    primaryRenewalExist = false;
    displayOpportunity = false;
    primaryRenewalOwner;
    primaryRenewal = '';

    /*  Get the 'Primary_Renewal_Owner__c' fron Contract level
        While this field is empty:
        - It will show an error message via the Custom label --> 'renewal_primaryRenewalLabel'
        - It will disable the 'Create Renewal Opportunity' button
        In order to enable the button --> the user must populate the 'Primary_Renewal_Owner__c' field --> No refresh needed
    */
    @wire(getRecord, { recordId: '$recordId', fields: [primaryRenewalOwner] })
    contractRecord({ error, data }) {
        if(data){
            console.log('### data: ' + data);
            console.log('### data_v1: ' + JSON.stringify(data));
            this.primaryRenewal = getFieldValue(data, primaryRenewalOwner);
            console.log('### primaryRenewal: ' + this.primaryRenewal);
            this.primaryRenewalExist = false;
            this.buttonDisplayed = false;
            if(this.primaryRenewal == null || this.primaryRenewal == ''){
                this.primaryRenewalExist = true;
                this.buttonDisplayed = true;
                console.log('### this.primaryRenewalExist: ' + this.primaryRenewalExist);
            }
        }

        if(error){
            console.log('### error - contractRecord: ' + error.body.message);
            this.error = error;
        }
    }

    @wire(checkRelatedMAs, { recordId: '$recordId' })
    mondayAccList({ error, data }) {
        console.log('### data: ' + data);
        if (data) {
			// find how many items are in caselist for each loop
			console.log(' No of accs --> ' + data.length);
            this.mondayAcc = data;
            this.error = undefined;
            if(data.length == 0){
                console.log('### in if: ' + data.length);
                this.buttonDisplayed = true;
                this.mondayAccExist = true;
            }
            console.log('### mondayAccExist: ' + this.mondayAccExist);
        }
        
        else if (error) {
            console.log('### error: ' + error.body.message);
            this.error = error;
        }
    }

    @wire(checkRelatedOpps, { recordId: '$recordId' })
    opportunityList({ error, data }) {
        
        console.log('### data: ' + data);
        if (data) {
			// find how many items are in caselist for each loop
			console.log(' No of opps --> ' + data.length);
            this.oppty = data;
            this.error = undefined;
            if(data.length > 0){
                console.log('### in if: ' + data.length);
                this.oppEsixt = true;
            }

            else {
                console.log('### in else: ' + data.length);
                this.oppEsixt = false;
            }
            console.log('### oppEsixt: ' + this.oppEsixt);
        }
        
        else if (error) {
            console.log('### error: ' + error.body.message);
            this.error = error;
        }
    }

    viewRecord(event) {
        // Navigate to Team record page
        console.log('### event.target.value: ' + event.target.value);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "Opportunity",
                "actionName": "view"
            },
        });
    }

    handleClick() {
        console.log('!!!');
        insertOpportunity( {recordId: this.recordId}).then((response)=>{
            this.showSpinner = false;
            this.opportunityId = response.Id;
            console.log('### succcess - this.opportunityId: '+this.opportunityId);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Renewal Opportunity was created successfully",
                    variant: "success"
                }),
            );
            this.displayOpportunity = true;
        }).catch(error => {
            console.log('### error - this.opportunityId: '+error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Creating Renewal Opportunity',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    closeModal(){
        this.displayOpportunity = false;
        window.location.reload()
    }

    navigateToOpp(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opportunityId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
    }
}