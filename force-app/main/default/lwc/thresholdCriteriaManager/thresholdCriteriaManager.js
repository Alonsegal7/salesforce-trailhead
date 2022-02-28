import { LightningElement, api, wire, track } from 'lwc';
import findExistingThCr from '@salesforce/apex/Handover_ThresholdMapping.findExistingThCr';
import checkThresholdCriteriaFieldsValidity from '@salesforce/apex/Handover_ThresholdMapping.checkThresholdCriteriaFieldsValidity';
import updateThCr from '@salesforce/apex/Handover_ThresholdMapping.updateThCr';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Criteria Name', fieldName: 'Criteria_Name__c', sortable: true, wrapText: true , editable: true},
    { label: 'Field API Name on Opportunity', fieldName: 'Target_Field_API_Name__c', sortable: true, wrapText: true , editable: true},
    { label: 'Operator', fieldName: 'Operator__c', sortable: true, wrapText: true , editable: true},
    { label: 'Value', fieldName: 'Value__c', sortable: true, wrapText: true , hideDefaultActions: true, editable: true},
    { label: 'Relevant for Link', fieldName: 'Relevant_for_Link__c', type: 'boolean', sortable: true, wrapText: true , editable: true},
    { label: 'Relevant for Pass', fieldName: 'Relevant_for_Pass__c', type: 'boolean', sortable: true, wrapText: true , editable: true},
    { label: 'Number', fieldName: 'thCrUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, sortable: true, wrapText: true},
];


export default class ThresholdCriteriaManager extends LightningElement {
    @track tableData = [];
    columns = columns;
    rowOffset = 0;
    loadingModal = false;
    
    @api recordId;

    connectedCallback() {
        this.loadingModal = true;
        findExistingThCr({thId: this.recordId})
            .then(result => {
                this.tableData = result;
                console.log('##thCrList found: '+JSON.stringify(this.tableData));
                this.tableData.forEach(item => item['thCrUrl'] = '/lightning/r/HO_Threshold_Criteria__c/' +item['Id'] +'/view');
                this.loadingModal = false;
            })
            .catch(error => {
                console.log('##thCrList returned error: '+error);
            })
    }

    handleSave(event) {
        this.loadingModal=true;
        let draftValues = event.detail.draftValues
        console.log('##ThCr saved, draft list: '+JSON.stringify(draftValues));
        var checkBool = true;
        for ( var i = 0; i < draftValues.length; i++ ) {
            if(draftValues[i].Operator__c != null) {
                if(!["greaterthen","lessthen","equal","notequal","oneoff"].includes(draftValues[i].Operator__c)){
                    let evt = new ShowToastEvent({
                        message: 'Operator must be: greaterthen / lessthen / equal / notequal / oneoff',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    checkBool = false;
                    break;
                }
            }
        }
        
        if ( checkBool == true ) {
            updateThCr({finalThCr: draftValues, thId: this.recordId})
            .then(result => {
                console.log('##ThCr updated: '+JSON.stringify(result));
                this.loadingModal=false;
                this.tableData = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Threshold Criterias Successfully Updated!',
                        variant: 'success',
                    }),
                );
                this.template.querySelector("lightning-datatable").draftValues = [];
            })
            .catch(error => {
                if (error.body.message.includes("Field names mismatch - make sure that target opportunity field API name exists")) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: 'Field names mismatch - make sure that target opportunity field API name exists on the opportunity',
                            variant: 'error'
                        }),
                    );
                }
                else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: 'Something went wrong: '+error.body.message,
                            variant: 'error'
                        }),
                    );
                }
            })
        }
    }
}