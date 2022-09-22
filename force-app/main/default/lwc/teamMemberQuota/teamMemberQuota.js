import {LightningElement, api, track } from 'lwc';
import quotas_assets from '@salesforce/resourceUrl/leadQuota';

export default class TeamMemberQuota extends LightningElement {


    @api teamMemberInfo;
    @track editIcon = quotas_assets + '/iconsQuota/edit.svg';
    // connectedCallback(){
    //     console.log('Line 8');
    //     console.log(event.target.value);
    // }


    // renderedCallback(){
    //     if(this.teamMemberInfo){
    //         console.log(this.teamMemberInfo);
    //     }else{
    //         console.log('TeamMember indo is not having data');
    //     }
    // }

    // @track photoUrl = this.teamMemberInfo.MediumPhotoUrl;
    // @track name = this.teamMemberInfo.Name;
    // @track signupDailyQuota = this.teamMemberInfo.Leads_Quotas__r.at(0).Sign_Up_Daily_Quota__c;
    //     // Need to be set into Signups countries
    // @track officeRegion = this.teamMemberInfo.at(0).Office_Region__c;
    // @track currentSignupQuota = this.teamMemberInfo.Current_Sign_Up_Quota__c;
    // @track openLeadsLimit = this.teamMemberInfo.Lead_Caps__r.at(0).Open_Leads_Limit__c;
    // @track openLeadsActual = this.teamMemberInfo.Lead_Caps__r.at(0).Open_Leads_Actual__c;


}