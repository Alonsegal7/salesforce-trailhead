import { LightningElement ,api, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getRelatedLeadOnLead from '@salesforce/apex/relatedPopoverHelper.getRelatedLeadOnLead';
import getRelatedOppsOnLead from '@salesforce/apex/relatedPopoverHelper.getRelatedOppsOnLead';
export default class LightningDatatableLWCExample extends LightningElement {
    
    @api recordId;
    @track error;
    @track leadList;
    @track oppList;
    showRelatedLeadsModal=false;
    showRelatedOppsModal=false;
    loadingModal=false;
    @track leadCount = 0;
    @track leadTitle = "";
    @track oppCount = 0;
    @track oppTitle = "";


    @track leadColumns = [
        {
            label: 'Name', 
            fieldName: 'recordUrl', 
            type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, 
            sortable: true, 
            wrapText: true
        },
        {
            label: 'Title',
            fieldName: 'Title',
            wrapText: true,
            type: 'text',
            sortable: true
        },
        {
            label: 'Region',
            fieldName: 'Region__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Owner',
            fieldName: 'Owner_Name_Text__c',
            wrapText: true,
            type: 'text',
            sortable: true
        },
        {
            label: 'Owners Group',
            fieldName: 'Owner_s_Group__c',
            wrapText: true,
            type: 'text',
            sortable: true
        },
        {
            label: 'Status',
            fieldName: 'Status',
            type: 'text',
            sortable: true
        },
        {
            label: 'Last Activity Date',
            fieldName: 'Last_Touch_Date__c',
            type: 'date',
            typeAttributes: {month: "2-digit", day: "2-digit", year: "numeric"},
            sortable: true
        }
    ];
    
    @track oppColumns = [{
            label: 'Name', 
            fieldName: 'recordUrl', 
            type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, 
            sortable: true, 
            wrapText: true
        },
        {
            label: 'Stage',
            fieldName: 'StageName',
            type: 'text',
            sortable: true
        },
        {
            label: 'Region',
            fieldName: 'Account_Region__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Owner',
            fieldName: 'Owner_s_Name__c',
            wrapText: true,
            type: 'text',
            sortable: true
        },
        {
            label: 'Owners Group',
            fieldName: 'Owner_Group_Live__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Last Activity Date',
            fieldName: 'Last_Touch_Date__c',
            type: 'date',
            typeAttributes: {month: "2-digit", day: "2-digit", year: "numeric"},
            sortable: true
        }
    ];
    
    @wire(getRelatedLeadOnLead, {leadId: '$recordId'})
    wiredLeads({error,data}) {
        // this.loadingModal=true;
        console.log('##test');
        if (data) {
            this.leadList = data;
            this.leadCount = this.leadList.length;
            this.leadTitle = `The related company has ${this.leadCount} open leads`;
            console.log('##leadCount: '+this.leadCount);
            console.log('##leadTitle: '+this.leadTitle);
            console.log('##data returned: '+JSON.stringify(data));
            let tempLeadList = this.leadList.map((item) => ({
                ...item,
                recordUrl: '/lightning/r/Lead/' +item.Id +'/view'
            }));
            tempLeadList.forEach(item => {
                if (item.Owner_s_Group__c == 'Partners') {
                    item.Owner_s_Group__c = item.Owner_s_Group__c + ' (CPM: ' + item.Owner_s_Manager__r.Name + ')';
                }
            });
            console.log('##temp data: '+JSON.stringify(tempLeadList));
            this.leadList = tempLeadList;
        } else if (error) {
            this.error = error;
        }
        this.loadingModal=false;
    }

    @wire(getRelatedOppsOnLead, {leadId: '$recordId'})
    wiredOpps({error,data}) {
        // this.loadingModal=true;
        if (data) {
            this.oppList = data;
            this.oppCount = this.oppList.length;
            this.oppTitle = `The related company has ${this.oppCount} related opportunities`;
            console.log('##oppCount: '+this.oppCount);
            console.log('##oppTitle: '+this.oppTitle);
            console.log('##data returned: '+JSON.stringify(data));
            let tempOppList = this.oppList.map((item) => ({
                ...item,
                recordUrl: '/lightning/r/Opportunity/' +item.Id +'/view'
            }));
            tempOppList.forEach(item => {
                if (item.Owner_Group_Live__c == 'Partners') {
                    item.Owner_Group_Live__c = item.Owner_Group_Live__c + ' (CPM: ' + item.Owner_s_Manager__r.Name + ')';
                }
            });
            console.log('##temp data: '+JSON.stringify(tempOppList));
            this.oppList = tempOppList;
        } else if (error) {
            this.error = error;
        }
        this.loadingModal=false;
    }

    handleRelatedLeadsClick(e){
        if(this.showRelatedLeadsModal==false) {
            this.showRelatedLeadsModal=true;
        }
        else
            this.showRelatedLeadsModal=false;
    }

    handleRelatedOppsClick(e){
        if(this.showRelatedOppsModal==false) {
            this.showRelatedOppsModal=true;
        }
        else
            this.showRelatedOppsModal=false;
    }
    handleCancelClick(e){
        this.showRelatedLeadsModal=false;
        this.showRelatedOppsModal=false;
    }
}