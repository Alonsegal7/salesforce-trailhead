import {LightningElement, wire, api, track } from 'lwc';
import quotas_assets from '@salesforce/resourceUrl/leadQuota';
import getAVGDistributedScore from '@salesforce/apex/TeamQuotaComponentHelper.getAVGDistributedScore';

export default class TeamMemberQuota extends LightningElement {

    @api teamMemberInfo;
    @track editIcon = quotas_assets + '/iconsQuota/edit.svg';

    //Padd custom event to the parent if the user clicked on the edit button 
    openEditQuotaHandler(){
        const tileClicked = new CustomEvent('editquotaclik', {detail: this.teamMemberInfo, openWindow: true});
        this.dispatchEvent(tileClicked);
    }
}