import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import findTeams from '@salesforce/apex/Team_ComponentWidget.getTeams';

export default class Team_ComponentWidget extends NavigationMixin(LightningElement) {
    @track searchKey = '';
    @api recordId;
    @track titleWithCount;
    @track countBool = false;
    @track teams;
    error;
    
    //connectedCallback function is similar to init method in Lightning Components.
    // connectedCallback(){
    //     this.searchKey = this.recordId;
    // }

    @wire(findTeams, { recordId: '$recordId' })
    teamList({ error, data }) {
        console.log('### error: ' + error);
        console.log('### data: ' + data);
        if (data) {
			// find how many items are in caselist for each loop
			console.log(' No of teams --> ' + data.length);
            this.teams = data;
            this.error = undefined;
            if(data.length > 8){
                console.log('### in if: ' + data.length);
                this.titleWithCount = 'Related Teams (8+)';
                this.countBool = true;
            }

            else {
                console.log('### in else: ' + data.length);
                this.countBool = false;
                this.titleWithCount = 'Related Teams (' + data.length + ')';
            }
            console.log('### countBool: ' + countBool);
        }
        
        else if (error) {
            this.error = error;
            this.teams = undefined;
        }
    }

    viewRecord(event) {
        // Navigate to Team record page
        console.log('### event.target.value: ' + event.target.value);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "Team__c",
                "actionName": "view"
            },
        });
    }

    navigateToRelatedList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                relationshipApiName: 'Teams__r',
                actionName: 'view'
            }
        });
    }
}