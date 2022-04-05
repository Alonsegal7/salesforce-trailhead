import { LightningElement,track,wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import OPP_ID from '@salesforce/schema/Opportunity.Id';
import RELATED_OPP_ID from '@salesforce/schema/Opportunity.Related_Opportunity__c';

export default class NewCorrectionQuote extends LightningElement {
    @api recordId;
    oppId;
    relatedOppId;
    @wire(getRecord, { recordId: '$recordId', fields: [OPP_ID, RELATED_OPP_ID] })
    wiredOpp(result) {  
        if(result.data){
            this.relatedOppId = getFieldValue(result.data, RELATED_OPP_ID);
            this.goToDealHub();
            this.closeAction();
        }
    } 

    goToDealHub(event){
        console.log('record id: '+this.relatedOppId);
        var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id="+this.relatedOppId+"&param=Quotes";        
        window.open(thisUrl,'_blank');
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}