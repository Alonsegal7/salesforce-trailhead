import { LightningElement, track, wire, api } from 'lwc';
import {createRecord, getRecord} from "lightning/uiRecordApi";
import michael_assets from '@salesforce/resourceUrl/leadContextAssets';

const fieldArray = [
    'Lead.Related_Lead_Code__c', //Need to be true in both cases Related lead and New lead
    'Lead.Distribution_reason__c',//Related - for related lead & New Lead for new lead
    'Lead.Related_Distribution_Reason__c', 
    'Lead.Owner_Name_Initial__c', 
    'Lead.Related_Record_URL__c',
    'Lead.Company_Size__c',
    'Lead.Comp_Size_Formula__c',
    'Lead.Country',
    'Lead.Long_Lead_ID__c',
    'Lead.OwnerId'
];

export default class LeadContextComponent extends LightningElement {
    @track displayComponent = false;//Flag if displaying the component on the page

    @track isRelated=false;//Flag to display related lead
    @track isNewLead=false;//Flag to display new lead
    @track recordData=null;

    @track owner=null;
    @track ownerProfile=null;

    //Related Lead
    @track relatedDistributionReason=null;
    @track relatedRecordUrl = null;

    //New Lead
    @track companySize = null;
    @track country=null;

    @track relatedLeadCode=null;
    @track distributionReason=null;

    @track starIcon = michael_assets + '/icons/Rating.svg';
    @track iconPic=null;//Setting the icon image based on the distribution reason 
    @track docUrl=null;//Setting the doc url based on the distribution reason 
    @track leadTypeTitle = null;//Setting the titleof the lead based on the distribution reason 

    @track feedbackFormUrl = null;



    @api recordId;

    @wire(getRecord , {recordId:'$recordId', fields: fieldArray})
    leadRecordData
    ({error, data}){
        if(data){
            this.recordData = data;
            this.owner = data.fields.Owner_Name_Initial__c.value;
            this.relatedDistributionReason = data.fields.Related_Distribution_Reason__c.value;
            this.relatedRecordUrl = data.fields.Related_Record_URL__c.value;
            this.relatedLeadCode = data.fields.Related_Lead_Code__c.value;
            this.distributionReason = data.fields.Distribution_reason__c.value;
            this.ownerProfile = `https://monday.lightning.force.com/lightning/r/User/${data.fields.OwnerId.value}/view`

            //Adding link to form titan, Will add the message feedbak and feedback reason on the lead
            // this.feedbackFormUrl = 'https://forms.monday.com/forms/7f75d98aace78ed4c34bdbf543f070f0?r=use1';


            //If relatedLeadCode is true then check if the Lead is new lead or related lead
            if(this.relatedLeadCode == true){
                if(this.distributionReason =='Related'){

                    this.isRelated=true;
                    this.displayComponent = true;

                    this.iconPic = michael_assets + '/icons/file.svg';
                    this.docUrl='https://monday.monday.com/docs/3298342646';
                    this.leadTypeTitle = 'This Is A Related Sign Up';
                }else if(this.distributionReason =='New lead'){

                    this.isNewLead = true;
                    this.displayComponent = true;

                    this.iconPic = michael_assets + '/icons/phone.svg';
                    this.docUrl='https://monday.monday.com/docs/3315821052';
                    this.leadTypeTitle = 'This Is A New Sign Up';
                    this.companySize = data.fields.Comp_Size_Formula__c.value;
                    this.country = data.fields.Country.value;
                }
            }
        }
        else if(error)
        {
            console.log('From wire leadRecordData Error line 90');
        }
    }

}