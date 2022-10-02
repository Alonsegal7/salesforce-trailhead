import { LightningElement, track, wire, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getMyTeamQuoats from '@salesforce/apex/TeamQuotaComponentHelper.getMyTeamQuoats';
import getAVGDistributedScore from '@salesforce/apex/TeamQuotaComponentHelper.getAVGDistributedScore';


export default class TeamQuotaComponent extends LightningElement {

    //Will hold the data from the apex method using @wire 
    @track teamMembers;
    @track teamMembersMap;

    //If we get data from @wire then dispay the records of the team members else dont 
    @track isDataAvilable =false;

    @api userId = Id;
    // @track myTeamData; -- Check if can be deleted

    //Control the popup window the value is being passed fron the child component of the member record
    @track openModal =false;

    //Being passed to the popup component in order to edit the quotas #
    @track selectedQuota;

    @wire(getMyTeamQuoats, {userId: '$userId'})
    teamMembersList(result){
        if(result.data){
            console.log('From wire line 22 ' , result.data);//To be delted
            console.log('Line 17 testing data');//To be delted
            this.teamMembers = result.data;
            console.log('Wire line 25 ', JSON.stringify(this.teamMembers));//To be delted
            this.isDataAvilable = true; //Set the flag to be true in order to display the team member list
            console.log('line 21 ', this.isDataAvilable);//To be delted
        }else if(result.error){
            console.log('Wasnt able to fatch data ', result.error);
        }
    }


    @wire(getAVGDistributedScore, {userId:'$userId'})
    teamMembersDistributedScore(result){
        if(result.data){
            console.log('Line 45', JSON.stringify(result.data));

             this.teamMembersMap = new Map(result.data.map(obj => [ obj.Owner_Name_Initial__c, obj.expr0]));

             this.teamMembers.forEach(member => {
                member.avgScore = this.teamMembersMap.get('member.Name')
                    this.selectedQuota = member;
                });
                console.log('Line 54' , JSON.stringify(this.teamMembers));
            console.log('Line 49 ' ,this.teamMembersMap); 

        }else if(result.error){
            console.log('Line 47 ', error);
        }
    }

    // get theTeamMembers(){
    //     return this.teamMembers;
    // }

    handleDailyQuotaChanged(event){
        console.log('Line 35 handleDailyQuotaChanged', event.detail.Id);//To be delted
        console.log('Line 39 ',JSON.stringify(this.teamMembers) );//To be delted
        console.log('Line 41 ', this.teamMembers[0].Id);//To be delted

        this.teamMembers.forEach(member => {
            if(member.Id == event.detail.Id){
                this.selectedQuota = member;
            }
            console.log(member);
        });
   
       console.log('Line 52 ', this.selectedQuota);//To be delted
       this.openModal= true;
    }


    //Once the user is closing the popup window or press on the X button change the modal state 
    closePopUp(event){
        this.openModal = event.openWindow;
    }

    // getData(){
    //     console.log(this.teamMembers);
    // }


    @api
    refresh(event){
        console.log('In refreshDataHandler');
        console.log( JSON.stringify(this.teamMembers));

        // At the I want able to use the refreshApex method in order to update the view therefore im forcing refresh on the page
        window.location.reload();

        // return refreshApex(this.teamMembers)
        // .then(res=>{
        //     console.log('Line 69 refresh pasd');
        // })
        // .catch(error=>{
        //     console.log('line 72 error in refresh');
        // })
        // this.teamMembers.forEach(member => {
        //     console.log(member);
        //     console.log(event.detail.newquotas);
        //     if(member.Id == event.detail.id){
        //         console.log('Line 70 ', JSON.stringify(member));

        //         member.Leads_Quotas__r.forEach(element => {
        //             element.Sign_Up_Daily_Quota__c = event.detail.newquotas;
        //         });
        //         // member.Leads_Quotas__r[0].Sign_Up_Daily_Quota__c = event.detail.newquotas;
        //     }
        // });

    }
}