import { LightningElement, api, wire } from 'lwc';
import getLimit from '@salesforce/apex/ApexLimits.getLimits';

export default class GetOrgLimitationStatus extends LightningElement {

    @api title;
    @api subTitle;
    @api recordId;
    @api barColor;
    @api completeLabel;
    @api showTitle;
    @api orgLimitation;
    limitationResult;
    MaximumLimit;
    UsageValue;
    orgLimitatoinName;
    loading=true;

    @wire(getLimit, { requestedLimit: '$orgLimitation' })// need to add input 
    getLimitationResult(result) {
        this.limitationResult = result;
        if (result.data) {
            this.loading=false;
            this.MaximumLimit = result.data.MaximumLimit;
            this.UsageValue = result.data.UsageValue;
        } else if (result.error) {
            this.error = result.error;
            console.log('error: ' + JSON.stringify(this.error));
        }
    }
    get progress() {
        return ((this.UsageValue /  this.MaximumLimit) * 100).toFixed(2);
    }
    get barStyle() {
            if (this.progress<50){
                return `width:${this.progress}%;background:#00ca72;height: 14px;`;//green
            }else if(this.progress>=50&&this.progress<80){
                return `width:${this.progress}%;background:#ffcc00;height: 14px;`;//yellow
            }else{
                return `width:${this.progress}%;background:#fb275d;height: 14px;`;//red
            }
    }

    get title() {
        return this.title= 'Limitation Status For ' + '$orgLimitation';
    }
}