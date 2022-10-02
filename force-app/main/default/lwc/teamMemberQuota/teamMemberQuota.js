import {LightningElement, wire, api, track } from 'lwc';
import quotas_assets from '@salesforce/resourceUrl/leadQuota';
import getAVGDistributedScore from '@salesforce/apex/TeamQuotaComponentHelper.getAVGDistributedScore';

export default class TeamMemberQuota extends LightningElement {


    @api teamMemberInfo;
    // @api teamMemebrName;
    @track editIcon = quotas_assets + '/iconsQuota/edit.svg';


    //Padd custom event to the parent if the user clicked on the edit button 
    openEditQuotaHandler(){
        console.log('In openEditQuotaHandler');//Will be deleted
        const tileClicked = new CustomEvent('editquotaclik', {detail: this.teamMemberInfo, openWindow: true});
        this.dispatchEvent(tileClicked);
    }

    // @wire(getAVGDistributedScore, {userName: '$teamMemebrName'})
    // teamMembersDistributedScore(result){
    //     if(result.data){
    //         console.log('teamMembersDistributedScore ' , result.data);//To be delted
    //         // console.log('Line 17 testing data');//To be delted
    //         // this.teamMembers = result.data;
    //         // console.log('Wire line 25 ', JSON.stringify(this.teamMembers));//To be delted
    //         // this.isDataAvilable = true; //Set the flag to be true in order to display the team member list
    //         // console.log('line 21 ', this.isDataAvilable);//To be delted
    //     }else if(result.error){
    //         console.log('Wasnt able to fatch data ', result.error);
    //     }
    // }


}