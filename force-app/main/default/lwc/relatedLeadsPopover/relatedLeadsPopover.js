import { LightningElement ,api, wire, track} from 'lwc';
import getLeadData from '@salesforce/apex/relatedPopoverHelper.getLeadData';
export default class LightningDatatableLWCExample extends LightningElement {
    
    @api recordId;
    error;
    leadList;
    oppList;
    maList;
    showRelatedLeadsModal = false;
    showRelatedOppsModal = false;
    showRelatedMAsModal = false;
    showRelatedMA = false;
    loadingModal = false;
    leadCount = 0;
    leadTitle = "";
    oppCount = 0;
    oppTitle = "";
    relatedCompanyId;
    parentCompanyId;
    maCount = 0;
    maTitle = "";
    leadData;

    get relatedCompany() {
        return this.relatedCompanyId;
    }

    get relatedLeadsListUrl() {
        return 'https://monday.lightning.force.com/lightning/r/Account/'+this.relatedCompanyId+'/related/Leads__r/view';
    }

    get relatedOppsListUrl() {
        return 'https://monday.lightning.force.com/lightning/r/Account/'+this.relatedCompanyId+'/related/Opportunities__r/view';
    }

    leadColumns = [
        {label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, sortable: true, wrapText: true},
        {label: 'Title', fieldName: 'Title', wrapText: true, type: 'text', sortable: true},
        {label: 'Region', fieldName: 'Region__c', type: 'text', sortable: true},
        {label: 'Owner', fieldName: 'Owner_Name_Text__c', wrapText: true, type: 'text', sortable: true},
        {label: 'Owners Group', fieldName: 'Owner_s_Group__c', wrapText: true, type: 'text', sortable: true},
        {label: 'Status', fieldName: 'Status', type: 'text', sortable: true},
        {label: 'Last Activity Date', fieldName: 'Last_Touch_Date__c', type: 'date', typeAttributes: {month: "2-digit", day: "2-digit", year: "numeric"}, sortable: true}
    ];
    
    oppColumns = [
        {label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, sortable: true, wrapText: true},
        {label: 'Stage',fieldName: 'StageName', type: 'text', sortable: true},
        {label: 'Region', fieldName: 'Account_Region__c', type: 'text', sortable: true},
        {label: 'Owner', fieldName: 'Owner_s_Name__c', wrapText: true, type: 'text', sortable: true},
        {label: 'Owners Group', fieldName: 'Owner_Group_Live__c', type: 'text', sortable: true},
        {label: 'Last Activity Date', fieldName: 'LastActivityDate', type: 'date', typeAttributes: {month: "2-digit", day: "2-digit", year: "numeric"}, sortable: true}
    ];
    
    maColumns = [
        {label: 'Name', fieldName: 'recordUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}, sortable: true, wrapText: true},
        {label: 'Region', fieldName: 'Region__c', type: 'text', sortable: true},
        {label: 'Owner', fieldName: 'Owner_Name__c', wrapText: true, type: 'text', sortable: true},
        {label: 'Owners Group', fieldName: 'Owner_s_Group__c', type: 'text', sortable: true},
        {label: 'ARR', fieldName: 'ARR__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' }},
        {label: 'Seats', fieldName: 'Plan_Seats__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' }}
    ];

    @wire(getLeadData, {leadId: '$recordId'})
    wiredData({error,data}) {
        if(data){
            console.log('##wiredData: '+JSON.stringify(data));
            this.leadData = JSON.parse(JSON.stringify(data));
            this.leadList = this.leadData.relatedLeads;
            this.leadCount = this.leadList.length;
            this.leadTitle = `The related company has ${this.leadCount} open leads`;

            this.oppList = this.leadData.relatedOpps;
            this.oppCount = this.oppList.length;
            this.oppTitle = `The related company has ${this.oppCount} opportunities`;
            
            this.maList = this.leadData.relatedPayingMAs;
            this.maCount = this.maList.length;
            this.maTitle = `The related company has ${this.maCount} paying monday accounts`;

            this.showRelatedMA = this.leadData.isRelatedCompanyOwnedByAccountsPool;
            this.relatedCompanyId = this.leadData.relatedCompanyId;
        } else if (error) {
            console.log('##wiredData error: '+JSON.stringify(error));
        }
    }

    assembleRelatedLeadsDataTable() {
        let tempLeadList = this.leadList.map((item) => ({
            ...item,
            recordUrl: '/lightning/r/Lead/' +item.Id +'/view'
        }));
        tempLeadList.forEach(item => {
            if (item.Owner_s_Group__c == 'Partners') {
                item.Owner_s_Group__c = item.Owner_s_Group__c + ' (CPM: ' + item.Owner_s_Manager__r.Name + ')';
            }
        });
        this.leadList = tempLeadList;
    }

    assembleRelatedOppsDataTable(){
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
    }

    assembleRelatedMAsDataTable(){
        let tempMaList = this.maList.map((item) => ({
            ...item,
            recordUrl: '/lightning/r/Account/' +item.Id +'/view'
        }));
        tempMaList.forEach(item => {
            if (item.Owner_s_Group__c == 'Partners') {
                item.Owner_s_Group__c = item.Owner_s_Group__c + ' (CPM: ' + item.Owner_s_Manager__r.Name + ')';
            }
        });
        console.log('##temp data: '+JSON.stringify(tempMaList));
        this.maList = tempMaList;
    }

    handleRelatedLeadsClick(){
        this.loadingModal=true;
        this.assembleRelatedLeadsDataTable();
        this.loadingModal=false;
        if(this.showRelatedLeadsModal==false) {
            this.showRelatedLeadsModal=true;
        }
        else
            this.showRelatedLeadsModal=false;
    }

    handleRelatedOppsClick(e){
        this.loadingModal=true;
        this.assembleRelatedOppsDataTable();
        this.loadingModal=false;
        if(this.showRelatedOppsModal==false) {
            this.showRelatedOppsModal=true;
        }
        else
            this.showRelatedOppsModal=false;
    }

    handleRelatedMAsClick(e){
        this.loadingModal=true;
        this.assembleRelatedMAsDataTable();
        this.loadingModal=false;
        if(this.showRelatedMAsModal==false) {
            this.showRelatedMAsModal=true;
        }
        else
            this.showRelatedOppsModal=false;
    }
    
    handleCancelClick(e){
        this.showRelatedLeadsModal=false;
        this.showRelatedOppsModal=false;
        this.showRelatedMAsModal=false;
    }
}