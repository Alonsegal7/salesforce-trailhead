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
    'Lead.Country'
];

export default class LeadContextComponent extends LightningElement {
    @track displayComponent = false;//Needs to be set to false will be rendered after check 
    @track isRelated=false;
    @track isNewLead=false;
    @track recordData=null;

    @track owner=null;
    @track relatedDistributionReason=null;
    @track relatedRecordUrl = null;

    @track companySize = null;
    @track country=null;

    @track relatedLeadCode=null;
    @track distributionReason=null;

    @track starIcon = michael_assets + '/icons/Rating.svg';
    @track iconPic=null;
    @track docUrl=null;
    @track leadTypeTitle = null;



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

            if(this.relatedLeadCode == true){
                if(this.distributionReason =='Related'){
                    this.isRelated=true;
                    this.displayComponent = true;
                    this.iconPic = michael_assets + '/icons/file.svg';
                    this.docUrl='www.google.com';
                    this.leadTypeTitle = 'This Is A Related Sign Up';
                }else if(this.distributionReason =='New lead'){
                    console.log('In else if statment ', this.distributionReason);
                    this.isNewLead = true;
                    this.displayComponent = true;
                    this.iconPic = michael_assets + '/icons/phone.svg';
                    this.docUrl='www.google.com';
                    this.leadTypeTitle = 'This Is A New Sign Up';
                    this.companySize = data.fields.Company_Size__c.value;
                    this.country = data.fields.Country.value;
                }
            }
        }
        else if(error)
        {
            console.log('Error');
        }
    }

    // get relatedLeadCode(){
    //     if(this.leadRecordData.data){
    //         console.log('Testing line 15' , this.leadRecordData.data.fields.Related_Lead_Code__c.value);
    //         return this.leadRecordData.data.fields.Related_Lead_Code__c.value;
    //     }else{
    //         return undefined;
    //     }
    // }


    // get distributionReason(){
    //     if(this.leadRecordData.data){
    //         console.log('Testing line 15' , this.leadRecordData.data.fields.Distribution_reason__c.value);
    //         return this.leadRecordData.data.fields.Distribution_reason__c.value;
    //     }else{
    //         return undefined;
    //     } 
    // }

    // get relatedDistributionReason(){
    //     if(this.leadRecordData.data){
    //         // console.log('Testing line 15' , this.leadRecordData.data.fields.Related_Distribution_Reason__c.value);
    //         return this.leadRecordData.data.fields.Related_Distribution_Reason__c.value;
    //     }else{
    //         return undefined;
    //     } 
    // }

    // get ownerNameInitial(){
    //     if(this.leadRecordData.data){
    //         // console.log('Testing line 15' , this.leadRecordData.data.fields.Owner_Name_Initial__c.value);
    //         return this.leadRecordData.data.fields.Owner_Name_Initial__c.value;
    //     }else{
    //         return undefined;
    //     }   
    // }

    // get relatedRecordUrl(){
    //     if(this.leadRecordData.data){
    //         return this.leadRecordData.data.fields.Owner_Name_Initial__c.value;
    //     }else{
    //         return undefined;
    //     }
    // }

    // get isDistributionReasonRelated(){
    //     isRelatedResonTrue = this.leadRecordData.data.fields.Related_Lead_Code__c.value;
    //     isReasonRelated = this.leadRecordData.data.fields.Distribution_reason__c.value;
    //     console.log(isRelatedResonTrue + ' ' + isReasonRelated);
    //     if( isRelatedResonTrue == true && isReasonRelated == 'Related'){
    //             return true;
    //         }else{
    //             return false;
    //         }
    // }
}