import { LightningElement,api,wire,track } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';

export default class DynamicProgressBar extends LightningElement {
    @api title;
    @api subTitle;
    @api fieldAPIName;
    @api recordId;
    @api objectApiName;
    @api barColor;
    @api firstThreshold;
    @api secondThreshold;
    @api conditinalFormatting;
    @track currentField;

    connectedCallback() {
        this.currentField = this.objectApiName+'.'+this.fieldAPIName;
    }
    @wire(getRecord, { recordId: '$recordId', fields: '$currentField'})
    fullRecord;

    get progress() {
        return getFieldValue(this.fullRecord.data, this.objectApiName+'.'+this.fieldAPIName);
    }
    get barStyle() {
        if(this.conditinalFormatting==true){
            if (this.progress<this.firstThreshold){
                return `width:${this.progress}%;background:#fb275d;height: 14px;`;//red
            }else if(this.progress>=this.firstThreshold&&this.progress<this.secondThreshold){
                return `width:${this.progress}%;background:#ffcc00;height: 14px;`;//yellow
            }else{
                return `width:${this.progress}%;background:#00ca72;height: 14px;`;//green
            }
        }else if(this.progress=='100'){
            return `width:${this.progress}%;background:#00ca72;height: 14px;`;//green
        }else{
            return `width:${this.progress}%;background:${this.barColor};height: 14px;`;
        }
    }
    get showSubTitle() {
        return this.subTitle!=='undefined';
    }
}