import { LightningElement, track, wire, api } from 'lwc';
import Id from '@salesforce/user/Id';
import getMyTeamQuoats from '@salesforce/apex/TeamQuotaComponentHelper.getMyTeamQuoats';


export default class TeamQuotaComponent extends LightningElement {

    // the name of the filld --> userId
    @track teamMembers;
    @track isDataAvilable =false;

    @api userId = Id;
    @track myTeamData;

    @track openModal =false;

    @track selectedQuota;

    @wire(getMyTeamQuoats, {userId: '$userId'})
    teamMembers({error, data}){
        if(data){
            console.log('From wire line 22 ' , data);
            console.log('Line 17 testing data');
            this.teamMembers = data;
            console.log('Wire line 25 ', JSON.stringify(this.teamMembers));
            this.isDataAvilable = true;
            console.log('line 21 ', this.isDataAvilable);
        }else if(error){
            console.log('Wasnt able to fatch data ', error);
        }
    }

    get theTeamMembers(){
        return this.teamMembers;
    }

    handleDailyQuotaChanged(event){
        console.log('Line 35 handleDailyQuotaChanged', event.detail.Id);
        console.log('Line 39 ',JSON.stringify(this.teamMembers) );
        console.log('Line 41 ', this.teamMembers[0].Id);

        var teamMembersMap = new Map(this.teamMembers.map(i => [i.Id, i]));

        this.teamMembers.forEach(member => {
            if(member.Id == event.detail.Id){
                this.selectedQuota = member;
            }
            console.log(member);
        });
   
       console.log('Line 52 ', this.selectedQuota);
       this.openModal= true;
    }

    closePopUp(event){
        this.openModal = event.openWindow;
    }

    getData(){
        console.log(this.teamMembers);
    }
}