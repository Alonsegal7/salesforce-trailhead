import {LightningElement, api, track } from 'lwc';
import quotas_assets from '@salesforce/resourceUrl/leadQuota';

export default class TeamMemberQuota extends LightningElement {


    @api teamMemberInfo;
    @track editIcon = quotas_assets + '/iconsQuota/edit.svg';


    openEditQuotaHandler(){
        console.log('In openEditQuotaHandler');
        const tileClicked = new CustomEvent('editquotaclik', {detail: this.teamMemberInfo, openWindow: true});
        this.dispatchEvent(tileClicked);
    }


}