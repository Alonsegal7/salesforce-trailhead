import { LightningElement,api } from 'lwc';

export default class RedirectToURLButton extends LightningElement {    
    @api record='';
    goToDealHub(event)
    {
        console.log('record id: '+ record);
        var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id="+record+"&param=CreateQuoteFromOpp";
        console.log('Raz thisUrl: '+thisUrl);
        window.open(thisUrl,'_blank');
    }
}

