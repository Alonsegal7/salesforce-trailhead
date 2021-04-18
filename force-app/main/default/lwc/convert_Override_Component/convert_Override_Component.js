import { LightningElement,api,track } from 'lwc';
import leadCloseDate from '@salesforce/schema/Lead.Close_Date_for_Convert__c';

export default class convert_Override_Component extends LightningElement {
    @api recordId;
    @track leadCloseDate;
    fields = [leadCloseDate];
    //convertURL;
    
    handleSaveLead(event){
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields);
        console.log('Raz recordId in save: '+this.recordId);
        var thisUrl ="/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId="+this.recordId;
        //this.convertURL="https://monday--partial.lightning.force.com"+thisUrl;
        console.log('Raz thisUrl: '+thisUrl);
        window.open(thisUrl,'_self');
    }
    get convertURL(){
        return "https://monday--partial.lightning.force.com/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId="+this.recordId;
        //console.log('Raz this.convertURL: '+this.convertURL);
    }
}