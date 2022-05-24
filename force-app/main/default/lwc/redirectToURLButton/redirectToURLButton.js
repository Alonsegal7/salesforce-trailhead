import {LightningElement,api} from 'lwc';
import createServiceOpportunities from '@salesforce/apex/ServiceOpportunityCreation.createServiceOpportunities';

export default class RedirectToURLButton extends LightningElement {    
    //@api record;
    // handleClick(){
    //     createServiceOpportunities({accountsforserviceIds:[this.record]}).then((response)=>{this.opportunityId = response[0].Id;
    //     console.log('record id: '+ this.record);
    //     var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id="+this.opportunityId +"&param=CreateQuoteFromOpp";
    //     console.log('Raz thisUrl: '+thisUrl);
    //     window.open(thisUrl,'_blank');})                                                                               
    // }
}


//this.closeAction();
    // closeAction(){
    //      this.dispatchEvent(new CloseActionScreenEvent());
   //  }