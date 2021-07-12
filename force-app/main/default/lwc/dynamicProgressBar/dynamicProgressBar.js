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
    @api conditinalFormattingReverse;
    @api completeLabel;
    @api showTitle;
    @track currentField;

    connectedCallback() {
        this.currentField = this.objectApiName+'.'+this.fieldAPIName;
        console.log('PB Raz Ben Ron this.currentField: '+this.currentField);
        console.log('PB Raz Ben Ron this.completeLabel: '+this.completeLabel);
    }
    @wire(getRecord, { recordId: '$recordId', fields: '$currentField'})
    fullRecord;

    get progress() {
        console.log('PB Raz Ben Ron this.fullRecord.data: '+this.fullRecord.data);
        console.log('PB Raz Ben Ron this.objectApiName: '+this.objectApiName);
        console.log('PB Raz Ben Ron this.fieldAPIName: '+this.fieldAPIName);
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

        }else if(this.conditinalFormattingReverse==true){
            if (this.progress<this.firstThreshold){
                return `width:${this.progress}%;background:#00ca72;height: 14px;`;//green
            }else if(this.progress>=this.firstThreshold&&this.progress<this.secondThreshold){
                return `width:${this.progress}%;background:#ffcc00;height: 14px;`;//yellow
            }else{
                return `width:${this.progress}%;background:#fb275d;height: 14px;`;//red
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