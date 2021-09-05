import { LightningElement,api,wire,track } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';

export default class BannerComponent extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api title;
    @api titleFieldAPIName;
    @api bannerVariant;
    @api includeIcon;
    @api iconGroup;
    @api iconName;
    titleFieldAPI;

    connectedCallback() {
        this.titleFieldAPI = this.objectApiName+'.'+this.titleFieldAPIName;
        //console.log('BC Raz Ben Ron this.titleFieldAPI: '+this.titleFieldAPI);
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$titleFieldAPI'})
    fullRecord;

    get titleFieldContent() {
        //console.log('BC Raz Ben Ron this.fullRecord.data: '+this.fullRecord.data);
        //console.log('BC Raz Ben Ron this.objectApiName: '+this.objectApiName);
        return getFieldValue(this.fullRecord.data, this.titleFieldAPI);
    }

    get finalTitle(){
        //console.log('BC Raz Ben Ron this.titleFieldContent: '+this.titleFieldContent);
        if(this.titleFieldContent){
            return this.titleFieldContent;
        }else{
            return this.title;
        }
    }

    get varient(){
        console.log('BC Raz Ben Ron this.bannerVariant: '+this.bannerVariant);
        var varientClass='slds-notify slds-notify_alert ';
        if(this.bannerVariant=='warning'){
            varientClass+='slds-alert_warning';
        }else if(this.bannerVariant=='error'){
            varientClass+='slds-alert_error';
        }else if(this.bannerVariant=='black'){
            varientClass+='slds-alert_offline';
        }
        console.log('BC Raz Ben Ron varientClass: '+varientClass);
        return varientClass;
    }

    get icon(){
        console.log('BC Raz Ben Ron this.includeIcon: '+this.includeIcon);
        console.log('BC Raz Ben Ron this.iconGroup: '+this.iconGroup);
        console.log('BC Raz Ben Ron this.iconName: '+this.iconName);

        if(this.includeIcon==true){
            return this.iconGroup+':'+this.iconName;
        }
    }
}
