import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createRenewalOpportunities from '@salesforce/apex/Opportunity_RenewalCreation.createRenewalOpportunities';
import checkOpenRenewalOpps from '@salesforce/apex/Opportunity_RenewalCreation.checkOpenRenewalOpps';
import checkOpenExpansionOpps from '@salesforce/apex/Opportunity_RenewalCreation.checkOpenExpansionOpps';
import checkRelatedMAs from '@salesforce/apex/Opportunity_RenewalCreation.checkRelatedMAs';
import checkCurrentContract from '@salesforce/apex/Opportunity_RenewalCreation.checkCurrentContract';
import primaryRenewalOwner from "@salesforce/schema/Contract.Primary_Renewal_Owner__c";
import renewal_primaryRenewalLabel from '@salesforce/label/c.renewal_primaryRenewalLabel';
import renewal_relatedMondayAccountLabel from '@salesforce/label/c.renewal_relatedMondayAccountLabel';
//mport Contract from '@salesforce/schema/Order.Contract';
//import ContractId from '@salesforce/schema/Order.ContractId';

export default class Opportunity_RenewalCreation extends NavigationMixin(LightningElement){//
    label = {
        renewal_primaryRenewalLabel,
        renewal_relatedMondayAccountLabel
    };

    @api recordId;
    @track opportunityId;
    @track renewalOppty;
    @track expansionOppty;
    @track mondayAcc;
    @track showSpinner = false;
    @track contractDetails;
    renewalOppEsixt = false;
    expansionOppEsixt = false;
    mondayAccExist = false;
    buttonDisplayed = false;
    primaryRenewalExist = false;
    displayOpportunity = false;
    primaryRenewalOwner;
    relevantRecordId;
    primaryRenewal = '';

    /*  Get the 'Primary_Renewal_Owner__c' fron Contract level
        While this field is empty:
        - It will show an error message via the Custom label --> 'renewal_primaryRenewalLabel'
        - It will disable the 'Create Renewal Opportunity' button
        In order to enable the button --> the user must populate the 'Primary_Renewal_Owner__c' field --> No refresh needed
    */
    @wire(checkCurrentContract,{recordId: '$recordId'})
    contractId({error,data}){
        if(data){
            console.log('Noam data'+ JSON.stringify(data))
            this.relevantRecordId = data;
        }
        if(error){
            console.log('Error Wasnt able to find record Id '+ error.body.message); 
            this.error = error; 
        }
    }
    
    @wire(getRecord, { recordId: '$relevantRecordId', fields: [primaryRenewalOwner] })
    contractRecord({ error, data }) {
        if(data){
            this.primaryRenewal = getFieldValue(data, primaryRenewalOwner);
            this.primaryRenewalExist = false;
            this.buttonDisplayed = false;
            if(this.primaryRenewal == null || this.primaryRenewal == ''){
                this.primaryRenewalExist = true;
                this.buttonDisplayed = true;
            }
        }       
        if(error){
            console.log('### error - contractRecord: ' + error.body.message);
            this.error = error;
        }
    }

    @wire(checkRelatedMAs, { recordId: '$relevantRecordId' })
    mondayAccList({ error, data }) {
        if (data) {
			// find how many items are in caselist for each loop
            this.mondayAcc = data;
            this.error = undefined;
            if(data.length == 0){
                this.buttonDisplayed = true;
                this.mondayAccExist = true;
            }
        }
        
        else if (error) {
            console.log('### error: ' + error.body.message);
            this.error = error;
        }
    }

    @wire(checkOpenRenewalOpps, { recordId: '$relevantRecordId'})
    renewalOppList({ error, data }) {
        if (data) {
            this.renewalOppty = data;
            this.error = undefined;
            if(data.length > 0){
                this.renewalOppEsixt = true;
            }

            else {
                this.renewalOppEsixt = false;
            }
        }
        
        else if (error) {
            console.log('### error: ' + error.body.message);
            this.error = error;
        }
    }

    @wire(checkOpenExpansionOpps, { recordId: '$relevantRecordId' })
    expansionList({ error, data }) {
        console.log('### data_v1: ' + data);
        if (data) {
			console.log(' No of opps_v1 --> ' + data.length);
            this.expansionOppty = data;
            this.error = undefined;
            if(data.length > 0){
                console.log('### in if_v1: ' + data.length);
                this.expansionOppEsixt = true;
            }

            else {
                console.log('### in else_v1: ' + data.length);
                this.expansionOppEsixt = false;
            }
            console.log('### expansionOppEsixt_v1: ' + this.expansionOppEsixt);
        }
        
        else if (error) {
            console.log('### error_v1: ' + error.body.message);
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
        this.showSpinner = true;
        const conIds = [this.relevantRecordId];
        createRenewalOpportunities({renewalContractIds: conIds,Source:'Manual Renewal Creation From Contract'}).then((response)=>{
            this.showSpinner = false;
            this.opportunityId = response[0].Id;
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