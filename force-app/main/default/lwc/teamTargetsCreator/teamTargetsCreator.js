import { LightningElement, api, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import findExistingTeamTargets from '@salesforce/apex/TeamTargetsCreation.findExistingTeamTargets';
import upsertTargets from '@salesforce/apex/TeamTargetsCreation.upsertTargets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { 
        label: 'Date', 
        fieldName: 'Target_Date__c', 
        type: 'date-local', 
        editable: false, 
        sortable: true, 
        typeAttributes:{
            month: "2-digit",
            day: "2-digit",
            year: "numeric"
        }
    },
    { 
        label: 'Amount', 
        fieldName: 'Amount__c', 
        type: 'currency', 
        editable: true 
    },
];

export default class TeamTargetsCreator extends LightningElement {

    @api currentUserId = Id;
    @track currentUserName;
    @api chosenYear;
    thisYear;
    yearOptions;
    targetsList;
    targetsMap = {};
    showSetTargets=false;
    loadingModal=false;
    @track tableData = [];
    columns = columns;
    rowOffset = 0;

    @wire(getRecord, { recordId: Id, fields: [Name] })
    currentUser({ error, data }) {
        if(data){
            this.currentUserName = getFieldValue(data, Name);
            console.log('##This userName is: '+this.currentUserName);
        }
        if(error){
            console.log('##Error getting currentUser: ' + error.body.message);
            this.error = error;
        }
    }

    connectedCallback() {
        this.thisYear = new Date().getFullYear()  // returns the current year
        this.chosenYear = this.thisYear;
        console.log('##This year is: '+this.thisYear);
        console.log('##This userId is: '+this.currentUserId);
        this.yearOptions = [
            { label: (this.thisYear-1), value: (this.thisYear-1)},
            { label: this.thisYear, value: this.thisYear},
            { label: (this.thisYear+1), value: (this.thisYear+1)},
        ]; //picklist values- last year, this year and next year
    } 
    
    get options() {
        return this.yearOptions;
    }
    
    handleYearChange(event) {
        this.chosenYear = event.target.value;
    }

    handleStart(){
        console.log('##Chosen year is: '+this.chosenYear);
        findExistingTeamTargets({year: this.chosenYear, ownerId: this.currentUserId})
        .then(result => {
            this.targetsList = result;
            console.log('##Targets found: '+JSON.stringify(this.targetsList));
            this.tableData = result;
            result.forEach(element => {
                this.targetsMap[element.Target_Date__c] = element;
            });
            console.log('##Targets map: '+JSON.stringify(this.targetsMap));
            this.showSetTargets=true;
        })
        .catch(error => {
            console.log('##Targets find returned error: '+error);
        })
    }
    
    handleCancelClick() {
        console.log('##Modal closed');
        this.showSetTargets = false;
    }

    handleSaveClick(event) {
        this.loadingModal=true;
        const draftValues = event.detail.draftValues
        const updatedTargets = this.targetsList;
        console.log('##Targets saved, draft list: '+JSON.stringify(draftValues));
        draftValues.forEach(newTarget => {
            console.log('##Loop - new target date: '+newTarget.Target_Date__c);
            updatedTargets.forEach(originalTarget => {
                console.log('##Loop - original target date: '+originalTarget.Target_Date__c);
                if(newTarget.Target_Date__c === originalTarget.Target_Date__c) {
                    console.log('##Loop - match found, original: '+JSON.stringify(originalTarget)+' New: '+JSON.stringify(newTarget));
                    originalTarget.Amount__c = newTarget.Amount__c;
                    // console.log('##Loop - map: '+JSON.stringify(this.targetsMap[originalTarget.Target_Date__c]));
                    //this.targetsMap[originalTarget.Target_Date__c].Amount__c=newTarget.Amount__c;
                }
            })
        });
        console.log('##Targets upserted! list: '+JSON.stringify(updatedTargets));
        // console.log('##Targets updated! map: '+JSON.stringify(this.targetsMap));
        upsertTargets({finalTargets: updatedTargets})
        .then(result => {
            console.log('##Targets upserted: '+JSON.stringify(result));
            this.showSetTargets = false;
            this.loadingModal=false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Team Targets Successfully Updated!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            console.log('##Targets find returned error: '+error);
        })
    }
}