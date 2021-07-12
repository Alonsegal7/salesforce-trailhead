import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedLeadsCap from '@salesforce/apex/LeadsCap_MonitorWidgetController.getLeadCapDetails';
import userId from '@salesforce/user/Id';

export default class leadsCap_MonitorWidget extends NavigationMixin(LightningElement) {
    leadCapDetails;
    remainingLeads;
    leadCapLimit;
    actualOpenLeads;
    avilableForDistribution;
    leadCapId;
    ratio;
    subTitle;

    @wire(getRelatedLeadsCap, { userId: userId }) 
        leadCapData({data, error}){
            if(data){
                this.leadCapDetails=data;
                this.leadCapId=this.leadCapDetails.Id;
                this.remainingLeads=this.leadCapDetails.Remaining_Leads_to_Hold__c;
                this.leadCapLimit=this.leadCapDetails.Open_Leads_Limit__c;
                this.actualOpenLeads=this.leadCapDetails.Open_Leads_Actual__c;
                this.avilableForDistribution=this.leadCapDetails.Available_for_Distribution__c;
                this.subTitle='Remaining Leads: '+this.remainingLeads+' (Holding '+this.actualOpenLeads+' leads, out of '+this.leadCapLimit+' available leads)';
                console.log('Raz Ben Ron lead cap data: '+ JSON.stringify(data));
            }
        }
    
    handleManuselect(event) {

        var selectedVal = event.detail.value;
        console.log( 'Raz Ben Ron Selected button is ' + selectedVal );
        if(selectedVal=='dashboard1'){
            window.open("https://monday--partial.lightning.force.com/lightning/n/Lead_Analysis");
        }
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: selectedVal,
                actionName: 'new'
            }
        });*/

    }

    get numStyle(){
        this.ratio=this.remainingLeads/this.leadCapLimit;
        if (this.ratio>=0.5){
            return `font-size:5em;color:#00ca72;`;//green
        }else if(this.ratio<0.5&&this.ratio>=0.1){
            return `font-size:5em;color:#ffcc00;`;//yellow
        }else{
            return `font-size:5em;color:#fb275d;`;//red
        }
    }

}