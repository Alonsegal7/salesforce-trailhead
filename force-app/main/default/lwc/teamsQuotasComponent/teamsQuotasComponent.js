import { LightningElement, track, wire, api } from 'lwc';
import Id from '@salesforce/user/Id';
import getMyTeamQuoats from '@salesforce/apex/TeamQuotaComponentHelper.getMyTeamQuoats';


export default class TeamQuotaComponent extends LightningElement {

    // the name of the filld --> userId
    @track teamMembers;
    @track isDataAvilable =false;

    @api userId = Id;
    @track myTeamData;

    @wire(getMyTeamQuoats, {userId: '$userId'})
    teamMembers({error, data}){
        if(data){
            console.log(data);
            console.log('Line 17 testing data');
            this.teamMembers = data;
            this.isDataAvilable = true;
            console.log('line 21 ', this.isDataAvilable);
        }else if(error){
            console.log('Wasnt able to fatch data ', error);
        }
    }

    get theTeamMembers(){
        return this.teamMembers;
    }
}