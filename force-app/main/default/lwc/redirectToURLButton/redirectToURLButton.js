import {LightningElement,api} from 'lwc';
import createServiceOpportunities from '@salesforce/apex/ServiceOpportunityCreation.createServiceOpportunities';
import {FlowNavigationFinishEvent} from 'lightning/flowSupport';

export default class RedirectToURLButton extends LightningElement {    
    @api record;
    @api availableActions = [];
    showSpinner = false;
    error;

    handleClick(){
        this.showSpinner = true;
        this.error = '';
        console.log('Entered createClick');
        createServiceOpportunities({
            accountsforserviceIds:[this.record]})
        .then((response)=>{
            this.opportunityId = response[0].Id;
            console.log('record id: '+ this.record);
            var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id="+this.opportunityId +"&param=CreateQuoteFromOpp";
            window.open(thisUrl,'_blank');
            if (this.availableActions.find((action) => action === 'FINISH')) {
                // navigate to the next screen
                const navigateFinishEvent = new FlowNavigationFinishEvent();
                this.dispatchEvent(navigateFinishEvent);
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.showSpinner = false;
        });
    }
}